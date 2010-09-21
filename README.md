[Drupal iOS SDK](http://workhabit.com) - Connect your iOS/OS X app to Drupal
================================

What you need to get started
---------------------------------------
* This library
* the following frameworks
  - UIKit.Framework
  - CoreGraphics.framework
  - CFNetwork.framework
  - libz.1.2.3.dylib
  - SystemConfiguration.framework
  - MobileCoreServices.framework
* Drupal 6.0 setup with [PLIST Server](http://drupal.org/project/plist_server)
* Update DIOSConnect.h with the correct API_KEYS SERVICES_URL and DOMAIN

Demo Code
--------------
    DIOSConnect *session = [[DIOSConnect alloc] init];
    
    [session loginWithUsername:[username text] andPassword:[password text]];
    
    NSDictionary *result = [[[delegate session] connResult] objectForKey:@"#data"];
    if([result objectForKey:@"#error"]) {
      UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:[result objectForKey:@"#message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
      [alert show];
    } else {
      //Do some login Stuff
    }
    
    DIOSViews *views = [[DIOSViews alloc] initWithUserInfo:[session userInfo] andSessId:[session sessid]];
    [views initViews];
    [views addParam:@"test" forKey:@"view_name"];
    [views addParam:@"block_1" forKey:@"display_id"];
    [views runMethod];

    DIOSNode *node = [[DIOSNode alloc] init];
    [node setType:@"story"];
    [node setTitle:[mTitle text]];
    [node setBody:[mBody text]];
    [node nodeSave];


    DIOSComment *commentConnect = [[DIOSComment alloc] initWithUserInfo:[session userInfo] andSessId:[session sessid]];
    [commentConnect getComments:nid andStart:start andCount:count];

Troubleshooting
----------
If you are getting Access denied, or API Key not valid, double check that your key settings are setup correctly at admin/build/services/keys and double check that permissions are correct for your user and anonymous.

Questions
----------
Email kyle@workhabit.com