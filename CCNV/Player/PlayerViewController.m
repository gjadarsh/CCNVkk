//
//  PlayerViewController.m
//  CCNV
//
//  Created by  Linksware Inc. on 9/12/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import "PlayerViewController.h"
#import "AppDelegate.h"
@implementation PlayerViewController
@synthesize fileUrl,progress,ImgAlbumArt,strContent,objFile,isRepeat;
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
    if(ApplicationDelegate.player)
    {
         ApplicationDelegate.player=nil;
              
    }
    self.navigationItem.hidesBackButton=FALSE;
    
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
    
    progress.value=0;
    
    /// adding action button for edit option 
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(Share:)];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initPlayer) name:@"TokenRefreshed" object:nil];
    // init player
    
    [self initPlayer];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


#pragma mark - share 
/**
 * this method open actionsheet to show share option 
 */
-(void)Share:(id)sender{
    // open action Sheet
    
        actionsSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"Email", nil),@"Rename",nil] ;
        
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
    /// update file info to server
    
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
    
    //   NSLog(@"URL = %@",xmlString);
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

#pragma mark - UIactionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        [self MailFile]; /// call method to do mail File 
    }
    else if (buttonIndex==1)
    {
        
        ///set Title View 
        self.navigationItem.rightBarButtonItem=nil;
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(DoneClicked)];
        lblTitle.hidden=TRUE;
        txtTitle.hidden=FALSE;
        self.navigationItem.titleView=txtTitle;
        [txtTitle becomeFirstResponder];
        
    }
}

/**
 * this method will call method to update file info like displayname to sugersync server
 * and reset the navigation bar
 */
-(void)DoneClicked{
    
    /// call update file method
    [self UpdateFileInfo];
    
    /// set titile view
    self.navigationItem.rightBarButtonItem=nil;
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(Share:)];
    lblTitle.hidden=FALSE;
    txtTitle.hidden=TRUE;
    self.navigationItem.titleView=lblTitle;

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
    NSString *path=[self GetFileUrl]; // get file path 
    NSData *data=[NSData dataWithContentsOfFile:path];
    
     if ([MFMailComposeViewController canSendMail]) {
         MFMailComposeViewController *emailer = [[MFMailComposeViewController alloc] init];
         emailer.mailComposeDelegate = self;
         NSString *mymetype=[objFile.strDisplayName pathExtension];
        
         /// add attachment in mail 
         [emailer addAttachmentData:data mimeType:mymetype fileName:objFile.strDisplayName];
         
         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
             emailer.modalPresentationStyle = UIModalPresentationPageSheet;
         }
         [self presentViewController:emailer animated:YES completion:nil];
     }
     else {
         ///show alert if mail account is not configered 
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
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopDownload) name:@"stopDownload" object:nil];
    [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.4];
    [super viewWillAppear:YES];
}

- (void) viewDidDisappear:(BOOL)animated {
    [self Back];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:YES];
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

/**
 * it stops the audio player
 * and remove the downloaded temp file 
 */
-(void)Back{
    [ApplicationDelegate.player stop];
    NSError *error;
    ///remove temp file from document dir of application 
    [[NSFileManager defaultManager] removeItemAtPath:[self GetFileUrl] error:&error];
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
 * this method will start loading file data from server if file is not in doucment dir of application 
    and if file is already downloaded before it will init the player and play the file 
 */
-(void)initPlayer{
 
    // start loading file data from server if its not in doucment dir of application 
    
    if(![[NSFileManager defaultManager]fileExistsAtPath:[self GetFileUrl]]){
        [ApplicationDelegate.HUD setHidden:FALSE];
        [ApplicationDelegate showCloseButton];
     
        NSString *urlString =[NSString stringWithFormat:@"%@",objFile.ref];
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
        [self Play:nil];  ///play audio file if its already loaded 
    }
}

/*
-(void)workspaceFileContent{
    
    NSString *urlString =[NSString stringWithFormat:@"%@",strContent];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    //NSLog(@"Access token = %@",ApplicationDelegate.accessToken);
    [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"GET"];
    
    Connection2 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if(Connection2) {
        
        ResponseData2 = [[NSMutableData alloc] init];
    }
}*/

- (void)viewDidUnload
{
    [ApplicationDelegate.player stop];
      NSError *error;
    
    //remove temp file from document dir of appliction 
    
    [[NSFileManager defaultManager] removeItemAtPath:[self GetFileUrl] error:&error];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - UIInterfaceOrientation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - HTTP connection methods 
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    if (connection == Connection1)
        ResponseData1 = nil;   
    
    else if(connection == Connection2)
        ResponseData2 = nil;
    
    else if(connection == Connection3)
        ResponseData3 = nil;
    NSLog(@"Error = %@", error);
    
     [ApplicationDelegate.HUD setLabelText:@"Loading..."];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == Connection1){
        [ResponseData1 setLength:0];
        NSLog(@"content length : %llu",[response expectedContentLength]);
        expectedBytes = (long)[response expectedContentLength];
      

     //   NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
     //   NSDictionary* headers = [httpResponse allHeaderFields];
        //NSLog(@"Header Response = %@",headers);
    }
    
    else if(connection == Connection2){
        [ResponseData2 setLength:0];
      //  NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
      //  NSDictionary* headers = [httpResponse allHeaderFields];
        //NSLog(@"Header Response = %@",headers);
    }
    
    else if(connection == Connection3){
        [ResponseData3 setLength:0];
     //   NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
     //   NSDictionary* headers = [httpResponse allHeaderFields];
        //NSLog(@"Header Response = %@",headers);
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == Connection1){
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
    else if(connection == Connection2){
        [ResponseData2 appendData:data];}
    else if(connection == Connection3){
        [ResponseData3 appendData:data];}
}

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes{
    NSLog(@"downloaded %llu total %llu",totalBytesWritten,expectedTotalBytes);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [ApplicationDelegate.HUD setLabelText:@"Loading..."];

    if (connection == Connection1) { /// for loading file data
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

            NSString *path=[self GetFileUrl]; //get file path to save it temp
            [[NSFileManager defaultManager] createFileAtPath:path
                                                    contents:ResponseData1
                                                  attributes:nil ];
            NSError *error;
            ///init player
            
            
            ApplicationDelegate.player=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
            
            
            if (error)
            {
                NSLog(@"Error in audioPlayer: %@",
                      [error localizedDescription]);
            } else {
                ApplicationDelegate.player.delegate = self;
                [ ApplicationDelegate.player prepareToPlay];
            }
            
            //NSLog(@"%f",ApplicationDelegate.player.duration);
            [ApplicationDelegate.HUD setHidden:YES];
            [ApplicationDelegate hideCloseButton];
            
            [self Play:nil];
            // [self setAlbumArtwork];
            
            timer=nil;
            //start timer for change slider value
            timer= [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(ChngeSliderValue) userInfo:nil repeats:YES];
        }
    }
    else if (connection==Connection3) ///for updating file info
    {
       // NSString *responsestring= [[NSString alloc] initWithData:ResponseData3 encoding:NSUTF8StringEncoding];
     //   NSLog(@"responsestring = %@",responsestring);
        lblTitle.text=txtTitle.text;
    }
}

#pragma mark - player
/**
 * this method called by timer and change the slider value 
 * and when audio/moview is not playing it invalidates the timer.
 */
-(void)ChngeSliderValue
{
    if([ApplicationDelegate.player isPlaying]){
        progress.value = ApplicationDelegate.player.currentTime;
        //NSLog(@"Current : %f",ApplicationDelegate.player.currentTime);
        //NSLog(@"Progress : %f", progress.value);
    }
    else {
        [timer invalidate];
    }
}
//
//-(IBAction)progressValueChange:(id)sender
//{
//    //NSLog(@"%f",progress.value);
//    
//    ///change progressbar value
//    
//    ApplicationDelegate.player.currentTime = progress.value;
//    if([ApplicationDelegate.player isPlaying]){
//
//        [ApplicationDelegate.player play];
//      
//    }
//}

#pragma mark - play
/**
 * this method will init palyer and play the audio/video.
 * and starts timer to call change slider value.
 */
-(IBAction)Play:(id)sender
{
    if(!ApplicationDelegate.player){
    
        NSError *error;
        ApplicationDelegate.player=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:[self GetFileUrl]] error:&error];
        
        if (error)
        {
            NSLog(@"Error in audioPlayer: %@", 
                  [error localizedDescription]);
        } else {
            ApplicationDelegate.player.delegate = self;
            [ ApplicationDelegate.player prepareToPlay];
        }
        
       //[self setAlbumArtwork];
       
        timer=nil;
        timer= [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(ChngeSliderValue) userInfo:nil repeats:YES];
    }
    [btnPlay setTintColor:[UIColor clearColor]];

    if([ApplicationDelegate.player isPlaying])
    {
        [ApplicationDelegate.player pause]; //Pause
        
        [btnPlay setImage:[UIImage imageNamed:@"play_btn.png"]];
  
    }
    else{
         //  Play
        
        [btnPlay setImage:[UIImage imageNamed:@"Pause_btn.png"]];

        progress.minimumValue = 0;
        progress.maximumValue = ApplicationDelegate.player.duration;
        //NSLog(@"progress :%f", progress.value);
    
        [ApplicationDelegate.player play];
        ApplicationDelegate.player.delegate=self;///set delegate
        
        ///start timer to change progress value 
        timer= [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(ChngeSliderValue) userInfo:nil repeats:YES];
        
    }
}

/**
 * this method will set value for isRepeat flag .
 * and also change image for repeat button.
 */
-(IBAction)repeat:(id)sender
{
    isRepeat=!isRepeat; //set flag  for repeat functionality 
    UIBarButtonItem *repeatBtn = (UIBarButtonItem*) sender;
    if(isRepeat) {
        
        [repeatBtn setStyle:UIBarButtonItemStyleDone];
    }
    else {
        [repeatBtn setStyle:UIBarButtonItemStylePlain];
    }
}

#pragma mark -AVAudioplayer delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
     progress.value=0;//reset progress value
    if(isRepeat)
    {
        [player play];/// repeat audio if isRepeat flag is true
    }
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    //NSLog(@"%@",[error localizedDescription]);   
}

@end