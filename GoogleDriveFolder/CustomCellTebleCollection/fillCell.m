//
//  fillCell.m
//  sampleDrive
//
//  Created by Project Development Department on 2014/03/26.
//  Copyright (c) 2014年 Project Development Department. All rights reserved.
//

#import "fillCell.h"
#import "UIImageView+WebCache.h"
@implementation fillCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
       
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.contentView.layer.borderWidth=2;
    self.contentView.layer.borderColor=(__bridge CGColorRef)([UIColor redColor]);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setDriveFile:(GTLDriveFile *)driveFile
{
    self.fileSizeLabel.hidden=NO;
    self.fileCreatedDate.hidden=NO;

    self.fileSizeLabel.text= [driveFile.mimeType isEqualToString:@"application/vnd.google-apps.folder"]?nil:[self ChangeStringSize:driveFile.fileSize];
    self.fileNameLabel.text=driveFile.title;
//    if ([driveFile.mimeType rangeOfString:@"image/"].location != NSNotFound) {
//        [self addDateImageFile:driveFile];
//    }else{
        self.fileCreatedDate.text=driveFile.modifiedDate.stringValue;

   // }
    self.fileNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.fileCreatedDate.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.iconImage setImageWithURL:[NSURL URLWithString:driveFile.thumbnailLink.length<=0?driveFile.iconLink:driveFile.thumbnailLink]];


}
- (id)ChangeStringSize:(id)value
{
    
    double convertedValue = [value doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (convertedValue >= 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}
-(void)addDateImageFile:(GTLDriveFile *)driveFile{
    self.fileCreatedDate.text=driveFile.imageMediaMetadata.date.length>0?driveFile.imageMediaMetadata.date: driveFile.createdDate.stringValue;
}
@end
