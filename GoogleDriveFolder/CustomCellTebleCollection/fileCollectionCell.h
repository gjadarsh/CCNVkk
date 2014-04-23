//
//  fileCollectionCell.h
//  sampleDrive
//
//  Created by Project Development Department on 2014/03/27.
//  Copyright (c) 2014年 Project Development Department. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLDriveFile.h"
@interface fileCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *filedateLabel;
@property (nonatomic,retain) GTLDriveFile *driveFile;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@end
