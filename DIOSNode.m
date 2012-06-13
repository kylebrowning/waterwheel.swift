//  DIOSNode.m
//
// ***** BEGIN LICENSE BLOCK *****
// Version: MPL 1.1/GPL 2.0
//
// The contents of this file are subject to the Mozilla Public License Version
// 1.1 (the "License"); you may not use this file except in compliance with
// the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
// for the specific language governing rights and limitations under the
// License.
//
// The Original Code is Kyle Browning, released June 27, 2010.
//
// The Initial Developer of the Original Code is
// Kyle Browning
// Portions created by the Initial Developer are Copyright (C) 2010
// the Initial Developer. All Rights Reserved.
//
// Contributor(s):
//
// Alternatively, the contents of this file may be used under the terms of
// the GNU General Public License Version 2 or later (the "GPL"), in which
// case the provisions of the GPL are applicable instead of those above. If
// you wish to allow use of your version of this file only under the terms of
// the GPL and not to allow others to use your version of this file under the
// MPL, indicate your decision by deleting the provisions above and replacing
// them with the notice and other provisions required by the GPL. If you do
// not delete the provisions above, a recipient may use your version of this
// file under either the MPL or the GPL.
//
// ***** END LICENSE BLOCK *****

#import "DIOSNode.h"
#import "DIOSSession.h"
#import "AFJSONUtilities.h"
@implementation DIOSNode

#pragma mark nodeGets
+ (void)nodeGet:(NSDictionary *)node
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  [[DIOSSession sharedSession] getPath:[NSString stringWithFormat:@"%@/%@/%@", kDiosEndpoint, kDiosBaseNode, [node objectForKey:@"nid"]] 
                            parameters:nil 
                               success:success 
                               failure:failure];
}

#pragma mark nodeSave
+ (void)nodeSave:(NSDictionary *)node
                               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

  [[DIOSSession sharedSession] postPath:[NSString stringWithFormat:@"%@/%@", kDiosEndpoint, kDiosBaseNode] 
                             parameters:node
                                success:success 
                                failure:failure];
}

#pragma mark nodeUpdate
+ (void)nodeUpdate:(NSDictionary *)node
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  [[DIOSSession sharedSession] putPath:[NSString stringWithFormat:@"%@/%@/%@", kDiosEndpoint, kDiosBaseNode, [node objectForKey:@"nid"]] 
                            parameters:node 
                               success:success
                               failure:failure];
}

#pragma mark nodeDelete
+ (void)nodeDelete:(NSDictionary *)node
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  [[DIOSSession sharedSession] deletePath:[NSString stringWithFormat:@"%@/%@/%@", kDiosEndpoint, kDiosBaseNode, [node objectForKey:@"nid"]] 
                               parameters:node 
                                  success:success 
                                  failure:failure];
}
#pragma mark nodeIndex
//Simpler method if you didnt want to build the params :)
+ (void)nodeIndexWithPage:(NSString *)page fields:(NSString *)fields parameters:(NSArray *)parameteres pageSize:(NSString *)pageSize
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  NSMutableDictionary *nodeIndexDict = [NSMutableDictionary new];
  [nodeIndexDict setValue:page forKey:@"page"];
  [nodeIndexDict setValue:fields forKey:@"fields"];
  [nodeIndexDict setValue:parameteres forKey:@"parameters"];
  [nodeIndexDict setValue:pageSize forKey:@"pagesize"];  
  [self nodeIndex:nodeIndexDict success:success failure:failure];
}

+ (void)nodeIndex:(NSDictionary *)params
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  [[DIOSSession sharedSession] getPath:[NSString stringWithFormat:@"%@/%@", kDiosEndpoint, kDiosBaseNode] parameters:params success:success failure:failure];
}

#pragma mark nodeAttachFile
+ (void)nodeAttachFile:(NSDictionary *)params
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  NSMutableURLRequest *request = [[DIOSSession sharedSession] multipartFormRequestWithMethod:@"POST" path:[NSString stringWithFormat:@"%@/%@/%@/attach_file?field_name=%@", kDiosEndpoint, kDiosBaseNode, [params objectForKey:@"nid"], [params objectForKey:@"field_name"]] parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
    [formData appendPartWithFileData:[params objectForKey:@"fileData"] name:[params objectForKey:@"name"] fileName:[params objectForKey:@"fileName"] mimeType:[params objectForKey:@"mimetype"]];
  }];
  
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  [operation setUploadProgressBlock:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
    NSLog(@"Sent %qi of %qi bytes", totalBytesWritten, totalBytesExpectedToWrite);
  }];
  [operation setCompletionBlockWithSuccess:success failure:failure];
  [operation start];
}
@end
