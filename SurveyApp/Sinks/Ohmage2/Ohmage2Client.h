//
//  Ohmage2Sink.h
//  SurveyApp
//
//  Created by Christian Kellner on 14/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

#ifndef SurveyApp_Ohmage2Sink_h
#define SurveyApp_Ohmage2Sink_h

#include <Foundation/Foundation.h>
#include <AFNetworking.h>

@interface Ohmage2Client : AFHTTPSessionManager

+ (Ohmage2Client *)clientForURL:(NSURL *)url;
- (Ohmage2Client *)initWithURL:(NSURL *)url;

- (void)authenticateForUser:(NSString *)user withPassword:(NSString *)pass onCompletion:(void (^)(BOOL success, NSError *err))completionBlock;

- (void)uploadResponse:(NSDictionary *)response forSurvey:(NSDictionary *)survey withMedia:(NSArray *)media onCompletion:(void (^)(BOOL success, NSError *err)) completionBlock;

- (void)fetchCampaignForName:(NSString *)name onCompletion:(void (^)(NSDictionary *campaign, BOOL success, NSError *err)) completionBlock;

@end

#endif
