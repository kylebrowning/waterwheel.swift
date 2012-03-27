Drupal iOS SDK - Connect your iOS/OS X app to Drupal
================================
What you need to know
================================
The Drupal iOS SDK is a standard set of libraries for communicating to Drupal from any iOS device. Its extremely simple.
If you wanted to get a node you can do so by instantiating a DIOSNode Object, creating an 
NSDictionairy and running the nodeGet method.  Heres an example.

```obj-c
    DIOSNode *node = [[DIOSNode alloc] init];
    NSMutableDictionary *nodeData = [NSMutableDictionary new];
    [nodeData setValue:@"12" forKey:@"nid"];
    [node nodeGet:nodeData success:^(AFHTTPRequestOperation *operation, id responseObject) {
      //Do Something with the responseObject
      NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      //we failed, uh-oh lets error log this.
      NSLog(@"%@,  %@", [error localizedDescription], [operation responseString]);    
    }];
    
```
For every DIOS Object you make, any method calls that are available to you use blocks. 
This allows us to define what happens when we have a request that fails or succeeds. 
If the request were successfully we will something like this.

    {"vid":"9","uid":"57","title":"testtitle","log":"","status":"1".......
    
However if it failed, the error might look like this.

    Expected status code in (200-299), got 404,  "Node 5 could not be found"
    
What you need to get started
================================
* This library :) 
* AFNetwork which can be found [here](https://github.com/AFNetworking/AFNetworking)
* Be sure to follow the AFNetworking installation guide.
* Update Settings.h with the correct correct url and endpoints)
* [Services](http://github.com/kylebrowning/services)

A couple of things to note
================================
Branches
--------------------
6.x-2.x 6.x-3.x and 7.x-3.x are all going to be moved to a *DEPRECATED* version of their branch.
The new dev branch will be the become the new master and as things are added, versions will be tagged and published.
master will always be the latest and greatest for the moost up to date version of everything(Services, Drupal, Services Api, DIOS).

Tags are in this format
`2.1-1.0` Which breaks down as, DIOSVersion 2.1, Services Api Version 1.0

Branches are in this format
`2.x-1.x`

OAuth
--------------------
its coming.

<!-- 
Demo Code (Code is pulled from [http://github.com/workhabitinc/drupal-ios-sdk-example](http://github.com/workhabitinc/drupal-ios-sdk-example))
======================
Demo Setup (Services 3.x) http://vimeo.com/22635252 -->
Documentation
===============
[Can be found here](https://github.com/workhabitinc/drupal-ios-sdk/wiki/drupal-ios-sdk-2.0)

Troubleshooting
----------
If you are getting Access denied, or API Key not valid, double check that your key settings are setup correctly at admin/build/services/keys and double check that permissions are correct for your user and anonymous.

X service doesnt exist in Drupal iOS SDK
----------
You no longer really need to subclass any existing DIOS classes, unless you want to override.
`[DIOSSession shared]` ensures that session information is stored for as long as the cookies are valid
If you do want to make your own object, just follow the pattern in the other files and everything should work fine.
Use the issue queue here on github if you have questions.

Questions
----------
CHeckout the Issue queue, or email me
Email kyle@workhabit.com
