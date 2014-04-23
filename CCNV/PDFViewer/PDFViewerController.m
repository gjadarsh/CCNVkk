//
//  PDFViewerController.m
//  CCNV
//
//  Created by  Linksware Inc. on 9/19/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import "PDFViewerController.h"

@implementation PDFViewerController
@synthesize fileUrl,objfile;
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
       ///set UItextField in Title View /////////////////////////
    txtTitle =[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    [txtTitle setBackgroundColor:[UIColor whiteColor]];
    txtTitle.text=objfile.strDisplayName;
    txtTitle.delegate=self;
    
       ///set UILabel in Title View /////////////////////////
    lblTitle =[[UILabel alloc] initWithFrame:txtTitle.frame];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    lblTitle.text=objfile.strDisplayName;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.textAlignment=NSTextAlignmentCenter;
    
    self.navigationItem.titleView=lblTitle;
    
    ///set mail,edit option button in navigation bar 
    UIImage* image2 = [UIImage imageNamed:@"mail.png"];
    CGRect frameimg2 = CGRectMake(0, 0, image2.size.width, image2.size.height);
    UIButton *mail = [[UIButton alloc] initWithFrame:frameimg2];
    [mail setBackgroundImage:image2 forState:UIControlStateNormal];
    [mail addTarget:self action:@selector(MailFile)
   forControlEvents:UIControlEventTouchUpInside];
    [mail setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *btnmail=[[UIBarButtonItem alloc] initWithCustomView:mail];
    UIBarButtonItem *btnedit=[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(EditText)];
    
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:btnedit,btnmail,nil];
    
    ///add NSNotificationCenter observer for uitextfield 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    ///get file data
    [self getFileData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFileData) name:@"TokenRefreshed" object:nil];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopDownload) name:@"stopDownload" object:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidDisappear:(BOOL)animated {
//    if(!isSendingMail){
//        [self cancel];}
    [super viewDidDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark Mail Compose Delegate
/**
 * this method will open  MFMailComposeViewController.
 *and Attach downloaded file to mail.
 */

-(void)MailFile
{
    NSString *path=[self GetFileUrl]; //get file path 
    NSData *data=[NSData dataWithContentsOfFile:path];
    //[data writeToFile:path atomically:YES];
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *emailer = [[MFMailComposeViewController alloc] init];
        emailer.mailComposeDelegate = self;
        
        //add attachment 
        [emailer addAttachmentData:data mimeType:@"pdf" fileName:objfile.strDisplayName];
        emailer.modalPresentationStyle=UIModalPresentationFullScreen;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            emailer.modalPresentationStyle = UIModalPresentationPageSheet;
        }
        [self presentViewController:emailer animated:YES completion:nil];
    }else {
        //pop alert if mail account is not Configured in device 
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"Configure your mail account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

/**
 *   MFMailComposeViewController delegate method.
 * pop ups alerts on failur .
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

#pragma mark - getdetails
/**
 * this method will load File data .
 * it starts new connection to load file data ,downloads file and store it in Document dir of application in ConnectionDidFinishLoading method */
-(void)getFileData
{
    
    // load file data
    
    [ApplicationDelegate.HUD setHidden:FALSE];
    [ApplicationDelegate showCloseButton];
    
    NSString *urlString =[NSString stringWithFormat:@"%@",objfile.filedata];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
    //  NSLog(@"URL = %@",urlString);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    //NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:APP.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"GET"];
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

#pragma mark - UpdateFile
/**
 * this method will upload File data .
 * it starts new connection to upload file data or upload new version of file 
 */
-(void)UpdateFile
{
    
    //update file version
    [ApplicationDelegate.HUD setHidden:FALSE];
    NSString *path=[self GetFileUrl];//get file path'
    
    NSData *data=[txtTitle.text dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:path atomically:YES];
    
    NSString *urlString =[NSString stringWithFormat:@"%@",objfile.filedata];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
    //   NSLog(@"URL = %@",urlString);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    //NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"PUT"];
    
    [theRequest setHTTPBody:[NSData dataWithContentsOfFile:[self GetFileUrl]]];
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
         [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        Connection2 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if(Connection2) {
            
            ResponseData2 = [[NSMutableData alloc] init];
        }
    }
}

/**
 * this method will update File info .
 * it starts new connection to update file info like display name .
 */
-(void)UpdateFileInfo{
    
    //update file info
    
    [ApplicationDelegate.HUD setHidden:FALSE];
     //  [ApplicationDelegate showCloseButton];
    NSString *strDisplayname=(__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                                   NULL,
                                                                                                   (__bridge_retained CFStringRef)txtTitle.text,
                                                                                                   NULL,
                                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                   kCFStringEncodingUTF8 );
    NSString *xmlString = [NSString stringWithFormat:
                           @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>                           <file><displayName>%@</displayName></file>",strDisplayname];
    
    NSData *thumbsupData = [xmlString dataUsingEncoding: NSASCIIStringEncoding];
    
    NSString *urlString =[NSString stringWithFormat:@"%@",objfile.ref];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
    //  NSLog(@"URL = %@",xmlString);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"PUT"];
    [theRequest addValue:@"application/xml; charset=UTF-8" forHTTPHeaderField:@"Content-type"];
    [theRequest setHTTPBody:thumbsupData];
    
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
         [ApplicationDelegate.HUD setHidden:TRUE];
           //[ApplicationDelegate hideCloseButton];
    }else{

        Connection3 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if(Connection3) {
            ResponseData3 = [[NSMutableData alloc] init];
        }
        
    }
}

/**
 * this method will return downloaded File path.
 * 
 */
-(NSString*)GetFileUrl
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],objfile.strDisplayName];
    NSLog(@"%@",path);
    return path;
}
#pragma mark - Edit
/**
 * this method will set navigation bar to make file displayName editable .
 */
-(void)EditText
{
    
    //set navigation bar
    
    self.navigationItem.rightBarButtonItem=nil;
    if(!self.editing)
    {
      //  textview.editable=TRUE;
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(UpdateFileInfo)];
        self.navigationItem.titleView=txtTitle;
    }
    else {
        UIImage* image2 = [UIImage imageNamed:@"mail.png"];
        CGRect frameimg2 = CGRectMake(0, 0, image2.size.width, image2.size.height);
        UIButton *mail = [[UIButton alloc] initWithFrame:frameimg2];
        [mail setBackgroundImage:image2 forState:UIControlStateNormal];
        [mail addTarget:self action:@selector(MailFile)
       forControlEvents:UIControlEventTouchUpInside];
        [mail setShowsTouchWhenHighlighted:YES];
        
        UIBarButtonItem *btnmail=[[UIBarButtonItem alloc] initWithCustomView:mail];
        UIBarButtonItem *btnedit=[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(EditText)];
     
                
        self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:btnedit,btnmail,nil];
        
        self.navigationItem.titleView=lblTitle;
    }
}

#pragma mark - KeyboardNotification
- (void)keyboardWillShow:(NSNotification*)notification {
//set frame hwen UIKeyBoard will show
    if (isIpad) {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
          //  [textview setFrame:CGRectMake(textview.frame.origin.x, textview.frame.origin.y, textview.frame.size.width, self.view.frame.size.height - 350)];
        }
        else {
           // [textview setFrame:CGRectMake(textview.frame.origin.x, textview.frame.origin.y, textview.frame.size.width, self.view.frame.size.height - 264)];
        }
    }
    else {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
          //  [textview setFrame:CGRectMake(textview.frame.origin.x, textview.frame.origin.y, textview.frame.size.width, self.view.frame.size.height - 160)];
        }
        else {
           // [textview setFrame:CGRectMake(textview.frame.origin.x, textview.frame.origin.y, textview.frame.size.width, self.view.frame.size.height - 216)];
        }
    }
 
}

- (void)keyboardWillHide:(NSNotification*)notification {
   }
#pragma mark - UIInterfaceOrientation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft||toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
    
        
    }
    else{
        txtTitle.frame=CGRectMake(0, 0, 80, 30);
        lblTitle.frame=CGRectMake(0, 0, 80, 30);
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        
   
        
    }
    else{
        txtTitle.frame=CGRectMake(0, 0, 80, 30);
        lblTitle.frame=CGRectMake(0, 0, 80, 30);

    }
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - http connection methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    ResponseData1 = nil;
    ResponseData2=nil;
    ResponseData3=nil;
     [ApplicationDelegate.HUD setLabelText:@"Loading..."];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection==Connection1){
        [ResponseData1 setLength:0];
        NSLog(@"content length : %llu",[response expectedContentLength]);
        expectedBytes =(long) [response expectedContentLength];
        [ResponseData1 setLength:0];
    }
    else if(connection==Connection2){
        [ResponseData2 setLength:0];
    }
    else{
        [ResponseData3 setLength:0];
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    NSLog(@"content length : %llu",[response expectedContentLength]);
    NSLog(@"Status Code : %d",code);
    
    if (code == 401 & [response expectedContentLength] == 315) {
        ApplicationDelegate.TokenExpired = TRUE;
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if(connection==Connection1){
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
    else if(connection==Connection2){
        [ResponseData2 appendData:data];
    }
    else if(connection==Connection3){
        [ResponseData3 appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *responsestring;
    if(connection==Connection1){ //file data
        [ApplicationDelegate.HUD setLabelText:@"Loading..."];
        responsestring= [[NSString alloc] initWithData:ResponseData1 encoding:NSUTF8StringEncoding];
        // [textview setText:responsestring];
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
            
            
            NSString *path=[self GetFileUrl];  ///get file path
            
            BOOL success= [[NSFileManager defaultManager] createFileAtPath:path
                                                                  contents:ResponseData1
                                                                attributes:nil ];
            if(success){
                
                NSURL *targetURL = [NSURL fileURLWithPath:path];
                NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
                
                //load file data into webview
                [webview loadRequest:request];
            }
            [ApplicationDelegate.HUD setHidden:TRUE];
            [ApplicationDelegate hideCloseButton];
        }
    }
    else if(connection==Connection2){
        responsestring= [[NSString alloc] initWithData:ResponseData2 encoding:NSUTF8StringEncoding];
        
        
        
        if(![txtTitle.text isEqualToString:objfile.strDisplayName]){
            [self UpdateFileInfo];  ///update file info 
        }
        else{
            //  [self.navigationController popViewControllerAnimated:YES];
        }
        self.editing=TRUE;
        [self EditText];   ///reset navigation bar 
    }
    else
    {
        responsestring= [[NSString alloc] initWithData:ResponseData3 encoding:NSUTF8StringEncoding];
       
        [ApplicationDelegate.HUD setHidden:TRUE];
        
        self.editing=TRUE;
        [self EditText];   ///reset navigation bar 
      
    }
    [ApplicationDelegate.HUD setHidden:TRUE];
    //  NSLog(@"responsestring = %@",responsestring);
}

@end