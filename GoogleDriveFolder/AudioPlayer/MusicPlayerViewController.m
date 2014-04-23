//
//  MusicPlayerViewController.m
//  CCNV
//
//  Created by Project Development Department on 2014/04/09.
//
//

#import "MusicPlayerViewController.h"

@interface MusicPlayerViewController ()<UIAlertViewDelegate>
@property (strong, nonatomic) AVAudioPlayer *audioPlayer; // This is used by playerControl.

@end

@implementation MusicPlayerViewController
{
    GTMHTTPFetcher *fileFetcher;

}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.customAudioPlayer = [[CustomAudioPlayer alloc] init];

    [self downloadFileContent];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewDidDisappear:(BOOL)animated
{
    if (self.customAudioPlayer) {
        [self.customAudioPlayer stopAudio];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)downloadFileContent
{
    
    UIAlertView *alert =
    [self showWaitIndicator:@"Downloading.."];
    alert.delegate=self;
        [GoogleDriveManager downloadFileContentWithFile:self.driveFile completionBlock:^(NSData *downloaded, NSError *error) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        
        if (!error) {
            NSLog(@"Success");
            [self writeFileToDocumentDirectory:downloaded];
            
        }else{
            [self showAlert:@"Error" message:[error localizedDescription]];
            
        }
        
    } progressBlock:^(NSData *reciveData, GTMHTTPFetcher *fetcher) {
        fileFetcher=fetcher;
        NSString *messageString=[NSString stringWithFormat:@"%.f%%Downloaded",(100.0 / [self.driveFile.fileSize longLongValue] * [reciveData length])];
        alert.message=messageString;
    }];
}
#pragma mark -Custom Alert
- (UIAlertView*)showWaitIndicator:(NSString *)title
{
    UIAlertView *progressAlert;
    progressAlert = [[UIAlertView alloc] initWithTitle:title
                                               message:@"Please wait..."
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"Cancel",nil];
    [progressAlert show];
    UIActivityIndicatorView *activityView;
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.center = CGPointMake(progressAlert.bounds.size.width / 2,
                                      progressAlert.bounds.size.height - 45);
    [progressAlert addSubview:activityView];
    [activityView startAnimating];
    return progressAlert;
}
// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle: title
                                       message: message
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
    [alert show];
}
-(void)writeFileToDocumentDirectory:(NSData *)content{
 
    NSString *finalPath=[self getDocumentDirectoryPath]; //check your path correctly and provide your name dynamically
    NSLog(@"finalpath--%@",finalPath);
    if(content)
        [content writeToFile:finalPath atomically:YES];
   // [self setAudioPlayerWithFilePath:finalPath];
    [self setupAudioPlayer:finalPath];
    
}
#pragma mark-Remove Data In document directory
-(void)removeFileFromDocumentDirectory{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *finalPath=[self getDocumentDirectoryPath]; //check your path correctly and provide your name dynamically

    BOOL isMyFileThere = [[NSFileManager defaultManager] fileExistsAtPath:finalPath];
    if(isMyFileThere){
        
        [fileManager removeItemAtPath:finalPath error:NULL];
    }
}
-(NSString *)getDocumentDirectoryPath
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[paths objectAtIndex:0];
    // NSString *fileExtention=[_driveFile.mimeType  isEqualToString:@"application/pdf"]?@"pdf":[_driveFile.mimeType rangeOfString:@"video/"].location != NSNotFound?@"mov":@"docx";
    NSString *finalPath=[documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.mp3",_driveFile.identifier]];
    //check your path correctly and provide your name dynamically
    NSLog(@"finalpath--%@",finalPath);
    return finalPath;
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%d",buttonIndex) ;
    if (buttonIndex == 0){
        //cancel clicked ...do your action
        [fileFetcher stopFetching];
        fileFetcher=nil;
        [self removeFileFromDocumentDirectory];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)setupAudioPlayer:(NSString*)fileName
{
    //insert Filename & FileExtension
   // NSString *fileExtension = @"mp3";
    
    //init the Player to get file properties to set the time labels
    [self.customAudioPlayer initPlayer:fileName];
    self.currentTimeSlider.maximumValue = [self.customAudioPlayer getAudioDuration];
    
    //init the current timedisplay and the labels. if a current time was stored
    //for this player then take it and update the time display
    self.timeElapsed.text = @"0:00";
    
    self.duration.text = [NSString stringWithFormat:@"-%@",
                          [self.customAudioPlayer timeFormat:[self.customAudioPlayer getAudioDuration]]];
    
}

/*
 * PlayButton is pressed
 * plays or pauses the audio and sets
 * the play/pause Text of the Button
 */
- (IBAction)playAudioPressed:(id)playButton
{
    [self.timer invalidate];
    //play audio for the first time or if pause was pressed
    if (!self.isPaused) {
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"audioplayer_pause.png"]
                                   forState:UIControlStateNormal];
        
        //start a timer to update the time label display
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTime:)
                                                    userInfo:nil
                                                     repeats:YES];
        
        [self.customAudioPlayer playAudio];
        self.isPaused = TRUE;
        
    } else {
        //player is paused and Button is pressed again
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"audioplayer_play.png"]
                                   forState:UIControlStateNormal];
        
        [self.customAudioPlayer pauseAudio];
        self.isPaused = FALSE;
    }
}

/*
 * Updates the time label display and
 * the current value of the slider
 * while audio is playing
 */
- (void)updateTime:(NSTimer *)timer {
    //to don't update every second. When scrubber is mouseDown the the slider will not set
    if (!self.scrubbing) {
        self.currentTimeSlider.value = [self.customAudioPlayer getCurrentAudioTime];
    }
    self.timeElapsed.text = [NSString stringWithFormat:@"%@",
                             [self.customAudioPlayer timeFormat:[self.customAudioPlayer getCurrentAudioTime]]];
    
    self.duration.text = [NSString stringWithFormat:@"-%@",
                          [self.customAudioPlayer timeFormat:[self.customAudioPlayer getAudioDuration] - [self.customAudioPlayer getCurrentAudioTime]]];
}

/*
 * Sets the current value of the slider/scrubber
 * to the audio file when slider/scrubber is used
 */
- (IBAction)setCurrentTime:(id)scrubber {
    //if scrubbing update the timestate, call updateTime faster not to wait a second and dont repeat it
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(updateTime:)
                                   userInfo:nil
                                    repeats:NO];
    
    [self.customAudioPlayer setCurrentAudioTime:self.currentTimeSlider.value];
    self.scrubbing = FALSE;
}

/*
 * Sets if the user is scrubbing right now
 * to avoid slider update while dragging the slider
 */
- (IBAction)userIsScrubbing:(id)sender {
    self.scrubbing = TRUE;
}






@end
