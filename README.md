###Drupal iOS SDK - Connect your iOS/OS X app to Drupal
-----
###### built by [Kyle Browning](http://kylebrowning.com)
####Introduction
----

[![Join the chat at https://gitter.im/kylebrowning/drupal-ios-sdk](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/kylebrowning/drupal-ios-sdk?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
The Drupal iOS SDK is a standard set of libraries for communicating to Drupal from any iOS device. Its extremely simple, and is basically a wrapper for AFNetworking. It combines the most used commands to communicate with Drupal and handles session managment for you(minus oauth)

### Requirements

| DIOS Version | Drupal Version  | Min iOS Target  |                                   Notes                                   |
|:--------------------:|:---------------------------:|:----------------------------:|:-------------------------------------------------------------------------:|
|          [3.x](https://github.com/kylebrowning/drupal-ios-sdk/tree/master)         |            Drupal 8            |           iOS 7.0          |  |
|          [2.x](https://github.com/kylebrowning/drupal-ios-sdk/tree/2.x)         |            Drupal 6-7            |         iOS 5.0        |        Requires [Services](http://drupal.org/project/services) module                                                                    |


####Installation
----
Create a pod file with (this will keep you on the 3.0 releases which is Drupal 8 specific) 
```
 pod 'drupal-ios-sdk', '~> 3.0'
```
Then run 
```
pod install
```


####Configuration
----
In Drupal 8 things are a bit different, but much easier.

####First steps
```obj-c
 DIOSSession *sharedSession = [DIOSSession sharedSession];
 [sharedSession setBaseURL:[NSURL URLWithString:@"http://d8"]];
 [sharedSession setBasicAuthCredsWithUsername:@"admin" andPassword:@"pass"];
```
Currently 3.x only supports basic auth but will support oAuth soon

####Quick Examples
----
```obj-c
 //create new user
 NSDictionary *user = @{@"name":@[@{@"value":@"username"}],@"mail":@[@{@"value":@"email@gmail.com"}],@"pass":@[@{@"value":@"passw0rd"}]};
 [DIOSUser createUserWithParams:user success:nil failure:nil];

 //update existing node
 NSDictionary *node = @{@"uid":@[@{@"target_id":@"1"} ],@"body":@[@{@"value":@"Updated BOdy ",@"format":@"full_html"}],@"title":@[@{@"value":@"Updated Title"}]};
 [DIOSNode patchNodeWithID:@"12" params:node type:@"page" success:nil failure:nil];

 //create new comment
 NSDictionary *parameters = @{@"subject":@[@{@"value":@"comment title"}],@"comment_body":@[@{@"value":@"a new body",@"format":@"basic_html"}]};
 [DIOSComment createCommentWithParams:parameters relationID:@"7" type:@"comment" success:nil failure:nil];
 
 //get a user
 [DIOSUser getUserWithID:@"1" success:nil failure:nil];
 
 //delete a node
 [DIOSNode deleteNodeWithID:@"13" success:nil failure:nil];
```
####Extras
----
[Drupal iOS SDK Addons](https://github.com/utneon/drupal-ios-sdk-addons)



####OAuth
--------------------
Coming soon

####Troubleshooting
----------
If you are getting Forbidden, you probably havnt setup your permissions.


####Questions
----------
Checkout the Issue queue, or email me
Email kylebrowning@me.com
