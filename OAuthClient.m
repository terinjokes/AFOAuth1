//
//  OAuthClient.m
//  emacseo
//
//  Created by Terin Stock on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OAuthClient.h"
#import "OAuthCore.h"
#import "OAuth+Additions.h"

@interface OAuthClient ()

@property (readwrite,copy) NSString *consumerKey;
@property (readwrite,copy) NSString *consumerSecret;
@property (readwrite,copy) NSString *oauthToken;
@property (readwrite,copy) NSString *oauthSecret;

@property (readwrite, getter = isAuthorized) BOOL authorized;

@end

@implementation OAuthClient {
    NSString *consumerKey;
    NSString *consumerSecret;
    
    NSString *oauthToken;
    NSString *oauthSecret;
}

@synthesize authorized;
@synthesize consumerKey;
@synthesize consumerSecret;
@synthesize oauthToken;
@synthesize oauthSecret;

- (id)initWithBaseURL:(NSURL *)url
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithBaseURL:(NSURL *)url consumerKey:(NSString *)key consumerSecret:(NSString *)secret
{
    return [self initWithBaseURL:url consumerKey:key consumerSecret:secret authToken:nil authSecret:nil];
}

- (id)initWithBaseURL:(NSURL *)url consumerKey:(NSString *)key consumerSecret:(NSString *)secret authToken:(NSString *)authToken authSecret:(NSString *)authSecret
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self setConsumerKey:key];
    [self setConsumerSecret:secret];
    if (authToken) {
        [self setOauthToken:authToken];
    }
    
    if (authSecret) {
        [self setOauthSecret:authSecret];
    }
    
    return self;
}

- (NSString *)description
{
    NSString *description = [super description];
    return [description stringByAppendingFormat:@"{consumerKey: %@; consumerSecret: %@; oauthToken: %@; oauthSecret: %@}",
            [self consumerKey], [self consumerSecret], [self oauthToken], [self oauthSecret]];
}

- (void)acquireOAuthRequestTokenPath:(NSString *)requestTokenPath success:(void (^)(NSString *token, NSString *secret))success failure:(void (^)(NSError *error))failure
{
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseURL], requestTokenPath]];
    NSString *authHeader = [self authHeaderForHTTPMethod:@"POST" URL:requestURL verifier:nil parameters:nil];
    [self setDefaultHeader:@"Authorization" value:authHeader];
    [self postPath:requestTokenPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *responseDictionary = [NSURL ab_parseURLQueryString:responseString];
        [self setOauthToken:[responseDictionary valueForKey:@"oauth_token"]];
        [self setOauthSecret:[responseDictionary valueForKey:@"oauth_token_secret"]];
        if (success) {
            success([self oauthToken], [self oauthSecret]);
        }
        [responseString release];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)acquireOAuthAccessTokenPath:(NSString *)accessTokenPath verifier:(NSString *)verifier success:(void (^)(NSString *token, NSString *secret))success failure:(void (^)(NSError *error))failure
{
    NSURL *accessURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseURL], accessTokenPath]];
    NSString *authHeader = [self authHeaderForHTTPMethod:@"POST" URL:accessURL verifier:verifier parameters:nil];
    [self setDefaultHeader:@"Authorization" value:authHeader];
    [self postPath:accessTokenPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *responseDictionary = [NSURL ab_parseURLQueryString:responseString];
        [self setOauthToken:[responseDictionary valueForKey:@"oauth_token"]];
        [self setOauthSecret:[responseDictionary valueForKey:@"oauth_token_secret"]];
        [self setAuthorized:YES];
        NSLog(@"%@", responseDictionary);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (NSString *)authHeaderForHTTPMethod:(NSString *)method URL:(NSURL *)url verifier:(NSString *)verifier parameters:(NSDictionary *)params
{
    NSString *path = [url path];
    NSURL *oauthURL = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(params, self.stringEncoding)]];
    return OAuthorizationHeader(oauthURL, method, nil, [self consumerKey], [self consumerSecret], verifier, [self oauthToken], [self oauthSecret]);
}

@end
