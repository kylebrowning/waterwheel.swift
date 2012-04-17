Drupal iOS SDK - Connect your iOS/OS X app to Drupal
================================
What you need to know
================================
This fork has just a few differences with the forked branch.

================================
Differences between original branch and this fork
================================

    DIOSView *view = [[DIOSView alloc] init];
	NSMutableDictionary *tempDict = [NSMutableDictionary new];
    [tempDict setValue:@"users" forKey:@"view_name"];
	[tempDict setValue:@"page_1" forKey:@"display_id"];
	[tempDict setValue:@"20" forKey:@"limit"];
	[tempDict setValue:@"10" forKey:@"offset"];
	[tempDict setValue:@"&picture=1" forKey:@"other_params"];

This example loads the view "users" with display_id "page_1", shows "20" records starting at offset "10" and using the exposed filter "picture" to show only users with picture.
To properly use "other_params" you have to add "&field_name=value" for each exposed filter you need to set.