//
//  FileViewViewController.h
//  CCNV
//
//  Created by Project Development Department on 2014/04/09.
//
//

#import <UIKit/UIKit.h>
#import "GTLDriveFile.h"
#import "GTLServiceDrive.h"
@interface FileViewViewController : UIViewController
@property (nonatomic,retain) GTLDriveFile *driveFile;
@property (nonatomic, retain) GTLServiceDrive *driveService;

@end
