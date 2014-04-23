//
//  CustomAudioPlayer.h
//  CCNV
//
//  Created by Project Development Department on 2014/04/10.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CustomAudioPlayer : NSObject

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

// Public methods
- (void)initPlayer:(NSString*) audioFile;
- (void)playAudio;
- (void)pauseAudio;
- (void)setCurrentAudioTime:(float)value;
- (float)getAudioDuration;
- (NSString*)timeFormat:(float)value;
- (NSTimeInterval)getCurrentAudioTime;
- (void)stopAudio;

@end
