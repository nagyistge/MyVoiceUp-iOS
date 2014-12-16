//
//  Ohmage2Sink.m
//  SurveyApp
//
//  Created by Christian Kellner on 14/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "Ohmage2Client.h"

@interface Ohmage2Client()
@property (strong, nonatomic) NSString *token;
@end


@implementation Ohmage2Client

+ (Ohmage2Client *)clientForURL:(NSURL *)url {
    Ohmage2Client *client = [[Ohmage2Client alloc] initWithURL:url];
    return client;
}

- (Ohmage2Client *)initWithURL:(NSURL *)url {
    self = [super initWithBaseURL:url ];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        [self setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            NSLog(@"%lld of %lld sent", totalBytesSent, totalBytesExpectedToSend);
        }];
    }
    
    return self;
}

- (void)authenticateForUser:(NSString *)user withPassword:(NSString *)pass onCompletion:(void (^)(BOOL success, NSError *err))completionBlock {
    
    NSDictionary *params = @{@"user": user, @"password": pass, @"client": @"MIT-SurveyApp"};

    [self POST:@"user/auth_token" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"response: %@", responseObject);
        
        NSString *success = responseObject[@"result"];
        BOOL res = true;
        NSError *err = nil;
        if ([success isEqualToString:@"success"]) {
            self.token = responseObject[@"token"];
        } else {
            NSLog(@"error during authentication");
            res = false;
            NSInteger errorCode = [[responseObject[@"errors"]  firstObject][@"code"] integerValue];
            err = [NSError errorWithDomain:@"ohmage.server" code:errorCode userInfo:nil];
        }
        
        completionBlock(res, err);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"error during request! %@ [%lld]", error.description, error.code);
        completionBlock(false, error);
    }];
}


- (void)fetchCampaignForName:(NSString *)name onCompletion:(void (^)(NSDictionary *campaign, BOOL success, NSError *err)) completionBlock {
    
    NSDictionary *params = @{@"auth_token":  self.token,
                             @"client": @"MIT-SurveyApp",
                             @"output_format": @"short",
                             @"campaign_name_search": name};
    
    [self POST:@"campaign/read" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"response: %@", responseObject);
    
        NSString *success = responseObject[@"result"];
        BOOL res = true;
        NSError *err = nil;
        NSDictionary *data;
        
        if ([success isEqualToString:@"success"]) {
            data = responseObject[@"data"];
        } else {
            NSLog(@"error during authentication");
            res = false;
            NSInteger errorCode = [[responseObject[@"errors"]  firstObject][@"code"] integerValue];
            err = [NSError errorWithDomain:@"ohmage.server" code:errorCode userInfo:nil];
            data = @{};
        }
        
        completionBlock(data, res, err);
        
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"error during request! %@ [%lld]", error.description, error.code);
        completionBlock(@{}, false, error);
    }];

}

- (void)uploadResponse:(NSDictionary *)response forSurvey:(NSDictionary *)survey withMedia:(NSArray *)media onCompletion:(void (^)(BOOL success, NSError *err)) completionBlock
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@[response] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *responseData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"json: [%@]", responseData);
    
    NSDictionary *params = @{ @"user": @"testuser",
                              @"auth_token":  self.token,
                              @"client": @"MIT-SurveyApp",
                              @"campaign_urn": survey[@"urn"],
                              @"campaign_creation_timestamp": survey[@"creation_timestamp"],
                              @"surveys": responseData
                              };
    
    [self POST:@"survey/upload" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (NSDictionary *m in media) {
            NSError *err = nil;
            NSString *uuidLower = [m[@"uuid"] lowercaseString];
            BOOL res = [formData appendPartWithFileURL:m[@"url"] name:uuidLower error:&err];
            NSLog(@"fomrDataRes: %d %@", res, err);
        }
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *success = responseObject[@"result"];
        BOOL res = true;
        NSError *err = nil;
        if ([success isEqualToString:@"success"]) {
            NSLog(@"upload done!");
        } else {
            NSLog(@"error during upload: %@", responseObject);
            res = false;
            NSInteger errorCode = [[responseObject[@"errors"]  firstObject][@"code"] integerValue];
            
            err = [NSError errorWithDomain:@"ohmage.upload" code:errorCode userInfo:nil];
        }
        
        completionBlock(res, err);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error! %@", error.description);
        completionBlock(false, error);
    }];
}

@end