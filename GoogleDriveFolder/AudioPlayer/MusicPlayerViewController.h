//
//  MusicPlayerViewController.h
//  CCNV
//
//  Created by Project Development Department on 2014/04/09.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GTLDriveFile.h"
#import "CustomAudioPlayer.h"
@interface MusicPlayerViewController : UIViewController< AVAudioPlayerDelegate>
@property (nonatomic,retain) GTLDriveFile *driveFile;

@property (nonatomic, strong) CustomAudioPlayer *customAudioPlayer;
@property (weak, nonatomic) IBOutlet UISlider *currentTimeSlider;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UILabel *timeElapsed;


@property BOOL isPaused;
@property BOOL scrubbing;
@property NSTimer *timer;





@end
