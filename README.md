# Extremely Experimental
 
 This is a simple OAuth 1.0 implementation using [AFNetworking](https://github.com/AFNetworking/AFNetworking) by Gowalla and the very nice [OAuthCore](https://github.com/terinjokes/OAuthCore) by Loren Brichter. It's fairly experimental, so unless you like hacking, I wouldn't use it in production.
 
## Instructions
 
You'll want to add AFOAuth1 and it's dependencies to your project. Then you can do something like the following:

``` objective-c
OAuthClient *oClient = [[OAuthClient alloc] initWithBaseURL:kMyOAuthBaseURL consumerKey:kMyOAuthConsumerKey consumerSecret:kMyOAuthConsumerSecret];
[oClient acquireOAuthRequestTokenPath:@"request_token" success:^(NSString *token, NSString *secret) {
	NSString *verifier = MyGetOAuthVerifierBySomeMeansCurrentlyNotImplementedByThisProject(token);
	[oClient acquireOAuthAccessTokenPath:@"access_token" verifier:verifier success:^(NSString *token, NSString *secret) {
		//oClient is now authenticated and can be used to create the Authorization header for AFNetworking.
		NSString *authheader = [oClient authHeaderForHTTPMethod:@"POST" URL:@"http://example.com/api/verify" verifier:nil parameters:nil];
		[myAFNetworkingInstance setDefaultHeader:@"Authorization" value:authHeader];
		[myAFNetworkingInstance getPath:@"verifiyTokens" parameters:nil success:nil failure:nil];
	}]
} failure:^(NSError *error) {
	NSLog(@"%@", error);
}];
```

## Contact

Terin Stock

- http://github.com/terinjokes
- http://twitter.com/terinjokes
- terin@terinstock.com