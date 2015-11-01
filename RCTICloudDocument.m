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

@property (nonatomic, retain) NSMetadataQuery *query;

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
  if(![fileManager fileExistsAtPath:[urlFrom path]]){
    return nil;
  }
  NSLog(@"urlFrom %@", urlFrom); 
//  return urlFrom;
  NSURL *tmpFileURL = [NSURL URLWithString: [self createTempFile:urlFrom]];
  NSLog(@"tmp file url %@, %@", urlFrom, tmpFileURL);
  return tmpFileURL;
  [fileManager copyItemAtURL:urlFrom toURL:tmpFileURL error:nil];
  NSLog(@"copied tmp\nurlTo: %@\n\n", urlTo);
  NSURL *resultingURL;
  NSError *err;
  return tmpFileURL;
  [fileManager setUbiquitous:YES itemAtURL:tmpFileURL destinationURL:urlTo error:nil];
  return urlTo;
//  [fileManager replaceItemAtURL:urlTo withItemAtURL:tmpFileURL backupItemName:nil options:0 resultingItemURL:&resultingURL error:&err];
//  if(!err && [resultingURL.absoluteString isEqualToString:urlTo.absoluteString]){
//    return resultingURL;
//  }else {
//    NSLog(@"replace error %@", err);
//    return nil;
//  }
}
RCT_EXPORT_METHOD(replaceFileToICloud:(NSString *)localPath :(RCTResponseSenderBlock)callback)
{
  //  NSURL *docUrl = [self getICloudDocumentURL];
  NSURL *sourceURL = [NSURL URLWithString:localPath];
//    NSURL *sourceURL = [NSURL fileURLWithPath:localPath];
  NSURL *destinationURL = [self getICloudDocumentURLByLocalPath:localPath];
  
  
//  NSLog(@"replace file to icloud local: %@, src: %@, dest: %@", localPath, sourceURL, destinationURL);
  
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
  if(![[[NSFileManager alloc] init] fileExistsAtPath:iCloudPath]){
    callback(@[@"file not exists, probably not downloaded yet"]);
    return;
  }
//  return;
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


#pragma mark - copy file to or from iCloud
RCT_EXPORT_METHOD(copyFileToICloud:(NSString *)localPath :(RCTResponseSenderBlock)callback)
{
  //  NSURL *docUrl = [self getICloudDocumentURL];
  NSURL *sourceURL = [NSURL fileURLWithPath:localPath];
  NSURL *destinationURL = [self getICloudDocumentURLByLocalPath:localPath];
  
  
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


RCT_EXPORT_METHOD(itemAttrsOfDirectoryAtICloud:(NSString *)path :(RCTResponseSenderBlock)callback){
  
  dispatch_sync(dispatch_get_main_queue(), ^{
    
    query = [[NSMetadataQuery alloc] init];
      [query setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
//    [query setSearchScopes:@[NSMetadataQueryUbiquitousDataScope]];
    
    //      NSPredicate *pred = [NSPredicate predicateWithFormat: @"%K like '*.*'", NSMetadataItemFSNameKey];
    //  NSString *icloudPath =
    //  NSPredicate *pred = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%%K like \"%@*\"", path], NSMetadataItemPathKey];
//    NSLog(@"predict path %@", [NSString stringWithFormat:@"%@ MATCHES '%@/*.*'", NSMetadataItemPathKey, path]);
    
//    [query setPredicate:[NSPredicate predicateWithFormat:@"%K MATCHES '%@/*.*'", NSMetadataItemPathKey, path]];
//    NSString *path2 = [[[NSFileManager alloc] init] URLForUbiquityContainerIdentifier:nil].path;
//    NSLog(@"predict path2 %@", path2);
    [query setPredicate:[NSPredicate predicateWithFormat:@"%K BEGINSWITH %@", NSMetadataItemPathKey, path]];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(queryDidFinishGathering:)
    //                                                 name:NSMetadataQueryDidFinishGatheringNotification
    //                                               object:query];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSMetadataQueryDidFinishGatheringNotification object:query queue:nil usingBlock:^(NSNotification * _Nonnull note) {
      //      NSMetadataQuery *query = [note object];
      NSArray *res = [self queryDidFinishGathering:note];
      callback(@[@NO, res]);
    }];
    [query startQuery];
  });

}

@synthesize query;

- (NSArray *)queryDidFinishGathering:(NSNotification *)notification {
//  NSLog(@"did finish");
//  NSMetadataQuery *query = [notification object];
  NSMutableArray *res = [NSMutableArray array];
  [query enumerateResultsUsingBlock:^(id  _Nonnull result, NSUInteger idx, BOOL * _Nonnull stop) {
    NSNumber *createAt = [self getDateNumber:[result valueForAttribute:NSMetadataItemFSCreationDateKey]];
    NSNumber *modifyAt = [self getDateNumber:[result valueForAttribute:NSMetadataItemFSContentChangeDateKey]];
    NSDictionary *item = @{
                           @"path": [result valueForAttribute:NSMetadataItemPathKey],
                           @"name": [result valueForAttribute:NSMetadataItemFSNameKey],
                           @"createAt": createAt,
                           @"modifyAt": modifyAt
                           };
    [res addObject:item];
//    NSLog(@"meta item %@", result);
  }];
  return res;
//  [[query results] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//    
//  }];
//  NSLog(@"did finish observe %@", res);
  
//  [query disableUpdates];
//  [query stopQuery];
  
}

#pragma mark - get file attributes with path
RCT_EXPORT_METHOD(attributesOfItemAtPath:(NSString *)path :(RCTResponseSenderBlock)callback){
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  NSDictionary *attrs;
  BOOL isDir;
  BOOL isExists = [fileManager fileExistsAtPath:path isDirectory:&isDir];
  if (!isExists) {
    callback(@[@"path not exists"]);
    return;
  }else if(isDir){
    attrs = [fileManager attributesOfItemAtPath:path error:nil];
  }else {
    attrs = [fileManager attributesOfItemAtPath:path error:nil];
  }
  
//  NSNumber *createAt = [NSNumber numberWithDouble: [[attrs objectForKey:@"NSFileCreationDate"] timeIntervalSince1970] ];
  NSNumber *createAt = [self getDateNumber:[attrs objectForKey:@"NSFileCreationDate"]];
//  NSNumber *modifyAt = [NSNumber numberWithDouble: [[attrs objectForKey:@"NSFileModificationDate"] timeIntervalSince1970] ];
  NSNumber *modifyAt = [self getDateNumber:[attrs objectForKey:@"NSFileModificationDate"]];
//  NSLog(@"attrs %@ at %@", attrs, path);
  NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithDictionary: @{
            @"path": path,
            @"createAt": createAt,
            @"modifyAt": modifyAt,
            @"isDirectory": [NSNumber numberWithBool:isDir]
            }];
  if(!isDir) {
    [ret setValue:[attrs objectForKey:@"NSFileSize"] forKey:@"size"];
  }
  //  NSLog(@"attrs %@", attrs);
  callback(@[@NO, ret]);
}
- (NSNumber *)getDateNumber: (id)obj{
  return [NSNumber numberWithDouble: [ obj timeIntervalSince1970] ];
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
  NSError *err;
  NSArray *array = [fileManager contentsOfDirectoryAtPath:path error:&err];
//  NSLog(@"contentsOfDirectoryAtPath err %@", [err description]);
  if(err){
    callback(@[[err localizedDescription]]);
  }else {
    callback(@[@NO, array]);
  }
}

#pragma mark - remove file with path
RCT_EXPORT_METHOD(removeFileAtPath:(NSString *)pathToRemove :(RCTResponseSenderBlock)callback){
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
    callback(@[@"Token Nil", [NSNull null]]);
  }else {
    
    NSData *tokenData = [NSKeyedArchiver archivedDataWithRootObject:token];
    NSLog(@"parsed token NSData %@", tokenData);
    //    NSString *tokenDataString = [[NSString alloc] initWithData:tokenData encoding:NSUTF8StringEncoding];
    NSString *tokenDataString = [tokenData description];
    NSLog(@"try parse data to string %@", tokenDataString);
    callback(@[@NO, tokenDataString]);
    //    NSData *tokenData = [token serializedRepresentation];
    //    NSString *tokenStr = [[NSString alloc] initWithData:tokenData encoding:NSUTF8StringEncoding];
    //    callback(@[tokenStr]);
  }
}


#pragma mark - get iCloud or local doc root
RCT_EXPORT_METHOD(iCloudDocumentPath:(RCTResponseSenderBlock)callback)
{
  callback(@[@NO, [[self getICloudDocumentURL] path] ]);
}
RCT_EXPORT_METHOD(documentPath:(RCTResponseSenderBlock)callback)
{
  callback(@[@NO,  [self _documentPath] ]);
}
RCT_EXPORT_METHOD(getICloudDocumentURLByLocalPath:(NSString *)localPath :(RCTResponseSenderBlock)callback){
  NSURL *url = [self getICloudDocumentURLByLocalPath:localPath];
  callback(@[@NO,  [url absoluteString] ]);
}


#pragma mark - native methods
- (NSString *)createTempFile:(NSURL *)url {
  NSFileManager *fileManager = [[NSFileManager alloc] init];
  NSString *filename = [url lastPathComponent];
  NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
  [fileManager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
//  fileManager createDirectoryAtURL:<#(nonnull NSURL *)#> withIntermediateDirectories:<#(BOOL)#> attributes:<#(nullable NSDictionary<NSString *,id> *)#> error:<#(NSError * _Nullable __autoreleasing * _Nullable)#>
  if ( [fileManager fileExistsAtPath:tempPath] ) {
    [fileManager removeItemAtPath:tempPath error:nil];
  }
  NSError *err;
  BOOL tempCopied = [fileManager copyItemAtPath:[url absoluteString] toPath:tempPath error:&err];
  NSLog(@"create tmp err %@", err);
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
//  NSLog(@"relative path input:%@ out:%@", path, relativePath);
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
//  [NSFileManager URLForUbiquityContainerIdentifier:nil].path
  NSURL *containerURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:icloudID];
  //  NSURL *containerURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
  NSURL *docUrl = [containerURL URLByAppendingPathComponent:@"Documents"];
  return docUrl;
}

@end
