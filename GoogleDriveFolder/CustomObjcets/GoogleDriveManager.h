//
//  GoogleDriveManager.h
//  sampleDrive
//
//  Created by Project Development Department on 2014/03/27.
//  Copyright (c) 2014年 Project Development Department. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLDrive.h"
#import "GTLServiceDrive.h"

@interface GoogleDriveManager : NSObject
@property (nonatomic, retain) GTLServiceDrive *driveService;
@property (nonatomic, retain) NSString *accessTokenValue;
+ (id)sharedGoogleDriveManager ;

+(void)getSubFolderFileList:(GTLService *)service ServiceTicket:(GTLServiceTicket *)serviceTicket folderId:(NSString *)folderId  :(void (^)(BOOL,NSMutableArray *, NSError*))completionBlock;

+(void)cancelOperationOfSeriveTicket:(GTLServiceTicket *)serviceTicket;

+ (void)downloadFileContentWithFile:(GTLDriveFile *)file completionBlock:(void (^)(NSData *, NSError *))completionBlock;

+ (void)downloadFileContentWithFile:(GTLDriveFile *)file completionBlock:(void (^)(NSData *, NSError *))completionBlock progressBlock:(void (^)(NSData *, GTMHTTPFetcher *))progressBlock;

+ (void)getIconWithFile:(GTLDriveFile *)file completionBlock:(void (^)(NSData *, NSError *))completionBlock;

@end
