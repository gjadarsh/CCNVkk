//
//  TextEditViewController.m
//  CCNV
//
//  Created by  Linksware Inc. on 10/08/2012.
//
//

#import "TextEditViewController.h"
@interface TextEditViewController ()

@end

@implementation TextEditViewController
@synthesize fileDict;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFileData) name:@"TokenRefreshed" object:nil];
    [super viewWillAppear:animated];
}
- (void) viewDidDisappear:(BOOL)animated {
   
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    ///set UItextField in Title View /////////////////////////

    txtTitle =[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [txtTitle setBackgroundColor:[UIColor whiteColor]];
    txtTitle.text=fileDict.strDisplayName;
    txtTitle.delegate=self;
    
    ///set UIlabel in Title View /////////////////////////

    lblTitle =[[UILabel alloc] initWithFrame:txtTitle.frame];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    lblTitle.text=fileDict.strDisplayName;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.textAlignment=NSTextAlignmentCenter;
    
    self.navigationItem.titleView=lblTitle;
  
    //set UIBarbutton for mail 
    UIImage* image2 = [UIImage imageNamed:@"mail.png"];
    CGRect frameimg2 = CGRectMake(0, 0, image2.size.width, image2.size.height);
    UIButton *mail = [[UIButton alloc] initWithFrame:frameimg2];
    [mail setBackgroundImage:image2 forState:UIControlStateNormal];
    [mail addTarget:self action:@selector(MailFile)
       forControlEvents:UIControlEventTouchUpInside];
    [mail setShowsTouchWhenHighlighted:YES];

    UIBarButtonItem *btnmail=[[UIBarButtonItem alloc] initWithCustomView:mail];
    UIBarButtonItem *btnedit=[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(EditText)];
    textview.editable=FALSE;
    
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:btnedit,btnmail,nil];
   
   //set observer for UItextview 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    //load file data
    [self getFileData];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark Mail Compose Delegate

/**
 * this method will open MailComposeViewController,and add attachment in mail
 * it will show alert if mail account is not configered in device.
 */

-(void)MailFile
{
    NSString *path=[self GetFileUrl];//get file path
    NSData *data=[textview.text dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:path atomically:YES];
    
     if ([MFMailComposeViewController canSendMail]) {
         MFMailComposeViewController *emailer = [[MFMailComposeViewController alloc] init];
         emailer.mailComposeDelegate = self;
         
         //add attachment in mail 
         [emailer addAttachmentData:data mimeType:@"txt" fileName:fileDict.strDisplayName];
         emailer.modalPresentationStyle=UIModalPresentationFullScreen;
         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
             emailer.modalPresentationStyle = UIModalPresentationPageSheet;
         }
         [self presentViewController:emailer animated:YES completion:nil];
     }else {
         // pop alert if mail account is not Configured in device 
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Edit

/**
 * this method will set navigation bar to make file displayName editable .
 */

-(void)EditText
{
    //set titile bar
    
    self.navigationItem.rightBarButtonItem=nil;
    if(!self.editing)
    {
        textview.editable=TRUE;
         self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(UpdateFile)];
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
        textview.editable=FALSE;
        
        
        self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:btnedit,btnmail,nil];
    
        self.navigationItem.titleView=lblTitle;
    }
}

#pragma mark - getdetails

/**
 * this method will load File data .
 * it starts new connection to load file data ,downloads file and store it in Document dir of application in ConnectionDidFinishLoading method 
 */
-(void)getFileData
{
    
    //load file data 
    [ApplicationDelegate.HUD setHidden:FALSE];
   
    NSString *urlString =[NSString stringWithFormat:@"%@",fileDict.filedata];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
    //  NSLog(@"URL = %@",urlString);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    //NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:APP.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"GET"];
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
         [ApplicationDelegate.HUD setHidden:TRUE];
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
    
    //// update file version
    [ApplicationDelegate.HUD setHidden:FALSE];
    NSString *path=[self GetFileUrl];
    NSData *data=[textview.text dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:path atomically:YES];

    NSString *urlString =[NSString stringWithFormat:@"%@",fileDict.filedata];
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
    
    NSString *strDisplayname=(__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                                   NULL,
                                                                                                   (__bridge_retained CFStringRef)txtTitle.text,
                                                                                                   NULL,
                                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                   kCFStringEncodingUTF8 );
    NSString *xmlString = [NSString stringWithFormat:
                           @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>                           <file><displayName>%@</displayName></file>",strDisplayname];
    
    NSData *thumbsupData = [xmlString dataUsingEncoding: NSASCIIStringEncoding];
    
    NSString *urlString =[NSString stringWithFormat:@"%@",fileDict.ref];
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

/**
 * this method will return downloaded File path.
 *
 */

-(NSString*)GetFileUrl
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],fileDict.strDisplayName];
    //NSLog(@"%@",path);
    return path;
}

#pragma mark - KeyboardNotification
- (void)keyboardWillShow:(NSNotification*)notification {
    [UIView beginAnimations:@"anim" context:nil];
    //set frame of view when UIkeyBoard will show 
    if (isIpad) {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
            [textview setFrame:CGRectMake(textview.frame.origin.x, textview.frame.origin.y, textview.frame.size.width, self.view.frame.size.height - 350)];
        }
        else {
            [textview setFrame:CGRectMake(textview.frame.origin.x, textview.frame.origin.y, textview.frame.size.width, self.view.frame.size.height - 264)];
        }
    }
    else {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
            [textview setFrame:CGRectMake(textview.frame.origin.x, textview.frame.origin.y, textview.frame.size.width, self.view.frame.size.height - 160)];
        }
        else {
            [textview setFrame:CGRectMake(textview.frame.origin.x, textview.frame.origin.y, textview.frame.size.width, self.view.frame.size.height - 216)];
        }
    }
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [UIView beginAnimations:@"anim" context:nil];
    textview.frame = self.view.frame;
    [UIView commitAnimations];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    return TRUE;
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
    // Return YES for supported orientations
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        
        
    }
    else{
        txtTitle.frame=CGRectMake(0, 0, 80, 30);
        lblTitle.frame=CGRectMake(0, 0, 80, 30);
    }
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - http connection methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    ResponseData1 = nil;
    ResponseData2=nil;
    ResponseData3=nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection==Connection1){
        [ResponseData1 setLength:0];}
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
         [ResponseData1 appendData:data];}
    else if(connection==Connection2){
         [ResponseData2 appendData:data];
    }
    else if(connection==Connection3){
        [ResponseData3 appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *responsestring;
    if(connection==Connection1){ // file data
        responsestring= [[NSString alloc] initWithData:ResponseData1 encoding:NSUTF8StringEncoding];
        
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
            [textview setText:responsestring];
            
            NSString *path=[self GetFileUrl];
            [[NSFileManager defaultManager] createFileAtPath:path
                                                    contents:ResponseData1
                                                  attributes:nil ];
            [ApplicationDelegate.HUD setHidden:TRUE];
            
        }
        
    }
    else if(connection==Connection2){ /// rsponce of file version updatetion 
        responsestring= [[NSString alloc] initWithData:ResponseData2 encoding:NSUTF8StringEncoding];
        
       
        
        if(![txtTitle.text isEqualToString:fileDict.strDisplayName]){
            [self UpdateFileInfo]; // start updating file info
        }
        else{
          //  [self.navigationController popViewControllerAnimated:YES];
        }
        self.editing=TRUE;
        [self EditText];//reset navigation bar
    }
    else
    {
       //  [self.navigationController popViewControllerAnimated:YES];
    }
    [ApplicationDelegate.HUD setHidden:TRUE];
  //  NSLog(@"responsestring = %@",responsestring);
}

@end