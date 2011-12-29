//
//  OAuthClient.h
//  emacseo
//
//  Created by Terin Stock on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AFHTTPClient.h"

@interface OAuthClient : AFHTTPClient {
    BOOL authorized;
}

- (id)initWithBaseURL:(NSURL *)url consumerKey:(NSString *)key consumerSecret:(NSString *)secret;
- (id)initWithBaseURL:(NSURL *)url consumerKey:(NSString *)key consumerSecret:(NSString *)secret authToken:(NSString *)authToken authSecret:(NSString *)authSecret;
- (void)acquireOAuthRequestTokenPath:(NSString *)requestTokenPath success:(void (^)(NSString *token, NSString *secret))success failure:(void (^)(NSError *error))failure;
- (void)acquireOAuthAccessTokenPath:(NSString *)accessTokenPath verifier:(NSString *)verifier success:(void (^)(NSString *token, NSString *secret))success failure:(void (^)(NSError *error))failure;
- (NSString *)authHeaderForHTTPMethod:(NSString *)method URL:(NSURL *)url verifier:(NSString *)verifier parameters:(NSDictionary *)params;

@property (readonly, getter = isAuthorized) BOOL authorized;

@end
