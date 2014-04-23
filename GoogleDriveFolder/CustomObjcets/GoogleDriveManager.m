//
//  GoogleDriveManager.m
//  sampleDrive
//
//  Created by Project Development Department on 2014/03/27.
//  Copyright (c) 2014年 Project Development Department. All rights reserved.
//

#import "GoogleDriveManager.h"

@implementation GoogleDriveManager

// Singleton Creation For google manager

+ (id)sharedGoogleDriveManager {
    static GoogleDriveManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

#pragma mark -Get SubFolder and Files

+(void)getSubFolderFileList:(GTLService *)service ServiceTicket:(GTLServiceTicket *)serviceTicket folderId:(NSString *)folderId  :(void (^)(BOOL,NSMutableArray *, NSError*))completionBlock{

//NSString *parentId = @"root";

GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
query.q = [NSString stringWithFormat:@"'%@' in parents", folderId];
        serviceTicket=[service executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                         GTLDriveFileList *files,
                                                         NSError *error) {
            NSMutableArray *mainArray=[[NSMutableArray alloc]init];
            
            if (error == nil)
            {
                [mainArray addObjectsFromArray:files.items];
            
                NSMutableArray *arrayFilter1=[[NSMutableArray alloc]init];
                NSMutableArray *arrayFilter2=[[NSMutableArray alloc]init];
                
                [mainArray enumerateObjectsUsingBlock:^(GTLDriveFile *obj, NSUInteger idx, BOOL *stop) {
                    [obj.mimeType isEqualToString:@"application/vnd.google-apps.folder"]?[arrayFilter1 addObject:obj]:[arrayFilter2 addObject:obj];
                }];
                [mainArray removeAllObjects];
                arrayFilter1.count>0?[mainArray addObject:arrayFilter1]:nil;
                arrayFilter2.count>0?[mainArray addObject:arrayFilter2]:nil;
                 
                 
                completionBlock(YES,mainArray,nil);
                //serviceTicket=nil;
                
            }
            else
            {
                NSLog(@"An error occurred: %@", error);
                completionBlock(NO,nil,error);
                
                // [self showAlert:@"Error" message:[error localizedDescription]];
            }
}];
    
    
    

}

#pragma mark - Download File Without Progress Value

+ (void)downloadFileContentWithFile:(GTLDriveFile *)file completionBlock:(void (^)(NSData *, NSError *))completionBlock {
    if (file.downloadUrl != nil) {
        // More information about GTMHTTPFetcher can be found on
        // http://code.google.com/p/gtm-http-fetcher
        NSLog(@"SERVice%@,,,,,%@",[[self sharedGoogleDriveManager] driveService],[[self sharedGoogleDriveManager] driveService].fetcherService);
       GTMHTTPFetcher *fetcher =
        [[[self sharedGoogleDriveManager] driveService].fetcherService fetcherWithURLString:file.downloadUrl];
        
        [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
            if (error == nil) {
                // Success.
                completionBlock(data, nil);
            } else {
                NSLog(@"An error occurred: %@", error);
                completionBlock(nil, error);
            }
        }];
    } else {
        completionBlock(nil,
                        [NSError errorWithDomain:NSURLErrorDomain
                                            code:NSURLErrorBadURL
                                        userInfo:nil]);
    }
}
#pragma mark -Cancel List Folder

+(void)cancelOperationOfSeriveTicket:(GTLServiceTicket *)serviceTicket
{
    [serviceTicket cancelTicket];
}
#pragma mark - Download File With Progress Value

+ (void)downloadFileContentWithFile:(GTLDriveFile *)file completionBlock:(void (^)(NSData *, NSError *))completionBlock progressBlock:(void (^)(NSData *, GTMHTTPFetcher *))progressBlock{
     __weak GTMHTTPFetcher * fetcher;
    if (file.downloadUrl != nil) {
        // More information about GTMHTTPFetcher can be found on
        // http://code.google.com/p/gtm-http-fetcher
        NSLog(@"SERVice%@,,,,,%@",[[self sharedGoogleDriveManager] driveService],[[self sharedGoogleDriveManager] driveService].fetcherService);
        fetcher =
        [[[self sharedGoogleDriveManager] driveService].fetcherService fetcherWithURLString:file.downloadUrl];
        
        [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
            if (error == nil) {
                // Success.
                completionBlock(data, nil);
            } else {
                NSLog(@"An error occurred: %@", error);
                completionBlock(nil, error);
            }
        }];
    } else {
        completionBlock(nil,
                        [NSError errorWithDomain:NSURLErrorDomain
                                            code:NSURLErrorBadURL
                                        userInfo:nil]);
    }
    [fetcher setReceivedDataBlock:^(NSData *data) {
        progressBlock(data,fetcher);
        //NSLog(@"%f%% Downloaded", (100.0 / [file.fileSize longLongValue] * [data length]));
    }];
    
   
}

+ (void)getIconWithFile:(GTLDriveFile *)file completionBlock:(void (^)(NSData *, NSError *))completionBlock{
    if (file.downloadUrl != nil) {
        // More information about GTMHTTPFetcher can be found on
        // http://code.google.com/p/gtm-http-fetcher
        GTMHTTPFetcher *fetcher =
        [[[self sharedGoogleDriveManager] driveService].fetcherService fetcherWithURLString:file.thumbnailLink];
        [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
            if (error == nil) {
                // Success.
                completionBlock(data, nil);
            } else {
                NSLog(@"An error occurred: %@", error);
                completionBlock(nil, error);
            }
        }];
    } else {
        completionBlock(nil,
                        [NSError errorWithDomain:NSURLErrorDomain
                                            code:NSURLErrorBadURL
                                        userInfo:nil]);
    }
}

@end
