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

@interface DHClient ()

@property (strong, nonatomic) AFHTTPSessionManager *http;
@property (strong, nonatomic) NSString *token;

+(NSString *)mimeTypeForURL:(NSURL *)url;
+(NSHTTPCookie *)findCookieWithName:(NSString *)cookieName forURL:(NSURL *)url;
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
            successCallback();
            NSLog(@"should be loggend in!");
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