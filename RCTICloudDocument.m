//
//  RCTICloudDocuments.m
//
//  Created by watert on 15/10/27.
//  Copyright © 2015年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCTBridgeModule.h"
#import "RCTUtils.h"

@interface RCTICloudDocuments : NSObject <RCTBridgeModule>

@end

@implementation RCTICloudDocuments


RCT_EXPORT_MODULE();


/*
 let Documents = React.NativeModules.ICloudDocuments;
 Documents.attributesOfItemAtPath(path,(err,attrs)=>{});
 Documents.contentsAtPath(manifest,(err,contents)=>{});
 Documents.contentsOfDirectoryAtPath(path, (err, files)=>{});
 Documents.copyFileToICloud(manifest,(err,attrs)=>{});
 Documents.documentPath((path)=>{});
 Documents.iCloudDocumentPath((path)=>{});
 Documents.getICloudDocumentURLByLocalPath(localPath,(iCloudPath)=>{});
 Documents.getICloudToken((token)=>{});
 Documents.moveFileToICloud(localPath,(err, result)=>{});
 Documents.removeICloudFile(iCloudPath,(err, isSuccess)=>{});

 */


#pragma mark - replace file to or from iCloud

- (NSURL *)replaceItemFrom: (NSURL *)urlFrom to:(NSURL *)urlTo {
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  NSURL *tmpFileURL = [NSURL URLWithString: [self createTempFile:urlFrom]];
  [fileManager copyItemAtURL:tmpFileURL toURL:urlTo error:nil];

  NSURL *resultingURL;
  [fileManager replaceItemAtURL:urlTo withItemAtURL:tmpFileURL backupItemName:nil options:0 resultingItemURL:&resultingURL error:nil];
  if([resultingURL.absoluteString isEqualToString:urlTo.absoluteString]){
    return resultingURL;
  }else {
    return nil;
  }
}
RCT_EXPORT_METHOD(replaceFileToICloud:(NSString *)localPath :(RCTResponseSenderBlock)callback)
{
  //  NSURL *docUrl = [self getICloudDocumentURL];
  NSURL *sourceURL = [NSURL fileURLWithPath:localPath];
  NSURL *destinationURL = [self getICloudDocumentURLByLocalPath:localPath];


  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self createDirectionOfFileURL:destinationURL];
    NSURL *resultingURL = [self replaceItemFrom:sourceURL to:destinationURL];
    if(resultingURL==nil){
      callback(@[@"URL unexpectly changed during replacing", [resultingURL absoluteString]]);
    }else {
      callback(@[@NO, [resultingURL absoluteString]]);
    }
  });
}
RCT_EXPORT_METHOD(replaceFileFromICloud:(NSString *)iCloudPath :(RCTResponseSenderBlock)callback)
{
  //  NSURL *docUrl = [self getICloudDocumentURL];
  NSURL *sourceURL = [NSURL fileURLWithPath:iCloudPath];
  NSURL *destinationURL = [self getDocumentURLByICloudPath:iCloudPath];

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self createDirectionOfFileURL:destinationURL];
    NSURL *resultingURL = [self replaceItemFrom:sourceURL to:destinationURL];
    if(resultingURL==nil){
      callback(@[@"URL unexpectly changed during replacing", [resultingURL absoluteString]]);
    }else {
      callback(@[@NO, [resultingURL absoluteString]]);
    }
  });
}


#pragma mark - copyFile to or from iCloud
RCT_EXPORT_METHOD(copyFileToICloud:(NSString *)pathToUpload :(RCTResponseSenderBlock)callback)
{
  //  NSURL *docUrl = [self getICloudDocumentURL];
  NSURL *sourceURL = [NSURL fileURLWithPath:pathToUpload];
  NSURL *destinationURL = [self getICloudDocumentURLByLocalPath:pathToUpload];


  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [self createDirectionOfFileURL:destinationURL];
    NSError *err = nil;
    [fileManager copyItemAtURL:sourceURL toURL:destinationURL error:&err];

    if(err==nil) {
      callback(@[@NO, [destinationURL absoluteString]]);
    }else {
      callback(@[ [err localizedDescription] ]);
    }
  });
}
RCT_EXPORT_METHOD(copyFileFromICloud:(NSString *)path :(RCTResponseSenderBlock)callback)
{
  NSURL *destinationURL = [self getDocumentURLByICloudPath:path];
  NSURL *sourceURL = [NSURL fileURLWithPath:path];

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [self createDirectionOfFileURL:destinationURL];
    NSError *err = nil;
    [fileManager copyItemAtURL:sourceURL toURL:destinationURL error:&err];

    if(err==nil) {
      callback(@[@NO, [destinationURL absoluteString]]);
    }else {
      callback(@[ [err localizedDescription] ]);
    }
  });
}
//- (void)copyItemFrom:(NSURL *)urlFrom to:(NSURL *)urlTo error:(NSError **)error {
//  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    NSFileManager *fileManager = [[NSFileManager alloc] init];
//    [self createDirectionOfFileURL:urlTo];
//    [fileManager copyItemAtURL:urlFrom toURL:urlTo error:error];
//  });
//}

#pragma mark - move file to or from icloud
RCT_EXPORT_METHOD(moveFileToICloud:(NSString *)pathToUpload :(RCTResponseSenderBlock)callback)
{
//  NSURL *docUrl = [self getICloudDocumentURL];

  NSURL *sourceURL = [NSURL fileURLWithPath:pathToUpload];
  NSURL *destinationURL = [self getICloudDocumentURLByLocalPath:pathToUpload];

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSFileManager *fileManager = [[NSFileManager alloc] init];

    [self createDirectionOfFileURL:destinationURL];
    NSError *err = nil;
    BOOL success = [fileManager setUbiquitous:YES itemAtURL:sourceURL destinationURL:destinationURL error:&err];
    dispatch_async(dispatch_get_main_queue(), ^{
      if(success) {
        callback(@[@NO, [destinationURL absoluteString]]);
      }else {
        callback(@[ [err localizedDescription] ]);
      }
    });

  });
}
RCT_EXPORT_METHOD(moveFileFromICloud:(NSString *)iCloudPath :(RCTResponseSenderBlock)callback)
{
  //  NSURL *docUrl = [self getICloudDocumentURL];

  NSURL *sourceURL = [NSURL fileURLWithPath:iCloudPath];
  NSURL *destinationURL = [self getDocumentURLByICloudPath:iCloudPath];

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSFileManager *fileManager = [[NSFileManager alloc] init];

    [self createDirectionOfFileURL:destinationURL];
    NSError *err = nil;
    BOOL success = [fileManager setUbiquitous:NO itemAtURL:sourceURL destinationURL:destinationURL error:&err];
    dispatch_async(dispatch_get_main_queue(), ^{
      if(success) {
        callback(@[@NO, [destinationURL absoluteString]]);
      }else {
        callback(@[ [err localizedDescription] ]);
      }
    });

  });
}

#pragma mark - get file attributes with path
RCT_EXPORT_METHOD(attributesOfItemAtPath:(NSString *)path :(RCTResponseSenderBlock)callback){
  NSDictionary *attrs = [[[NSFileManager alloc] init] attributesOfItemAtPath:path error:nil];
//  NSDictionary *attrs = [[[NSFileManager alloc] init] attributesOfItemAtPath:path error:nil];
  NSNumber *createAt = [NSNumber numberWithDouble: [[attrs objectForKey:@"NSFileCreationDate"] timeIntervalSince1970] ];
  NSNumber *modifyAt = [NSNumber numberWithDouble: [[attrs objectForKey:@"NSFileModificationDate"] timeIntervalSince1970] ];
  NSDictionary *ret = @{
                        @"createAt": createAt,
                        @"modifyAt": modifyAt,
                        @"size": [attrs objectForKey:@"NSFileSize"]};
//  NSLog(@"attrs %@", attrs);
  callback(@[@NO, ret]);
}


#pragma mark - contents at item or directory
RCT_EXPORT_METHOD(contentsAtPath:(NSString *)path :(RCTResponseSenderBlock)callback){
  NSFileManager *fileManager = [[NSFileManager alloc] init];

  NSData *data = [fileManager contentsAtPath:path];
  NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//  NSLog(@"datastr %@", dataStr);
  callback(@[@NO, dataStr]);
}
RCT_EXPORT_METHOD(contentsOfDirectoryAtPath:(NSString *)path :(RCTResponseSenderBlock)callback){
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  NSArray *array = [fileManager contentsOfDirectoryAtPath:path error:nil];
  callback(@[@NO, array]);
}

#pragma mark - remove file with path
RCT_EXPORT_METHOD(removeICloudFile:(NSString *)pathToRemove :(RCTResponseSenderBlock)callback){
  NSURL *destinationURL = [NSURL URLWithString:pathToRemove];

  NSFileManager *fileManager = [[NSFileManager alloc] init];
  BOOL fileExists = [fileManager fileExistsAtPath:pathToRemove];
  if(!fileExists){
    callback(@[@"file not exists"]);
    return;
  }

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSError *error = nil;
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    [fileCoordinator coordinateWritingItemAtURL:destinationURL options:NSFileCoordinatorWritingForDeleting error:&error byAccessor:^(NSURL * _Nonnull newURL) {
      NSError *err = nil;
      [fileManager removeItemAtURL:destinationURL error:&err];
      if (err) {
        callback(@[ [err localizedDescription] ]);
      }else {
        callback(@[ @FALSE, @TRUE ]);
      }
    }];
  });

}

#pragma mark - get iCloud token
RCT_EXPORT_METHOD(getICloudToken:(RCTResponseSenderBlock)callback){
  id token = [[[NSFileManager alloc] init] ubiquityIdentityToken];
//  DumpObjcMethods(object_getClass(token));
//  NSLog(@"token %@", token);
  if (token == nil) {
    callback(@[[NSNull null]]);
  }else {
    callback(@[@YES]);
//    NSData *tokenData = [token serializedRepresentation];
//    NSString *tokenStr = [[NSString alloc] initWithData:tokenData encoding:NSUTF8StringEncoding];
//    callback(@[tokenStr]);
  }
}


#pragma mark - get iCloud or local doc root
RCT_EXPORT_METHOD(iCloudDocumentPath:(RCTResponseSenderBlock)callback)
{
  callback(@[[self getICloudDocumentURL] ]);
}
RCT_EXPORT_METHOD(documentPath:(RCTResponseSenderBlock)callback)
{
  callback(@[ [self _documentPath] ]);
}
RCT_EXPORT_METHOD(getICloudDocumentURLByLocalPath:(NSString *)localPath :(RCTResponseSenderBlock)callback){
  NSURL *url = [self getICloudDocumentURLByLocalPath:localPath];
  callback(@[ [url absoluteString] ]);
}


#pragma mark - native methods
- (NSString *)createTempFile:(NSURL *)url {
  NSString *filename = [url lastPathComponent];
  NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
  BOOL tempCopied = [[[NSFileManager alloc] init] copyItemAtPath:[url absoluteString] toPath:tempPath error:nil];
  if (tempCopied) {
    return tempPath;
  }else {
    return nil;
  }
//  return tempCopied;
}
- (void)createDirectionOfFileURL:(NSURL *)url {
  NSURL *dir = [url URLByDeletingLastPathComponent];
  [[[NSFileManager alloc] init] createDirectoryAtURL:dir withIntermediateDirectories:YES attributes:nil error:nil];
}

- (NSString *)_documentPath {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  return [paths objectAtIndex:0];
}
- (NSString*)getRelativePath:(NSString *)path {
//  NSString *docPath = [self _documentPath];
  NSRange range = [path rangeOfString:@"Documents/"];
  NSString *relativePath = [path substringFromIndex:range.location+range.length];
  return relativePath;
}
- (NSURL *)getDocumentURLByICloudPath: (NSString *)iCloudPath {
  NSString *relativePath = [self getRelativePath:iCloudPath];
  NSURL *localURL = [[NSURL URLWithString:[self _documentPath]] URLByAppendingPathComponent:relativePath];
  return localURL;
}
- (NSURL *)getICloudDocumentURLByLocalPath: (NSString *)localPath {
  NSURL *docUrl = [self getICloudDocumentURL];
//  localPath = [self getRelativePathOfDocuments:localPath];
//  NSString *filename = [localPath lastPathComponent];
  NSString *filename = [self getRelativePath:localPath];
  NSURL *destinationURL = [docUrl URLByAppendingPathComponent:filename];
  return destinationURL;
}
- (NSURL *)getICloudDocumentURL {
  // get icloud docURL with default bundleID
  NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  NSString *icloudID = [NSString stringWithFormat:@"iCloud.%@", bundleIdentifier];
  NSURL *containerURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:icloudID];
//  NSURL *containerURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
  NSURL *docUrl = [containerURL URLByAppendingPathComponent:@"Documents"];
  return docUrl;
}

@end
