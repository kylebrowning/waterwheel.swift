
Drupal iOS SDK - Connect your iOS/OS X app to Drupal
================================
What you need to know
================================
The Drupal iOS SDK is a standard set of libraries for communicating to Drupal from any iOS device. Its extremely simple.
If you wanted to get a node and actually see the response you can do so by setting the delegate to yourself, (or any object you want)
As long as it conforms to `<DIOSNodeDelegate>` you can see the response whether it is successful or not. Heres an example.

```obj-c
    DIOSNode *node = [[DIOSNode alloc] initWithDelegate:self];
    NSMutableDictionary *nodeData = [NSMutableDictionary new];
    [nodeData setValue:@"12" forKey:@"nid"];
    [node nodeGet:nodeData];
    
```
Once that nodeGet: method is called it will fetch the data from your Services 3.x enabled website. When the call is finished it will 
call the method below and provide you with a couple of peices of information. You can see which methods certain DIOS classes respond to
by examining their respective header files, or going to the section you are curious about in this README. There names
should be pretty self-explanatory. 

```obj-c
    - (void)nodeGetDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error {
      [[[DIOSSession sharedSession] delegate] callDidFinish:status operation:operation response:response error:error];
    }
```    
There is a method called `callDidFinish:operation:response:error` from `[DIOSSession sharedSession]` that will just dump the contents of the requests and responses and errors
This is a snippet from what that method prints out.

    {"vid":"9","uid":"57","title":"testtitle","log":"","status":"1".......
    
A more practical example might be

```obj-c
    - (void)nodeSaveDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error {
        if([response objectForKey:"nid"]) {
            //looks like our node was saved, lets stop our progress indicators and show the user whatever we need.
        }
    }
```
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
`2.1-7-1.0` WHich breaks down as, DIOSVersion 2.1, Drupal version 7, Services Api Version 1.0

Branches are in this format
`2.x-7-1.x`

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
