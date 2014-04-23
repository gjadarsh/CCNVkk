//
//  SugarSyncAPI.m
//  SugarSyncProject
//
//  Created by Abdul Rehman on 12/19/12.
//  Copyright (c) 2012 Abdul Rehman. All rights reserved.
//

#import "SugarSyncAPI.h"
#import "XMLReader.h"
#import "Global.h"
#import "File.h"
#import "NWURLConnection.h"//adarsh

@interface SugarSyncAPI () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic,retain) NSString * token;
@property (nonatomic,retain) NSString * userAgent;
@property (nonatomic,retain) NSMutableDictionary * fDictionary;
@end


@implementation SugarSyncAPI

{
    NSMutableURLRequest *imageRequest;
    NSMutableURLRequest *requestMain;
}

//#define accessKeyId @"Mzk2MzMyNzEzNTU4MzExOTM0Nzc"
//#define privateAccessKey @"MGUyN2MwNDM2MWE0NDQwMDk5YWE1NWEzNWJiZTk5ZmQ"
//#define appId @"/sc/3963327/127_256995135"

static SugarSyncAPI* _sharedAPI = nil;

#pragma mark Singleton Methods

+ (SugarSyncAPI *)sharedAPI
{
	if(!_sharedAPI) {

		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedAPI = [[self alloc] init];
            _sharedAPI.userAgent = [NSString stringWithFormat:@"%@/%@",
                                    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"],
                                    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SSFDictionary"]==nil)
            {
                _sharedAPI.fDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
            }
            else
            {
                NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"SSFDictionary"];
                _sharedAPI.fDictionary = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
            }
        
            _sharedAPI.operationsArray=[[NSMutableArray alloc]init];
            
        });
    }
    return _sharedAPI;
}


#pragma mark - login Service

-(void)SSConnectWithUser:(NSString*)user andPassword:(NSString*)password
{
    NSURL *url = [NSURL URLWithString:@"https://api.sugarsync.com/app-authorization"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *str = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
                     "<appAuthorization>"
                     "<username>%@</username>"
                     "<password>%@</password>"
                     "<application>%@</application>"
                     "<accessKeyId>%@</accessKeyId>"
                     "<privateAccessKey>%@</privateAccessKey>"
                     "</appAuthorization>", user, password, APP.applicationID, APP.accessKeyId, APP.privateAccessKey];
    
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[str dataUsingEncoding:NSUTF8StringEncoding]];
        
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
//    [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response_, NSData *data, NSError *error)
     {
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)response_;
         if ([response respondsToSelector:@selector(allHeaderFields)])
         {
             NSLog(@"Responce header fields :%d",[response statusCode]);
             NSDictionary *dictionary = [response allHeaderFields];
             NSString *token = [dictionary objectForKey:@"Location"];
             NSLog(@"Text Value Responce :%@", [response allHeaderFields]);
             NSLog(@"Refresh Token :%@", token);
             
             if ([self.delegate respondsToSelector:@selector(SugarSync:didFinishAuthenticationWithRefreshToken:)])
             {
                 [self.delegate SugarSync:self didFinishAuthenticationWithRefreshToken:token];
             }
         }

     }];
    
}


-(void)SSGetAccesTokenWithRefreshToken: (NSString *)refreshToken
{
//    YNSLog(@"SSConnectWithUser: %@", user);
    NSURL *url = [NSURL URLWithString:@"https://api.sugarsync.com/authorization"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString * str = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
                      "<tokenAuthRequest>"
                      "<accessKeyId>%@</accessKeyId>"
                      "<privateAccessKey>%@</privateAccessKey>"
                      "<refreshToken>%@</refreshToken>"
                      "</tokenAuthRequest>", APP.accessKeyId, APP.privateAccessKey, APP.refreshToken];
    
    
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[str dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[[NSOperationQueue alloc] init] autorelease] completionHandler:^(NSURLResponse *response_, NSData *data, NSError *error)
     {
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)response_;
         if ([response respondsToSelector:@selector(allHeaderFields)])
         {
             NSLog(@"Responce header fields :%d",[response statusCode]);
             NSDictionary *dictionary = [response allHeaderFields];
             NSString *token = [dictionary objectForKey:@"Location"];
//             NSLog(@"Text Value Responce :%@", [response allHeaderFields]);
//             NSLog(@"Refresh Token :%@", token);
             
             if ([self.delegate respondsToSelector:@selector(SugarSync:didFinishAuthenticationWithAccessToken:)])
             {
                 [self.delegate SugarSync:self didFinishAuthenticationWithAccessToken:token];
             }
         }
         
     }];
}

- (void)SSgetUserTopFolderLinkWithAccesToken: (NSString *)accesToken
{
    NSURL *url = [NSURL URLWithString:@"https://api.sugarsync.com/user"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:accesToken forHTTPHeaderField:@"Authorization"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[[NSOperationQueue alloc] init] autorelease] completionHandler:^(NSURLResponse *response_, NSData *data, NSError *error)
     {
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)response_;
         if ([response respondsToSelector:@selector(allHeaderFields)])
         {
             NSError *responceError;
             NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&responceError];
             NSString *rootFolderLink = [[dictionary valueForKey:@"user"] valueForKey:@"syncfolders"];
             if ([self.delegate respondsToSelector:@selector(SugarSync:didGetRootFolderLink:)])
             {
                 [self.delegate SugarSync:self didGetRootFolderLink:rootFolderLink];
             }
         }
         else
         {
//             NSLog(@"Error Description :%@", [requestError debugDescription]);
         }

                 
     }];

}

#pragma mark - Traversing Folders hierarchy

// Get an Array of Metadata of Objects (files and Folders) with provided root folder link (ending with "/contents").

-(void)SSgetSyncFolderCollectionWithFolderLink:(NSString *)syncFolderLink  accessToken:(NSString *)token
{
    NSURL *url = [NSURL URLWithString:syncFolderLink];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    NSHTTPURLResponse *response = NULL;
    NSError *requestError = NULL;
    NSData *responceData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&requestError];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response_, NSData *data, NSError *error)
    {
    
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)response_;
    if ([response respondsToSelector:@selector(allHeaderFields)])
    {
        NSError *responceError;
     //   NSString *xmlResponce = [[[NSString alloc] initWithData:responceData encoding:NSUTF8StringEncoding] autorelease];
        NSDictionary *dictionary = [XMLReader dictionaryForXMLData:responceData error:&responceError];
        
        
        id end = [[dictionary valueForKey:@"collectionContents"] valueForKey:@"end"];
        if ([end isEqualToString:@"0"])
        {
        
            NSMutableArray *temp = [[[NSMutableArray alloc] init] autorelease];
            if ([self.delegate respondsToSelector:@selector(SugarSync:didGetFolderCollections:withError:)])
            {
                [self.delegate SugarSync:self didGetFolderCollections:temp withError:nil];
            }
        }
        
        id folders = [[dictionary valueForKey:@"collectionContents"] valueForKey:@"collection"];
        NSMutableArray *foldersArray;
        if ([folders isKindOfClass:[NSArray class]])
        {
             foldersArray   = [[[NSMutableArray alloc] initWithArray:folders] autorelease];
            
            id files = [[dictionary valueForKey:@"collectionContents"] valueForKey:@"file"];
            if ([files isKindOfClass:[NSArray class]])
            {
                [foldersArray addObjectsFromArray:files];
            }
            else
            {
                if (files != Nil)
                {
                    [foldersArray addObject:files];
                    
                }
            }
        }
        
        else
        {
            foldersArray = [[[NSMutableArray alloc] initWithObjects:folders, nil] autorelease];
            id files = [[dictionary valueForKey:@"collectionContents"] valueForKey:@"file"];
            if ([files isKindOfClass:[NSArray class]])
            {
                [foldersArray addObjectsFromArray:files];
            }
            else
            {
                [foldersArray addObject:files];
            }

        }
        if ([self.delegate respondsToSelector:@selector(SugarSync:didGetFolderCollections:withError:)])
        {
            [self.delegate SugarSync:self didGetFolderCollections:foldersArray withError:nil];
        }

    }
    else
    {
        NSLog(@"Error Description :%@", [requestError debugDescription]);
        if ([self.delegate respondsToSelector:@selector(SugarSync:didGetFolderCollections:withError:)])
        {
            [self.delegate SugarSync:self didGetFolderCollections:[NSMutableArray new] withError:error];
        }

//        return NULL;
    }
    }];
}

- (void)SSdownloadFileWithFileLink:(NSURL *)fileDataLink fileName:(NSString *)name  withAccessToken:(NSString *)atoken;
{
    NSURL *url = fileDataLink;
    requestMain = [NSMutableURLRequest requestWithURL:url];
    [requestMain setHTTPMethod:@"GET"];
    [requestMain setValue:atoken forHTTPHeaderField:@"Authorization"];
    NSOperationQueue *downloadOperationQueue;

    downloadOperationQueue=[NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:requestMain queue:downloadOperationQueue completionHandler:^(NSURLResponse *responce, NSData *data, NSError *error)
     {
         if (error)
         {
             // return nil
         }
         
         else
         {
             if ([responce respondsToSelector:@selector(allHeaderFields)])
             {
                 
                 File *imageFile = [[File alloc] init];
                 imageFile.FullImage = [UIImage imageWithData:data];
                 imageFile.filedata  = [fileDataLink absoluteString];
                 

                 NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:2];
                 [dictionary setObject:data forKey:@"imageData"];
                 [dictionary setObject:fileDataLink.absoluteString forKey:@"imageDataLink"];
                 NSLog(@"APIII");
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"SugarSyncImageDownloaded" object:nil userInfo:dictionary];
                 
                 if ([self.delegate respondsToSelector:@selector(SugarSync:downloadedFileSuccessfullyWithName:withData:)])
                 {
                     [self.delegate SugarSync:self downloadedFileSuccessfullyWithName:name withData:data];
                 }
             }
         }
     }];
    [_sharedAPI.operationsArray addObject:downloadOperationQueue];
    
}
+(void)getImageDataWithFileLink:(NSURL *)fileDataLink fileName:(NSString *)name  withAccessToken:(NSString *)token :(void (^)(BOOL,NSMutableDictionary *, NSError*))completionBlock{
    
    NSURL *url = fileDataLink;
    NSMutableURLRequest *requestMain = [NSMutableURLRequest requestWithURL:url];
    [requestMain setHTTPMethod:@"GET"];
    [requestMain setValue:token forHTTPHeaderField:@"Authorization"];
    NSOperationQueue *downloadOperationQueue;
    
    downloadOperationQueue=[NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:requestMain queue:downloadOperationQueue completionHandler:^(NSURLResponse *responce, NSData *data, NSError *error)
     {
         if (error)
         {
             // return nil
             completionBlock(YES,nil,error);

         }
         
         else
         {
             if ([responce respondsToSelector:@selector(allHeaderFields)])
             {
                 
                 File *imageFile = [[File alloc] init];
                 imageFile.FullImage = [UIImage imageWithData:data];
                 imageFile.filedata  = [fileDataLink absoluteString];
                 
                 
                 NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:2];
                 [dictionary setObject:data forKey:@"imageData"];
                 [dictionary setObject:fileDataLink.absoluteString forKey:@"imageDataLink"];
                 NSLog(@"APIII");
                 completionBlock(YES,dictionary,nil);
                 
                // [[NSNotificationCenter defaultCenter] postNotificationName:@"SugarSyncImageDownloaded" object:nil userInfo:dictionary];
                 
//                 if ([self.delegate respondsToSelector:@selector(SugarSync:downloadedFileSuccessfullyWithName:withData:)])
//                 {ni
//                     [self.delegate SugarSync:self downloadedFileSuccessfullyWithName:name withData:data];
//                 }
             }
         }
     }];
    [_sharedAPI.operationsArray addObject:downloadOperationQueue];
    

}
/*
- (void)SSdownloadFileWithFileLink:(NSURL *)fileDataLink fileName:(NSString *)name  withAccessToken:(NSString *)atoken;
{
    NSURL *url = fileDataLink;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:atoken forHTTPHeaderField:@"Authorization"];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *responce, NSData *data, NSError *error)
     {
         if (error)
         {
             // return nil
         }
         
         else
         {
             if ([responce respondsToSelector:@selector(allHeaderFields)])
             {
                 
                 File *imageFile = [[File alloc] init];
                 imageFile.FullImage = [UIImage imageWithData:data];
                 imageFile.filedata  = [fileDataLink absoluteString];
                 
                 
                 NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:2];
                 [dictionary setObject:data forKey:@"imageData"];
                 [dictionary setObject:fileDataLink.absoluteString forKey:@"imageDataLink"];
                 NSLog(@"APIII%@",dictionary);
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"SugarSyncImageDownloaded" object:nil userInfo:dictionary];
                 
                 if ([self.delegate respondsToSelector:@selector(SugarSync:downloadedFileSuccessfullyWithName:withData:)])
                 {
                     [self.delegate SugarSync:self downloadedFileSuccessfullyWithName:name withData:data];
                 }
             }
         }
     }];
    
    
}
*/
- (void)SSuploadFileAtFolderPath: (NSString *)folderPath withFileDataPath:(NSString *)path withName:(NSString *)fileName accessToken:(NSString *)token
{
        
    folderPath = [folderPath stringByDeletingLastPathComponent];  // to delete "/content" suffix from URL
    NSURL *url = [NSURL URLWithString:folderPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString * str = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>" "<file>"
                      "<displayName>%@</displayName>"
                      "</file>",fileName ];
    [request setHTTPBody:[str dataUsingEncoding:NSUTF8StringEncoding]];

    [NWURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response_, NSData *data, NSError *error){
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)response_;
    
    if ([response respondsToSelector:@selector(allHeaderFields)])
    {
        if ([response statusCode] >= 200 && [response statusCode] < 300 )
        {
            NSDictionary *createdFileMetadatInfoDict = [response allHeaderFields];
            NSString *fileToUploadDestinationUrlString = [createdFileMetadatInfoDict valueForKey:@"Location"];
            fileToUploadDestinationUrlString = [fileToUploadDestinationUrlString stringByAppendingPathComponent:@"data"];  // appending "/data" to URL of newly created file
            
            NSURL *url = [NSURL URLWithString:fileToUploadDestinationUrlString];
            imageRequest = [NSMutableURLRequest requestWithURL:url];
            
            [imageRequest setHTTPMethod:@"PUT"];
            [imageRequest setValue:token forHTTPHeaderField:@"Authorization"];
            
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
            NSData *fileData = [fileHandle availableData];
            [imageRequest setHTTPBody:fileData];
            
            [NWURLConnection sendAsynchronousRequest:imageRequest queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *responce_, NSData *data, NSError *error)
            {
            
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)responce_;
            if ([response respondsToSelector:@selector(allHeaderFields)])
            {
                if ([response statusCode] >= 200 && [response statusCode] < 300)
                {
                    NSLog(@"FIle Uploaded SuccessFUlly");
                    
                    if ([self.delegate respondsToSelector:@selector(SugarSync:finishUploadingFileWithName:withError:)])
                    {
                        [self.delegate SugarSync:self finishUploadingFileWithName:fileName withError:nil];
                    }
                    
                }
                else
                {
                    NSLog(@"Error in uploading Data to File");
                    if ([self.delegate respondsToSelector:@selector(SugarSync:finishUploadingFileWithName:withError:)])
                    {
                        [self.delegate SugarSync:self finishUploadingFileWithName:fileName withError:error];
                    }
                    
                }
            }
            }];
        }
        
        else
        {
            NSLog(@"Error in creating New File in the Folder");
        }
        
    }
    else
    {
        NSLog(@"Error in service");
    }
    }];
}

- (BOOL)SSDeleteFileWithLink:(NSString *)link withAccessToken:(NSString *)token
{

    NSURL *url = [NSURL URLWithString:link];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    
    NSHTTPURLResponse *response = NULL;
    NSError *requestError = NULL;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&requestError];
    
    if ([response respondsToSelector:@selector(allHeaderFields)])
    {
        if (requestError == NULL)
        {
             return TRUE;
        }

        else
        {
            return FALSE;
        }
    }
    
    return FALSE;
}
-(void)cancelRequest
{
    NSLog(@"OPereation Queue Count  %d",_sharedAPI.operationsArray.count);
    for (NSOperationQueue *downloadOperationQueue in _sharedAPI.operationsArray) {
         [downloadOperationQueue cancelAllOperations];
    }
    [_sharedAPI.operationsArray removeAllObjects];
}

@end
