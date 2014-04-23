//
//  fillCell.h
//  sampleDrive
//
//  Created by Project Development Department on 2014/03/26.
//  Copyright (c) 2014年 Project Development Department. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLDriveFile.h"
@interface fillCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (nonatomic,retain) GTLDriveFile *driveFile;
@property (weak, nonatomic) IBOutlet UILabel *fileCreatedDate;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@end
