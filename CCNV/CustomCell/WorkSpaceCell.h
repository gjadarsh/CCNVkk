//
//  WorkSpaceCell.h
//  CCNV
//
//  Created by  Linksware Inc. on 9/28/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class File;
@interface WorkSpaceCell : UITableViewCell
{
    IBOutlet UILabel *lblsize,*lbldateTime,*lblTitle;
    IBOutlet UIImageView *fileTypeImage;
    BOOL isFolder;
    File *file;
    int arrContentListCount;
    int i;
    
    NSMutableData *ResponseData1;
    NSURLConnection *Connection1;
    
    NSMutableData *ResponseData2;
    NSURLConnection *Connection2;
    
    NSMutableData *ResponseData3;
    NSURLConnection *Connection3;

}
@property(nonatomic,readwrite)int arrContentListCount;
- (void) fillCellWithObject:(File*)fileObj;
- (void) getFileInfo;
-(NSString *)size:(NSString *)size;
- (id)ChangeStringSize:(id)value;
-(void)LoadOwnerDetail;
@end
