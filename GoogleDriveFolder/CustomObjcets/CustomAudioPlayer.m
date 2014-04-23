//
//  CustomAudioPlayer.m
//  CCNV
//
//  Created by Project Development Department on 2014/04/10.
//
//

#import "CustomAudioPlayer.h"

@implementation CustomAudioPlayer
/*
 * Init the Player with Filename and FileExtension
 */
- (void)initPlayer:(NSString*) audioFile 
{
    NSURL *url = [NSURL fileURLWithPath:audioFile];
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
}

/*
 * Simply fire the play Event
 */
- (void)playAudio {
    [self.audioPlayer play];
}

/*
 * Simply fire the pause Event
 */
- (void)pauseAudio {
    [self.audioPlayer pause];
}

/*
 * Format the float time values like duration
 * to format with minutes and seconds
 */
-(NSString*)timeFormat:(float)value{
    
    float minutes = floor(lroundf(value)/60);
    float seconds = lroundf(value) - (minutes * 60);
    
    int roundedSeconds = lroundf(seconds);
    int roundedMinutes = lroundf(minutes);
    
    NSString *time = [[NSString alloc]
                      initWithFormat:@"%d:%02d",
                      roundedMinutes, roundedSeconds];
    return time;
}

/*
 * To set the current Position of the
 * playing audio File
 */
- (void)setCurrentAudioTime:(float)value {
    [self.audioPlayer setCurrentTime:value];
}

/*
 * Get the time where audio is playing right now
 */
- (NSTimeInterval)getCurrentAudioTime {
    return [self.audioPlayer currentTime];
}

/*
 * Get the whole length of the audio file
 */
- (float)getAudioDuration {
    return [self.audioPlayer duration];
}
- (void)stopAudio{
    [self.audioPlayer stop];
    self.audioPlayer=nil;
}
@end
