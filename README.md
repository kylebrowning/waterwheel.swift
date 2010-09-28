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
* ASIHTTPRequest which can be found [here](http://github.com/pokeb/asi-http-request)
* Update DIOSConnect.h with the correct API_KEYS SERVICES_URL and DOMAIN

Demo Code
======================
Session
--------------------
    DIOSConnect *session = [[DIOSConnect alloc] init];
    
    
Views
-----------------------
    - (NSMutableArray *) getViewDataWithName:(NSString*)viewName {
      DIOSViews *views = [[DIOSViews alloc] initWithSession:session];
      [views initViews];
      [views addParam:viewName forKey:@"view_name"];
      [views addParam:@"Defaults" forKey:@"display_id"];
      [views runMethod];
      id object;
      NSEnumerator *e = [[[views connResult] objectForKey:@"#data"] objectEnumerator];
      NSMutableArray *newArray = [[NSMutableArray alloc] init];
      while (object = [e nextObject]) {
        [newArray addObject:object];
      }
      return newArray;
    }

Node
-----------------------
    DIOSNode *node = [[DIOSNode alloc] initWithSession:session];
    [node setType:@"story"];
    [node setTitle:[mTitle text]];
    [node setBody:[mBody text]];
    [node nodeSave];


Comment
-----------------------
    - (NSMutableArray *) getCommentsForNode:(NSString*)nid {
      DIOSComment *comments = [[DIOSComment alloc] initWithSession:session];
      [comments getComments:nid andStart:@"0" andCount:@"0"];
      id object;
      NSEnumerator *e = [[[comments connResult] objectForKey:@"#data"] objectEnumerator];
      NSMutableArray *newArray = [[NSMutableArray alloc] init];
      while (object = [e nextObject]) {
        [newArray addObject:object];
      }
      return newArray;
    }
  
    DIOSComment *comment = [[DIOSComment alloc] initWithSession:[delegate session]];
    [comment addComment:[[nodeInfo objectForKey:@"nid"] stringValue] subject:[subject text] body:[body text]];
  
  
User
-----------------------
    DIOSUser *user = [[DIOSUser alloc] initWithSession:session];
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    [userData setObject:@"kyle2" forKey:@"name"];
    [userData setObject:@"password" forKey:@"pass"];
    [userData setObject:@"anemail@anyemail.com" forKey:@"mail"];
    NSMutableDictionary *roles = [[NSMutableDictionary alloc] init];
    [roles setObject:@"testRole" forKey:@"3"];
    [userData setObject:[user serializedObject:roles] forKey:@"roles"];
    [user userSave:userData];

    DIOSUser *user = [[DIOSUser alloc] initWithSession:session];
    [user userDelete:@"14"];
    
    [user loginWithUsername:[username text] andPassword:[password text]];
    
    NSDictionary *result = [[user connResult] objectForKey:@"#data"];
    if([result objectForKey:@"#error"]) {
      UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:[result objectForKey:@"#message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
      [alert show];
    } else {
      //Do some login Stuff
    }
    
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

Questions
----------
Email kyle@workhabit.com
