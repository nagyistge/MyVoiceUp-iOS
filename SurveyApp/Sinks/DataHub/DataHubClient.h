//
//  DataHubClient.h
//  SurveyApp
//
//  Created by Christian Kellner on 16/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

#ifndef SurveyApp_DataHubClient_h
#define SurveyApp_DataHubClient_h
#include <AFNetworking.h>

@interface DHClient: NSObject

-(DHClient *) initWithURL:(NSURL *)url;

-(void) registerUser:(NSString *)username withEmail:(NSString *)email andPassword:(NSString *)password onSuccess:(void (^)(void)) successCallback onFailure:(void (^)(NSError *err)) failureCallback;

-(void) loginForUser:(NSString *)user withPassword:(NSString *)pass onSuccess:(void (^)(void)) successCallback onFailure:(void (^)(NSError *err)) failureCallback;
;

-(void) uploadFile:(NSURL *)localeFile forUser:(NSString *)user toRepository:(NSString *)repo onSuccess:(void (^)(void)) successCallback onFailure:(void (^)(NSError *err)) failureCallback;

-(void) uploadResponse:(NSDictionary *)respones forUser:(NSString *)user toTable:(NSString *)table inRepository:(NSString *)repo onSuccess:(void (^)(void)) successCallback onFailure:(void (^)(NSError *err)) failureCallback;

-(void) createRepo:(NSString *)repo andShareWith:(NSString *)user onSuccess:(void (^)(void)) successCallback onFailure:(void (^)(NSError *err)) failureCallback;

-(void) createTable:(NSString *)table  inRepo:(NSString *)repo withSchema:(NSString *)schema onSuccess:(void (^)(void)) successCallback onFailure:(void (^)(NSError *err)) failureCallback;

@end


#endif
