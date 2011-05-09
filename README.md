[Drupal iOS SDK](http://workhabit.com) - Connect your iOS/OS X app to Drupal
================================

What you need to get started
---------------------------------------
####XCode
* This library
* the following frameworks
  - UIKit.Framework
  - CoreGraphics.framework
  - CFNetwork.framework
  - libz.1.2.3.dylib
  - SystemConfiguration.framework
  - MobileCoreServices.framework
  * ASIHTTPRequest which can be found [here](http://github.com/pokeb/asi-http-request)
* Update DIOSConfig.h with the correct API_KEYS SERVICES_URL and DOMAIN (make sure you checkout the drupal-ios-sdk branch for your version of drupal eg. 6.x-2.x, 6.x-3.x or 7.x-3.x)

####Drupal 6
* [PLIST Server](http://drupal.org/project/plist_server)
* [services 2.2](http://drupal.org/project/services) (3.x is becoming more stable every day, but still use at your own risk)

####Drupal 7 (kind of stable, not yet in Code freeze)
* [Services](http://github.com/kylebrowning/services)
* [REST SERVER PLIST](http://drupal.org/project/rest_server_plist)

Demo Code (Code is pulled from [http://github.com/workhabitinc/drupal-ios-sdk-example](http://github.com/workhabitinc/drupal-ios-sdk-example))
======================
Demo Setup (Services 3.x) http://vimeo.com/22635252
====================== 
Session
--------------------
    DIOSConnect *session = [[DIOSConnect alloc] init];
    
    
Views
-----------------------
    DIOSViews *views = [[DIOSViews alloc] initWithSession:session];
    [views initViews];
    [views addParam:[viewNameField text] forKey:@"view_name"];
    [views addParam:[NSArray arrayWithObjects:[argsField text], nil] forKey:@"args"];
    [views addParam:[displayNameField text] forKey:@"display_id"];
    [views runMethod];
    [views release];

Node
-----------------------
#### Add
    DIOSNode *node = [[DIOSNode alloc] initWithSession:session];
    NSMutableDictionary *nodeData = [[NSMutableDictionary alloc] init];
    [nodeData setObject:[bodySaveField text] forKey:@"body"];
    [nodeData setObject:[typeSaveField text] forKey:@"type"];
    [nodeData setObject:[titleSaveField text] forKey:@"title"];
    [nodeData setObject:[nidSaveField text] forKey:@"nid"];
    [nodeData setObject:@"now" forKey:@"date"];
    [nodeData setObject:@"1" forKey:@"status"];
    [nodeData setObject:[[session userInfo] objectForKey:@"name"] forKey:@"name"];
    [node nodeSave:nodeData];
    [node release];
#### Delete
    DIOSNode *node = [[DIOSNode alloc] initWithSession:session];
    [node nodeDelete:[nidDeleteField text]];
    [node release];
    
#### Get
    DIOSNode *node = [[DIOSNode alloc] initWithSession:session];
    [node nodeGet:[nidGetField text]];
    [node release]; 

Comment
-----------------------
#### Add
    DIOSComment *comment = [[DIOSComment alloc] initWithSession:session];
    [comment addComment:[nidCommentAddField text] subject:[subjectCommentAddField text] body:[bodyCommentAddField text]];
    [comment release]; 
#### Get  
    DIOSComment *comment = [[DIOSComment alloc] initWithSession:session];
    [comment getComment:[nidCommentGetField text]];
    [comment release]; 
  
User
-----------------------
#### Login 
    DIOSUser *user = [[DIOSUser alloc] initWithSession:session];
    [user loginWithUsername:[usernameLoginField text] andPassword:[passwordLoginField text]];
    [user release];
#### Logout
    DIOSUser *user = [[DIOSUser alloc] initWithSession:session];
    [user logout];
    [user release];
#### Save    
    DIOSUser *user = [[DIOSUser alloc] initWithSession:session];
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    [userData setObject:[usernameSaveField text] forKey:@"name"];
    [userData setObject:[passwordSaveField text] forKey:@"pass"];
    [userData setObject:[emailSaveField text] forKey:@"mail"];
    [userData setObject:[uidSaveField text] forKey:@"uid"];
    [user userSave:userData];
    [user release];
#### Get    
    DIOSUser *user = [[DIOSUser alloc] initWithSession:session];
    [user userGet:[uidGetField text]];
    [user release];

#### Delete    
    DIOSUser *user = [[DIOSUser alloc] initWithSession:session];
    [user userDelete:[uidDeleteField text]];
    [user release];
    
Taxonomy 
------------------------

    - (NSMutableArray *) getTreeForVid:(NSString*)vid {
      DIOSTaxonomy *taxonomy = [[DIOSTaxonomy alloc] initWithSession:session];
      return [[taxonomy getTree:vid] objectForKey:@"#data"];
    }

    - (NSMutableArray *) getNodesForTid:(NSString*)tid {
      DIOSTaxonomy *taxonomy = [[DIOSTaxonomy alloc] initWithSession:session];
      
      return [[taxonomy selectNodes:tid] objectForKey:@"#data"];
    }
  
Troubleshooting
----------
If you are getting Access denied, or API Key not valid, double check that your key settings are setup correctly at admin/build/services/keys and double check that permissions are correct for your user and anonymous.

X service doesnt exist in Drupal iOS SDK
----------
Thats ok, just subclass DIOSConnect and follow the model of tthe other DIOS classes. If its a core services Class and I have not added it in, please help us all out and contribute it by by doing a pull request. Thanks!

Questions
----------
Email kyle@workhabit.com
