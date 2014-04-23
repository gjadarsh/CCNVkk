//
//  MoviePlayerController.m
//  CCNV
//
//  Created by  Linksware Inc. on 9/14/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import "MoviePlayerController.h"
#import "AppDelegate.h"
@implementation MoviePlayerController
@synthesize moviePlayer,fileUrl,objFile,strContent;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    isPlaying=false;
    
       ///set UItextField in Title View /////////////////////////
    txtTitle =[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [txtTitle setBackgroundColor:[UIColor whiteColor]];
    txtTitle.text=objFile.strDisplayName;
    txtTitle.delegate=self;
    txtTitle.hidden=TRUE;
    
    ///set UIlabel in Title View /////////////////////////
    lblTitle =[[UILabel alloc] initWithFrame:txtTitle.frame];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    lblTitle.text=objFile.strDisplayName;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.textAlignment=NSTextAlignmentCenter;
    
    self.navigationItem.titleView=lblTitle;
    
    self.navigationController.navigationBarHidden=FALSE;
    
       /// adding action button for edit option 
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(Share:)];
  
     // init player
    [self initPlayer];
      [super viewDidLoad];
    
    
    ///set scrollview content size 
    if(!isIpad){
        
        [scrollview setContentSize:CGSizeMake(320, 460)];}
    else
        [scrollview setContentSize:CGSizeMake(768, 1004)];     
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopDownload) name:@"stopDownload" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initPlayer) name:@"TokenRefreshed" object:nil];
    [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.4];
    [super viewWillAppear:YES];
}

/**
 * this method will stop current download .
 * and return on previous view.
 */

- (void)stopDownload {
    [Connection1 cancel];
    [Connection3 cancel];
    Connection1 = nil;
    Connection3 = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewDidDisappear:(BOOL)animated {
    if(!isSendingMail){
        [self cancel];}
    [super viewDidDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - share
/**
* this method open actionsheet to show share option
*/
-(void)Share:(id)sender{
    
   //open UIActionSheet
        actionsSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"Email", nil),NSLocalizedString(@"Save", nil),@"Rename", nil] ;
        actionsSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [actionsSheet showFromBarButtonItem:sender animated:YES];
        } else {
            [actionsSheet showInView:self.view];
        }
}

#pragma mark - updatefileinfo
/**
 * this method will update file info like displayname to sugersync server
 * it starts new connection to update file info.
 */
-(void)UpdateFileInfo{
    
    //update file info 
    NSString *strDisplayname=(__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                                   NULL,
                                                                                                   (__bridge_retained CFStringRef)txtTitle.text,
                                                                                                   NULL,
                                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                   kCFStringEncodingUTF8 );
    NSString *xmlString = [NSString stringWithFormat:
                           @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>                           <file><displayName>%@</displayName></file>",strDisplayname];
    
    NSData *thumbsupData = [xmlString dataUsingEncoding: NSASCIIStringEncoding];
    
    NSString *urlString =[NSString stringWithFormat:@"%@",objFile.ref];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
    //NSLog(@"URL = %@",xmlString);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    //NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"PUT"];
    [theRequest addValue:@"application/xml; charset=UTF-8" forHTTPHeaderField:@"Content-type"];
    [theRequest setHTTPBody:thumbsupData];
    
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
        [ApplicationDelegate.HUD setHidden:TRUE];
        [ApplicationDelegate hideCloseButton];
    }else{
        Connection3 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
        if(Connection3) {
            ResponseData3 = [[NSMutableData alloc] init];
        }
    
    }
    /*
     PUT https://api.sugarsync.com/file/:sc:566494:6552993_66025 HTTP/1.1
     Authorization: https://api.sugarsync.com/authorization/ZSIUGY3D45RyDa6Gmd...
     User-Agent: Jakarta Commons-HttpClient/3.1
     Host: api.sugarsync.com
     Content-Length: 755
     Content-Type: application/xml; charset=UTF-8
     
     <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
     <file>
     <displayName>PineCreek5_120411.jpg</displayName>
     <dsid>/sc/566494/6552993_66025</dsid>
     <timeCreated>2011-12-05T08:05:21.000-08:00</timeCreated>
     <parent>https://api.sugarsync.com/folder/:sc:566494:4</parent>
     <size>1502167</size>
     <lastModified>2011-12-04T09:26:42.000-08:00</lastModified>
     <mediaType>image/jpeg</mediaType>
     <presentOnServer>true</presentOnServer>
     <fileData>https://api.sugarsync.com/file/:sc:566494:6552993_66025/data</fileData>
     <versions>https://api.sugarsync.com/file/:sc:566494:6552993_66025/version</versions>
     <publicLink enabled="false"/>
     <image>
     <height>3264</height>
     <width>1952</width>
     <rotation>0</rotation>
     </image>
     </file>
     */
}

#pragma mark - actionsheetdelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        [self MailFile]; // do mail 
    }
    else if (buttonIndex==1)
    {
        [self SaveToLib:nil]; //save file to divice Lib 
    }
    else if (buttonIndex==2)
    {
        //reset navigation bar
        self.navigationItem.rightBarButtonItem=nil;
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(DoneClicked)];
        lblTitle.hidden=TRUE;
        txtTitle.hidden=FALSE;
        self.navigationItem.titleView=txtTitle;
        [txtTitle becomeFirstResponder];
        
    }
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark Mail Compose Delegate
/**
 * this method will open MailComposeViewController,and add attachment in mail
 * it will show alert if mail account is not configered in device.
 */
-(void)MailFile
{
    isSendingMail=TRUE;
    NSString *path=[self GetFileUrl]; //get file path 
    NSData *data=[NSData dataWithContentsOfFile:path];
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *emailer = [[MFMailComposeViewController alloc] init];
        emailer.mailComposeDelegate = self;
        NSString *mymetype=[objFile.strDisplayName pathExtension];
        
        ///add attachemnt in mail 
        [emailer addAttachmentData:data mimeType:mymetype fileName:objFile.strDisplayName];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            emailer.modalPresentationStyle = UIModalPresentationPageSheet;
        }
        [self presentViewController:emailer animated:YES completion:nil];
    }
    else{
        
        /// pop up alert if mail account is not Configured  
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"Configure your mail account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

/**
 *  MFMailComposerDelegate method
 * it will show alert if any error arise
 */
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (result == MFMailComposeResultFailed) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Email", nil)
                                                        message:NSLocalizedString(@"Email failed to send. Please try again.", nil)
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil] ;
		[alert show];
    }
    isSendingMail=FALSE;
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -player
/**
 * this method will start loading file data from server if file is not in doucment dir of application
 and if file is already downloaded before it will init the player and play the file
 */
-(void)initPlayer{
    
    if(![[NSFileManager defaultManager]fileExistsAtPath:[self GetFileUrl]]){
    
        ///load file data if ifle is not in document dir of application
       
        [ApplicationDelegate.HUD setHidden:FALSE];
        [ApplicationDelegate showCloseButton];
        NSString *urlString =objFile.filedata;
        NSURL *theURL = [NSURL URLWithString:urlString]; 
          //NSLog(@"URL = %@",urlString);
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
        //NSLog(@"Access token = %@",ApplicationDelegate.accessToken);
        [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
        [theRequest setHTTPMethod:@"GET"];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
        
        if(ApplicationDelegate.connectionRequired){
            SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
            [ApplicationDelegate.HUD setHidden:TRUE];
            [ApplicationDelegate hideCloseButton];
        }else{
            Connection1 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
       
            if(Connection1) {
            
                ResponseData1 = [[NSMutableData alloc] init];
            }
        }
     }
     else{
         [self Play]; // play if file already loaded  
     }
}

/**
 * this method returns string value of temp file path.
 
 */
-(NSString*)GetFileUrl
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSString *path=[NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],objFile.strDisplayName];
    //NSLog(@"%@",path);
    return path;
}

/**
 * this method will call method to update file info like displayname to sugersync server
 * and reset the navigation bar
 */
-(void)DoneClicked{
    
    [self UpdateFileInfo];/// update file data
    
    
    ///reset navigation bar 
    self.navigationItem.rightBarButtonItem=nil;
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(Share:)];
    lblTitle.hidden=FALSE;
    txtTitle.hidden=TRUE;
    self.navigationItem.titleView=lblTitle;
}

/**
 * it stops the movie/audio player
 * invalidate the timer
 * and remove the downloaded temp file
 */
-(void)cancel
{
    timer=nil;
    [self.moviePlayer stop]; // stop movie
    
    ///remove temp file
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSString *path=[NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],objFile.strDisplayName];
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];

}

/**
 * This method will save compatible videos to library
 */
-(IBAction)SaveToLib:(id)sender
{
    
   
    if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(fileUrl))
    {
        ///save video in device lib
        UISaveVideoAtPathToSavedPhotosAlbum(fileUrl, nil, nil, nil);
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@" Video successfully saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else{
        
        //pops alert if file forate is not suported by device
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"Error in saving Video." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
    
}
#pragma mark - HTTP connection methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    if (connection == Connection1)
        ResponseData1 = nil;   
    
   else if (connection == Connection3)
        ResponseData3 = nil;
      NSLog(@"Error = %@", error);
    
     [ApplicationDelegate.HUD setLabelText:@"Loading..."];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == Connection1){
        NSLog(@"content length : %llu",[response expectedContentLength]);
        expectedBytes =(long) [response expectedContentLength];
        [ResponseData1 setLength:0];
    //    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    //    NSDictionary* headers = [httpResponse allHeaderFields];
     //   NSLog(@"Header Response = %@",headers);
    } 
    else if (connection == Connection3){
        [ResponseData3 setLength:0];
      //  NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
     //   NSDictionary* headers = [httpResponse allHeaderFields];
      //  NSLog(@"Header Response = %@",headers);
    }
       
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == Connection1) {
        [ResponseData1 appendData:data];
        NSInteger receivedLen = [data length];
        bytesReceived = (bytesReceived + receivedLen);
        
        if(expectedBytes != NSURLResponseUnknownLength) {
            progressCount = ((bytesReceived/(float)expectedBytes)*100)/100;
            percentComplete = progressCount*100;
//            NSLog(@"process %f%%",percentComplete);
            [ApplicationDelegate.HUD setLabelText:[NSString stringWithFormat:@"%0.0f%% Completed",percentComplete]];
        }
    }
    else if (connection == Connection3) {
        [ResponseData3 appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes{
    NSLog(@"downloaded %llu total %llu",totalBytesWritten,expectedTotalBytes);
}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes {
    NSLog(@"downloaded %llu total %llu",totalBytesWritten,expectedTotalBytes);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [ApplicationDelegate.HUD setLabelText:@"Loading..."];
    if (connection == Connection1) { // for file data responce
        NSString *responsestring= [[NSString alloc] initWithData:ResponseData1 encoding:NSUTF8StringEncoding];
        //  NSLog(@"responsestring = %@",responsestring);
        NSString *start1 = @"<h3>";
        NSRange starting1 = [responsestring rangeOfString:start1];
        if(starting1.location != NSNotFound){
            NSString *end1 = @"</h3>";
            NSRange ending1 = [responsestring rangeOfString:end1];
            NSString *str1 = [responsestring substringWithRange:NSMakeRange(starting1.location + starting1.length, ending1.location - (starting1.location + starting1.length))];
           ApplicationDelegate.TokenExpired=[str1 isEqualToString:Authtoken];
        }
        
        if(ApplicationDelegate.TokenExpired){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshAccessToken" object:nil];
           ApplicationDelegate.TokenExpired=FALSE;
        }
        else{
                
            NSString *path=[self GetFileUrl];
            [[NSFileManager defaultManager] createFileAtPath:path
                                                        contents:ResponseData1
                                                      attributes:nil ];
                fileUrl=path;
                                
                [ApplicationDelegate.HUD setHidden:YES];
                [ApplicationDelegate hideCloseButton];
                [self Play];
            }
            
        
    }
    else if (connection == Connection3) { /// update file data responce
        lblTitle.text=txtTitle.text;
    }
}

/**
 * This mathod play a slected file with movie player
 */

#pragma mark - player
-(void)Play
{
   
    NSURL    *url = [NSURL fileURLWithPath:[self GetFileUrl]];
    if (self.moviePlayer != nil){
        [self stopPlayingVideo:nil];
    }
    
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];

    if (self.moviePlayer != nil){
        //add notification observer for movie player
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(videoHasFinishedPlaying:)
         name:MPMoviePlayerPlaybackDidFinishNotification
         object:self.moviePlayer];
        
        self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        //set player propeties
        
        [moviePlayer.view setFrame:MvView.bounds];
        [self.moviePlayer setControlStyle:MPMovieControlStyleNone];
        moviePlayer.view.center = MvView.center;
        moviePlayer.view.userInteractionEnabled=FALSE;
        isPlaying=TRUE;
      
        [MvView addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:NO
                               animated:NO];
        
        //play 
        [self.moviePlayer play];
        
        //start timer to chnage progress value 
        [self performSelector:@selector(StartTimer) withObject:nil afterDelay:1.0f];
      
    }
}

/**
 * This mathod maintain seekbar value corresponding to media file length
 */

-(void)StartTimer{
    //reset progress value 
    progress.minimumValue = 0;
    progress.maximumValue = moviePlayer.duration;
     
    //start timer 
    timer=nil;
    timer= [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(ChngeSliderValue) userInfo:nil repeats:YES];
}

/**
 * This mathod call when a user want temporary stop a file.
 * And can play again.
 */

-(IBAction)PlayPause:(id)sender
{
   
    if(isPlaying){
        [moviePlayer pause]; //Pause 
        [btnPlay setImage:[UIImage imageNamed:@"play_btn.png"]];
   
    }else{
        progress.minimumValue = 0;
        progress.maximumValue = moviePlayer.duration;
     
        //start timer 
        [timer invalidate];
        timer= [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(ChngeSliderValue) userInfo:nil repeats:YES];
       
        
        [moviePlayer play];//Play 
        [btnPlay setImage:[UIImage imageNamed:@"Pause_btn.png"]];

    }
    isPlaying=!isPlaying; //set playing flag
}

/**
 * this method called by timer and change the slider value
 * and when audio/moview is not playing it invalidates the timer.
 */
-(void)ChngeSliderValue
{
       //set progressbar value
    if(isPlaying){
        //NSLog(@"%f",progress.value);

        progress.value = moviePlayer.currentPlaybackTime;

    }
    else{
        [timer invalidate]; 
    }
}

#pragma mark - UIInterfaceOrientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    [moviePlayer.view setFrame:MvView.frame];
    moviePlayer.view.center = MvView.center;
    
    if(isIpad) {
        if(toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft||toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
            moviePlayer.view.frame=CGRectMake(0, 0, 1024, 768); //set frame of player
        }
    }
  
  //  NSLog(@"%@",NSStringFromCGRect(moviePlayer.view.frame));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  //set frame of player
    [UIView beginAnimations:@"anim" context:nil];
    [moviePlayer.view setFrame:MvView.frame];
    moviePlayer.view.center = MvView.center;
    [UIView commitAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    [moviePlayer.view setFrame:MvView.frame];
    moviePlayer.view.center = MvView.center;

    if(isIpad) {
        if(interfaceOrientation==UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight){
            moviePlayer.view.frame=CGRectMake(0, 0, 1024, 768);
        }
    }
    
     return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - movie player
/**
 * this method will set value for isRepeat flag .
 * and also change image for repeat button.
 */
-(IBAction)repeat:(id)sender
{
    isRepeat=!isRepeat; //set repeat flag 
    UIBarButtonItem *repeatBtn = (UIBarButtonItem*) sender;
    if(isRepeat) {
        if(!isPlaying)
            [self PlayPause:nil];
        [repeatBtn setStyle:UIBarButtonItemStyleDone];
    }
    else {
        [repeatBtn setStyle:UIBarButtonItemStylePlain];
    }
}


/**
 * this method will stop playing movie.
 */
- (void) stopPlayingVideo:(id)paramSender {
    if (self.moviePlayer != nil){

        [self.moviePlayer stop]; //Stop playing
        progress.value = 0;
        [btnPlay setImage:[UIImage imageNamed:@"play_btn.png"]];
    
    }
}
- (void) viewDidUnload{
   // self.playButton = nil;
    [self stopPlayingVideo:nil];///stop playing video
    
    
    self.moviePlayer = nil;
    
    //remove notification observer of player 
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:self.moviePlayer];
    [super viewDidUnload];
}

/**
 * MPMoviePlayerdelegate method
 */
- (void) videoHasFinishedPlaying:(NSNotification *)paramNotification{
    /* Find out what the reason was for the player to stop */
  //  timer=nil;
    
    isPlaying=FALSE;
    [timer invalidate];
    NSNumber *reason =
    [paramNotification.userInfo
     valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    if (reason != nil){
        NSInteger reasonAsInteger = [reason integerValue];
        switch (reasonAsInteger){
            case MPMovieFinishReasonPlaybackEnded:{
                /* The movie ended normally */
                break; }
            case MPMovieFinishReasonPlaybackError:{
                /* An error happened and the movie ended */
                break; 
            }
            case MPMovieFinishReasonUserExited:{
                /* The user exited the player */
                break;
            } 
        }
        //NSLog(@"Finish Reason = %ld", (long)reasonAsInteger);
        if(isRepeat)
        {

            [self PlayPause:nil]; //play again 
        }
        else{
            [self stopPlayingVideo:nil]; // stop video
        }
    } 
}
-(IBAction)progressValueChange:(id)sender{
    
}
-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL
{
    
}
@end