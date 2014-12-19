//
//  DataHubClient.m
//  SurveyApp
//
//  Created by Christian Kellner on 16/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

#import "DataHubClient.h"
#import "TFHpple.h"
#import  <MobileCoreServices/MobileCoreServices.h>

#import "datahub.h"
#import <THTTPClient.h>
#import <TBinaryProtocol.h>

@interface DHClient ()

@property (strong, nonatomic) AFHTTPSessionManager *http;
@property (strong, nonatomic) NSString *token;

@property (strong, nonatomic) Connection *dhConnection;
@property (strong, nonatomic) DataHubClient *dhClient;

+(NSString *)mimeTypeForURL:(NSURL *)url;
+(NSHTTPCookie *)findCookieWithName:(NSString *)cookieName forURL:(NSURL *)url;

-(BOOL) dhConnectForUser:(NSString *)user withPassword:(NSString *)pass error:(NSError **)error;
@end


@implementation DHClient

-(DHClient *) initWithURL:(NSURL *)url {
    self = [super init];
    
    if (self) {
        self.http = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
        self.http.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    return self;
}

-(void) registerUser:(NSString *)username withEmail:(NSString *)email andPassword:(NSString *)password onSuccess:(void (^)(void)) successCallback onFailure:(void (^)(NSError *err)) failureCallback
{
    [self.http GET:@"account/register" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSURL *fullURL = [self.http.baseURL URLByAppendingPathComponent:@"account/register"];

        NSString *token = [DHClient findCookieWithName:@"csrftoken" forURL:fullURL].properties[@"Value"];
        
        if (token == nil) {
            NSError *err = [NSError errorWithDomain:@"Datahub"
                                               code:1
                                           userInfo:@{ NSLocalizedDescriptionKey:
                                                           NSLocalizedString(@"Internal error :-(", nil) }];
            failureCallback(err);
            return;
        }
        
        NSDictionary *params = @{@"username": username,
                                 @"email": email,
                                 @"password": password,
                                 @"csrfmiddlewaretoken": token,
                                 @"redirect_url": @"/"};
        
        [self.http POST:@"account/register" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {

            TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
            NSArray *elements = [doc searchWithXPathQuery:@"//div[@id='error']/span[@class='error']"];
            
            if (elements.count > 0) {

                NSInteger errCode = 100;
                
                NSString *reason = [elements[0] text];
                NSString *suggestions = @"Try different username/email!";
                if ([reason isEqualToString:@"Username already taken."]) {
                    suggestions = @"Please use a different username!";
                    errCode += 1;
                } else if ([reason hasPrefix:@"Account with the email address"]) {
                    suggestions = @"Please use a different email address!";
                    errCode += 2;
                }
                
                NSDictionary *info =
                    @{NSLocalizedDescriptionKey: NSLocalizedString(@"Could not register user.", nil),
                      NSLocalizedFailureReasonErrorKey: NSLocalizedString(reason, nil),
                      NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestions, nil)};
                
                NSError *err = [NSError errorWithDomain:@"DataHub" code:errCode userInfo:info];
                failureCallback(err);

            } else {
                successCallback();
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failureCallback(error);
        }];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failureCallback(error);
    }];
}

-(void) loginForUser:(NSString *)user withPassword:(NSString *)pass onSuccess:(void (^)(void)) successCallback onFailure:(void (^)(NSError *err)) failureCallback
{
    [self.http GET:@"account/login" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        //now we have to parse the http response
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray *elements = [doc searchWithXPathQuery:@"//form[@class='form-signin']/input[@name='csrfmiddlewaretoken']"];
        
        if (elements.count != 1) {
            failureCallback(nil);
            return;
        }
        
        TFHppleElement *elm = elements[0];
        self.token = [elm objectForKey:@"value"];
        
        NSDictionary *params = @{@"csrfmiddlewaretoken": self.token,
                                 @"login_id": user,
                                 @"login_password": pass,
                                 @"redirect_url": @"/"};
        
        [self.http POST:@"account/login" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            
            dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(globalQueue, ^(void) {
                NSError *thriftErr = nil;
                BOOL thriftResult = [self dhConnectForUser:user withPassword:pass error:&thriftErr];
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    if (thriftResult) {
                        NSLog(@"should be loggend in!");
                        successCallback();
                    } else {
                        failureCallback(thriftErr);
                    }
                });
            });
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failureCallback(error);
        }];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failureCallback(error);
    }];
}



-(void) uploadFile:(NSURL *)localeFile forUser:(NSString *)user toRepository:(NSString *)repo onSuccess:(void (^)(void)) successCallback onFailure:(void (^)(NSError *err)) failureCallback
{
    NSString *pathPOST = [NSString stringWithFormat:@"upload/%@/%@/file", user, repo];
    NSString *refererPath = [NSString stringWithFormat:@"browse/%@/%@/files", user, repo];
    NSString *referer = [self.http.baseURL URLByAppendingPathComponent:refererPath].absoluteString;

    NSURL *url = [self.http.baseURL URLByAppendingPathComponent:pathPOST];
    
    NSHTTPCookie *cookie = [DHClient findCookieWithName:@"csrftoken" forURL:[NSURL URLWithString:referer]];
    NSString *token = cookie.properties[@"Value"];
    
    NSData *fileData = [NSData dataWithContentsOfURL:localeFile];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    
    NSString *buid = [NSUUID UUID].UUIDString;
    NSString *boundary = [NSString stringWithFormat:@"----MIT-AppSurvey-%@", buid];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [req setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    //adding the body:
    
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"Content-Disposition: form-data; name=\"csrfmiddlewaretoken\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[token dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *formDataFile = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"data_file\"; filename=\"%@\"\r\n", localeFile.lastPathComponent];
    
    NSString *mimeType = [DHClient mimeTypeForURL:localeFile];
    
    NSString *fileContentType = [NSString stringWithFormat:@"ontent-Type: %@\r\n", mimeType];
    
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[formDataFile dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[fileContentType dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[NSData dataWithData:fileData]];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    [req setHTTPBody:postBody];

    NSLog(@"Sending POST");
    NSURLSessionDataTask *task = [self.http dataTaskWithRequest:req completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error == nil) {
            successCallback();
        } else {
            failureCallback(error);
        }
    }];
    
    [task resume];
}
// thrift client

-(BOOL) dhConnectForUser:(NSString *)user withPassword:(NSString *)pass error:(NSError **)error {
    BOOL res = true;
    @try {
        NSURL *url = [self.http.baseURL URLByAppendingPathComponent:@"service"];
        
        // Talk to a server via HTTP, using a binary protocol
        THTTPClient *transport = [[THTTPClient alloc] initWithURL:url];
        TBinaryProtocol *protocol = [[TBinaryProtocol alloc]
                                     initWithTransport:transport
                                     strictRead:YES
                                     strictWrite:YES];
        
        self.dhClient = [[DataHubClient alloc] initWithProtocol:protocol];
        
        ConnectionParams *conparams = [[ConnectionParams alloc] initWithClient_id:@"MIT-SurveyApp" seq_id:nil user:user password:pass repo_base:nil];
        
        self.dhConnection = [self.dhClient open_connection:conparams];
        NSLog(@"Successfully establish db connection");
    }
    @catch (NSException *exception) {
        //fixme
        *error = [NSError errorWithDomain:@"DHClient" code:1 userInfo:nil];
        res = false;
    }
    
    return res;
}

-(void) uploadResponse:(NSDictionary *)response forUser:(NSString *)user toTable:(NSString *)table inRepository:(NSString *)repo onSuccess:(void (^)(void)) successCallback onFailure:(void (^)(NSError *err)) failureCallback
{
     NSLog(@"uploadResponse!");
    
    //dispatch_queue_t globalQueue = dispatch_queue_create("edu.mit.datahub", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(globalQueue, ^(void) {
        BOOL res;

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:nil];
        NSString *responseData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *uuid = response[@"uuid"];
        NSString *qStr = [NSString stringWithFormat:@"insert into %@.%@.%@ values ('%@', '%@')", user, repo, table, uuid, responseData];
        
        @try {
            ResultSet *results = [self.dhClient execute_sql:self.dhConnection query:qStr query_params:nil];
            res = results.statusIsSet && results.status;
        }
        @catch (NSException *exception) {
            res = false;
            NSLog(@"exception: %@", exception);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (res) {
                successCallback();
            } else {
                failureCallback(nil); //FIXME
            }
        });
        
    });
}

-(void) createRepo:(NSString *)repo andShareWith:(NSString *)user onSuccess:(void (^)(void)) successCallback onFailure:(void (^)(NSError *err)) failureCallback
{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^(void) {
        BOOL res = true;
        NSError *err = nil;
        @try {
            [self.dhClient create_repo:self.dhConnection repo_name:repo];
            //check resiult? it seems we always get an exception on any error
            
            if (user != nil) {
                //grant accesss of repo to user
                NSString *qstr = [NSString stringWithFormat:@"grant usage on schema %@ to %@;", repo, user];
                [self.dhClient execute_sql:self.dhConnection query:qstr query_params:nil];
                
                //Fixme: way to many permisions
                qstr = [NSString stringWithFormat:@"grant all on all tables in schema %@ to %@;", repo, user];
                [self.dhClient execute_sql:self.dhConnection query:qstr query_params:nil];
            }
            
        }
        @catch (NSException *exception) {
            res = false;
            NSDictionary *info = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Could create shared repository", nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(exception.description, nil)};
            //FIXME: exception to error is using exception.description which is crytic
            err = [NSError errorWithDomain:@"DataHub" code:50 userInfo:info];
            NSLog(@"exception: %@", exception);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (res) {
                successCallback();
            } else {
                failureCallback(err);
            }
        });

     
     });
}


// class methods

+(NSString *)mimeTypeForURL:(NSURL *)url {
    CFStringRef fileExtension = (__bridge CFStringRef)url.lastPathComponent.pathExtension;
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    CFStringRef mtype = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    NSString *mimeType = (__bridge_transfer NSString *)mtype;
    return mimeType;
}

+(NSHTTPCookie *)findCookieWithName:(NSString *)cookieName forURL:(NSURL *)url {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    
    for (NSHTTPCookie* cookie in cookies) {
    
        if ([cookie.name isEqualToString:cookieName]) {
            return cookie;
        }
    }
    return nil;
}

@end