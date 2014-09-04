Drupal iOS SDK - Connect your iOS/OS X app to Drupal
================================
##### built by [Kyle Browning](http://kylebrowning.com) and modified by Tom Kremer to be AFNetworking 2.0.X compatible.
Introduction
================================
The Drupal iOS SDK is a standard set of libraries for communicating to Drupal from any iOS device. Its extremely simple, and is basically a wrapper for AFNetworking. It combines the most used commands to communicate with services and handles session managment for you(but it doesnt store passwords or persist CSRF/oAUTH tokens, you must do that)

Installation
================================
Create a pod file with (this will keep you on the 2.1 releases) 
```
pod 'drupal-ios-sdk', '~> 2.1'
```
Then run `pod install`

Configuration
================================
You have *three* options for getting started, these will depend on how you plan on using DIOS


##Option #1
=
1. Create a file named `dios.plist` and place it in your workspace/project. Copy it from dios_example.plist

2. Edit dios.plist and change the siteUrl and endpoint to be values that pertain to you.
 
3. Add `[DIOSSession setupDios]` line to your AppDelegates didFinishLaunching method.

4. Begin Coding!

 
##Option #2
=
1. In your AppDelegate's didFinishLaunching method add `[DIOSSession setupDiosWithURL:@"http://local.drupal.com"];`

2. Begin Coding!

##Option #3 (pertains only to Oauth)
=
1. In your AppDelegate's didFinishLaunching method add `[DIOSSession setupDiosWithURL:@"http://local.drupal.com" andConsumerKey:@"yTkyapFEPAdjkW7G2euvJHhmmsURaYJP" andConsumerSecret:@"ZzJymFtvgCbXwFeEhivtF67M5Pcj4NwJ"];;`

2. Begin Coding!

Quick Example
===============================
```obj-c
    NSMutableDictionary *nodeData = [NSMutableDictionary new];
    [nodeData setValue:@"12" forKey:@"nid"];
    [DIOSNode nodeGet:nodeData success:^(AFHTTPRequestOperation *operation, id responseObject) {
      //Do Something with the responseObject
      [self setNodeData:responseObject];
      [self setTitle:[responseObject objectForKey:@"title"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      [self alertUser:@"I failed to fetch the node"];   
    }];
    
```
For every DIOS call you make, any method calls that are available to you use blocks.
All calls are logged to the console whether sucessfull or failed when in Debug
If the request was successful the result would be something like this:

    {"vid":"9","uid":"57","title":"testtitle","log":"","status":"1".......
    
## Requirements

| DIOS Version | Drupal Version  | Min iOS Target  |                                   Notes                                   |
|:--------------------:|:---------------------------:|:----------------------------:|:-------------------------------------------------------------------------:|
|          [3.x](https://github.com/kylebrowning/drupal-ios-sdk/tree/master)         |            Drupal 8            |           iOS 7.0          | . |
|          [2.x](https://github.com/kylebrowning/drupal-ios-sdk/tree/2.x)         |            Drupal 6-7            |         iOS 5.0        |                                                                           |
Extras
===============================
[Drupal iOS SDK Addons](https://github.com/utneon/drupal-ios-sdk-addons)

Deprecations
--------------------
6.x-2.x 6.x-3.x and 7.x-3.x have all been moved to a  *DEPRECATED* version of their branch.
The new dev branch will be the become the new master and as things are added, versions will be tagged and published.
master will always be the latest and greatest for the most up to date version of everything(Services, Drupal, Services Api, DIOS). Use `pod update` to get the latest, and if you want to upgrade an API version change your podfile to reflect that

OAuth
--------------------
If you want to use oAuth theres only one thing you need to do for 2-legged
```obj-c
[DIOSSession setupDiosWithURL:@"http://local.drupal.com" andConsumerKey:@"yTkyapFEPAdjkW7G2euvJHhmmsURaYJP" andConsumerSecret:@"ZzJymFtvgCbXwFeEhivtF67M5Pcj4NwJ"];
```
This will create your shared session with the baseURL and attach your consumer key and secret.

3-legged requires that you get some request tokens, and convert them into access tokens.
DIOS provides methods to do this, as an Example, this code will grab some request tokens and load a webview to be displayed

```obj-c
  [DIOSSession getRequestTokensWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    requestTokens = [NSMutableDictionary new];
    NSArray *arr = [operation.responseString componentsSeparatedByCharactersInSet:
                    [NSCharacterSet characterSetWithCharactersInString:@"=&"]];
    if([arr count] == 4) {
      [requestTokens setObject:[arr objectAtIndex:1] forKey:[arr objectAtIndex:0]];
      [requestTokens setObject:[arr objectAtIndex:3] forKey:[arr objectAtIndex:2]];
    } else {
      NSLog(@"failed ahh");
    }
    [_window addSubview:oauthWebView];
    NSString *urlToLoad = [NSString stringWithFormat:@"%@/oauth/authorize?%@", [[DIOSSession sharedSession] baseURL], operation.responseString];
    NSURL *url = [NSURL URLWithString:urlToLoad];
    NSLog(@"loading url :%@", urlToLoad);
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];

    //Load the request in the UIWebView.
    [oauthWebView loadRequest:requestObj];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"failed");
  }];
```

If you want to get back a notificaiton when the request tokens have been authorized youll need to register a URL
for your application and make sure it is defined in your oAuth consumer which you created on your Drupal website

Again, another example here, we registered our app url and this method gets called when it does.

```obj-c
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
  //If our request tokens were validated, this will get called.
  if ([[url absoluteString] rangeOfString:[requestTokens objectForKey:@"oauth_token"]].location != NSNotFound) {
    [DIOSSession getAccessTokensWithRequestTokens:requestTokens success:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSArray *arr = [operation.responseString componentsSeparatedByCharactersInSet:
                      [NSCharacterSet characterSetWithCharactersInString:@"=&"]];
      if([arr count] == 4) {
        //Lets set our access tokens now
        [[DIOSSession sharedSession] setAccessToken:[arr objectAtIndex:1] secret:[arr objectAtIndex:3]];
        NSDictionary *node = [NSDictionary dictionaryWithObject:@"1" forKey:@"nid"];
        [DIOSNode nodeGet:node success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"%@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"%@", [error localizedDescription]);
        }];
      } else {
        NSLog(@"failed ahh");
      }
      NSLog(@"successfully added accessTokens");
      [oauthWebView removeFromSuperview];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"getting access tokens failed");
      [oauthWebView removeFromSuperview];
    }];
  }
  return YES;
}
```
Documentation
-----------
[Can be found here](https://github.com/kylebrowning/drupal-ios-sdk/wiki/drupal-ios-sdk-2.0)

Troubleshooting
----------
If you are getting Access denied, or API Key not valid, double check that your key settings are setup correctly at admin/build/services/keys and double check that permissions are correct for your user and anonymous.

X service doesnt exist in Drupal iOS SDK
----------
You no longer really need to subclass any existing DIOS classes, unless you want to override.
`[DIOSSession sharedSession]` ensures that session information is stored for as long as the cookies are valid
If you do want to make your own object, just follow the pattern in the other files and everything should work fine.
Use the issue queue here on github if you have questions. An addon library is [here](https://github.com/utneon/drupal-ios-sdk-addons)

Questions
----------
Checkout the Issue queue, or email me
Email kylebrowning@me.com
