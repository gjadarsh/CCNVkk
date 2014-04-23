//
//  fileCollectionCell.m
//  sampleDrive
//
//  Created by Project Development Department on 2014/03/27.
//  Copyright (c) 2014年 Project Development Department. All rights reserved.
//

#import "fileCollectionCell.h"
#import "UIImageView+WebCache.h"
@implementation fileCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
#pragma Setter Method of driveFile
-(void)setDriveFile:(GTLDriveFile *)driveFile
{
    if ([driveFile.mimeType rangeOfString:@"image/"].location != NSNotFound) {
        [self addDateImageFile:driveFile];
    }else{
        self.filedateLabel.text=driveFile.createdDate.stringValue;
        
    }
    self.fileNameLabel.text=driveFile.title;
    self.fileNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.filedateLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

    [self.iconImage setImageWithURL:[NSURL URLWithString:driveFile.thumbnailLink.length<=0?driveFile.iconLink:driveFile.thumbnailLink]];
    
    
}
-(void)addDateImageFile:(GTLDriveFile *)driveFile{
    self.filedateLabel.text=driveFile.imageMediaMetadata.date.length>0?driveFile.imageMediaMetadata.date: driveFile.createdDate.stringValue;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
