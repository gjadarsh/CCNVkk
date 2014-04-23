//
//  SugarSyncAPI.h
//  SugarSyncProject
//
//  Created by Abdul Rehman on 12/19/12.
//  Copyright (c) 2012 Abdul Rehman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SugarSyncAPI;
@protocol SugarSyncDelegate <NSObject>
@optional
- (void)SugarSync:(SugarSyncAPI *)api didFinishAuthenticationWithRefreshToken:(NSString *)refreshToken;
- (void)SugarSync:(SugarSyncAPI *)api didFinishAuthenticationWithAccessToken:(NSString *)accessToken;
- (void)SugarSync:(SugarSyncAPI *)api didGetRootFolderLink:(NSString *)rootFolderLink;

- (void)SugarSync:(SugarSyncAPI *)api downloadedFileSuccessfullyWithName:(NSString *)name withData:(NSData *)data;

- (void)SugarSync:(SugarSyncAPI *)api finishUploadingFileWithName:(NSString *)name withError:(NSError *)error;

- (void)SugarSync:(SugarSyncAPI *)api didGetFolderCollections:(NSMutableArray *)collectionsArray withError:(NSError *)error;

@end


@interface SugarSyncAPI : NSObject

@property (nonatomic, assign) id<SugarSyncDelegate>delegate;
@property(nonatomic,retain)NSMutableArray *operationsArray;

+ (SugarSyncAPI*)sharedAPI;
 // OAUTH 2.0 Protocol Functions
- (void)SSConnectWithUser:(NSString*)user andPassword:(NSString*)password;
- (void)SSGetAccesTokenWithRefreshToken: (NSString *)refreshToken;
- (void)SSgetUserTopFolderLinkWithAccesToken: (NSString *)accesToken;

// Get Folder Collection Objects
- (void)SSgetSyncFolderCollectionWithFolderLink:(NSString *)syncFolderLink  accessToken:(NSString *)token;
// Download File Data with given parameters as fileData Link ("ending with /Data") and Access Token
- (void)SSdownloadFileWithFileLink:(NSURL *)fileDataLink fileName:(NSString *)name  withAccessToken:(NSString *)token;

// Delete File With Parameter

- (BOOL)SSDeleteFileWithLink:(NSString *)link withAccessToken:(NSString *)token;



// upload File with parameter as filedata Link , Name and Access Token

- (void)SSuploadFileAtFolderPath: (NSString *)folderPath withFileDataPath:(NSString *)path withName:(NSString *)fileName accessToken:(NSString *)token;

-(void)cancelRequest;
+(void)getImageDataWithFileLink:(NSURL *)fileDataLink fileName:(NSString *)name  withAccessToken:(NSString *)token :(void (^)(BOOL,NSMutableDictionary *, NSError*))completionBlock;

@end
