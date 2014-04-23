//
//  File.h
//  CCNV
//
//  Created by  Linksware Inc. on 9/26/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface File : NSObject
{
    NSString *strDisplayName;
    NSString *strMediaType;
    NSString *ref;
    NSString *strDateTime;
    NSString *strSize;
    NSString *filedata;
    NSString *dateStr;
    NSString *strMovieThumnailUrl;
    NSString *strFileAuthor;
    NSString *strFileownerName;
    NSString *strLastModified;
    BOOL isInfoLoaded;
    BOOL isPublick;
    int size;
    UIImage *thumbnail;
    UIImage *FullImage;
    
    NSURLConnection *Connection2;
    NSMutableData *ResponseData2;
    NSURLConnection *Connection1;
    NSMutableData *ResponseData1;
}
@property(nonatomic)BOOL isPublick;
@property(nonatomic,strong)UIImage *FullImage;
@property(nonatomic,strong)UIImage *thumbnail;
@property(nonatomic,readwrite)int size;
@property(nonatomic)BOOL isInfoLoaded;
@property(nonatomic,strong) NSString *strFileownerName;
@property(nonatomic,strong) NSString *strFileAuthor;
@property(nonatomic,strong) NSString *filedata;
@property(nonatomic,strong) NSString *strDisplayName;
@property(nonatomic,strong) NSString *strMediaType;
@property(nonatomic,strong) NSString *ref;
@property(nonatomic,strong) NSString *strDateTime;
@property(nonatomic,retain) NSString *strSize;
@property(nonatomic,strong) NSString *dateStr;
@property(nonatomic,strong) NSString *strMovieThumnailUrl;
@property(nonatomic,strong) NSString *strLastModified;

-(void)loadThumbnailImage;
- (void) getFileInfo;
@end
