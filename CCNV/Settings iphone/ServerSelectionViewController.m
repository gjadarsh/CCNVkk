//
//  ServerSelectionViewController.m
//  CCNV
//
//  Created by  Linksware Inc. on 9/11/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import "ServerSelectionViewController.h"
//#import "FilesViewController.h"
#import "PlayerViewController.h"
#import "MoviePlayerController.h"
#import "AboutCCNVviewController.h"
#import "HelpViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "GoogleDriveContentListingViewController.h"
@implementation ServerSelectionViewController
{
    IBOutlet TPKeyboardAvoidingScrollView *tpScrollView;
}
@synthesize tableview,arrServerlist;
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
    
    arrServerlist=[[NSMutableArray alloc] initWithObjects:@"Storage",@"About CCNV",@"CCNV Help", nil];
    self.navigationItem.title=@"Settings";
    self.navigationItem.hidesBackButton=TRUE;
    
    //set login values of CCNV.
    lblUserID.text=ApplicationDelegate.currentUser.strUserName;
    lblType.text=ApplicationDelegate.currentUser.strProductValue;

    [tpScrollView setContentSize:CGSizeMake(300,460)];
    //set all keys for sugersync
    APP.applicationID = @"/sc/3641183/222_198946960";
    APP.accessKeyId = @"MzY0MTE4MzEzNDgyMDMwNTIxODU";
    APP.privateAccessKey = @"YmFlMjBiMDMyMDA5NDFiNDg4MzI2N2ZhZGRjYjI3MGM";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        [self buttonLayerSetForIos7:loginButton];
        
    }

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
-(void)buttonLayerSetForIos7:(UIButton *)button
{
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    button.layer.cornerRadius = 8;
    button.layer.masksToBounds = YES;
}
-(void)viewWillAppear:(BOOL)animated{
    
    UIBarButtonItem *logout = [[UIBarButtonItem alloc]initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout_clicked)];
    self.navigationItem.rightBarButtonItem=logout;
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated{
    if(!isIpad){
//        [bannerview loadImageFromURL];
        [self loadBanner];
        adTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(loadBanner) userInfo:nil repeats:YES];
    }
}
- (void)loadBanner {
    [bannerview performSelectorInBackground:@selector(loadImageFromURL) withObject:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [adTimer invalidate];
    adTimer = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
   return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationLandscapeLeft||
           interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

#pragma mark - tableview delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrServerlist count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = [arrServerlist objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.row==0)
    {
        LogInViewController *login;
        if(isIpad)
        {
            login=[[LogInViewController alloc] initWithNibName:@"LogInViewController_ipad" bundle:nil];
            
        }else{
            login=[[LogInViewController alloc] initWithNibName:@"LogInViewController" bundle:nil];
        }
        login.title=@"SugerSync";
        [self.navigationController pushViewController:login animated:YES];
    }
    else if (indexPath.row==1)
    {
        if(!isIpad)
        {
            AboutCCNVviewController *aboutview=[[AboutCCNVviewController alloc] initWithNibName:@"AboutCCNVviewController" bundle:nil];
            aboutview.title=@"About CCNV";
            [self.navigationController pushViewController:aboutview animated:YES];

        }
    }
    else if (indexPath.row==2){
        if(!isIpad)
        {
        HelpViewController *helpview=[[HelpViewController alloc]initWithNibName:@"HelpViewController" bundle:nil];
            [self.navigationController pushViewController:helpview animated:YES];}
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - alertview delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    LogInViewController *login;
    if(isIpad)
    {
        login=[[LogInViewController alloc] initWithNibName:@"LogInViewController_ipad" bundle:nil];
        
    }else{
        login=[[LogInViewController alloc] initWithNibName:@"LogInViewController" bundle:nil];
    }
    login.title=@"SugerSync";
    [self.navigationController pushViewController:login animated:YES];

}

/**
* this method will do logout.
* it will reset refreshtoken.
*/

-(IBAction)logout_clicked{
    
    APP.refreshToken = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate {
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return TRUE;
}

#pragma mark - login
/**
 * this method will call login webservice in connection .
 * it pops alert if username or password value is blank , and update User object in (connectionDidFinishLoading) on successful login  method
 */
-(IBAction)login_Clicked:(id)sender{
    
    //  set loging details 
//    [ApplicationDelegate.HUD setHidden:FALSE];
//    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"usernameSS"];
//   NSString * password = [[NSUserDefaults standardUserDefaults] valueForKey:@"passwordSS"];
//    
    if (!self.isAuthorized) {
        
        SHOW_ALERT(@"Google Drive", @"Please Login to Google Drive", nil, @"OK", nil, nil)
    }else{
        GoogleDriveContentListingViewController *googleDriveListViewcontroller =[[GoogleDriveContentListingViewController alloc]initWithNibName:@"GoogleDriveContentListingViewController" bundle:nil];
        googleDriveListViewcontroller.checkRoot=YES;

        [self.navigationController pushViewController:googleDriveListViewcontroller animated:YES];
    }
    /*
    if ([username isEqualToString:@""] || [password isEqualToString:@""]||!username||!password) {
        //pop ups alert if any value is null 
        
        SHOW_ALERT(@"CCNV", @"Set Username and password ", self, @"OK", nil, nil)
        [ApplicationDelegate.HUD setHidden:TRUE];
        return;
    }
    
    
    // loging to sugersync 
    
    NSString *xmlString = [NSString stringWithFormat:
                           @"<appAuthorization> \
                           <username>%@</username> \
                           <password>%@</password> \
                           <application>%@</application> \
                           <accessKeyId>%@</accessKeyId> \
                           <privateAccessKey>%@</privateAccessKey> \
                           </appAuthorization>",username,password,APP.applicationID,APP.accessKeyId,APP.privateAccessKey];
    
    NSData *thumbsupData = [xmlString dataUsingEncoding: NSASCIIStringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:@"%@app-authorization",BaseURL];
   NSURL * theURL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest addValue:@"application/xml; charset=UTF-8" forHTTPHeaderField:@"Content-type"];
    [theRequest setHTTPBody:thumbsupData];
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
      [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        Connection1 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if(Connection1) {
            ResponseData1 = [[NSMutableData alloc] init];
        }
        
        else {
            //NSLog(@"Error, Invalid Request");
        }
    }
     */
}

#pragma mark - NSURLConnection methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    if (connection == Connection1)
        ResponseData1 = nil;
    
    else if(connection == Connection2)
        ResponseData2 = nil;
    
    else if(connection == Connection3)
        ResponseData3 = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == Connection1){
        [ResponseData1 setLength:0];
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSDictionary* headers = [httpResponse allHeaderFields];
        NSLog(@"Refresh Token: %@",[headers valueForKey:@"Location"]);
        
        if (![headers valueForKey:@"Location"]) {
            SHOW_ALERT(@"CCNV", @"Username or password incorrect", nil, @"OK", nil, nil)
          
            loginButton.userInteractionEnabled = TRUE;
         
            //  [activity stopAnimating];
            [ApplicationDelegate.HUD setHidden:TRUE];
            return;
        }
        
        APP.refreshToken = [NSString stringWithFormat:@"%@",[[headers valueForKey:@"Location"]stringByReplacingOccurrencesOfString:@"https://api.sugarsync.com/app-authorization/" withString:@""]];
        
    }
    
    else if(connection == Connection2){
        [ResponseData2 setLength:0];
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSDictionary* headers = [httpResponse allHeaderFields];
        APP.accessToken = [headers valueForKey:@"Location"];
        //NSLog(@"Access Token = %@",APP.refreshToken);
    }
    
    else if(connection == Connection3){
        [ResponseData3 setLength:0];
        //NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        //NSLog(@"Status code : %d",[httpResponse statusCode]);
       // NSDictionary* headers = [httpResponse allHeaderFields];
        //NSLog(@"Response Header : %@", headers);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (connection == Connection1)
        [ResponseData1 appendData:data];
    
    else if(connection == Connection2)
        [ResponseData2 appendData:data];
    
    else if(connection == Connection3)
        [ResponseData3 appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    if (connection == Connection1){
        
        [self getUserID];
    }
    else if(connection == Connection2){
        
        NSString *responsestring= [[NSString alloc] initWithData:ResponseData2 encoding:NSUTF8StringEncoding];
        //NSLog(@"responsestring = %@",responsestring);
        
        NSString *start = @"<user>";
        NSRange starting = [responsestring rangeOfString:start];
        if(starting.location != NSNotFound){
            NSString *end = @"</user>";
            NSRange ending = [responsestring rangeOfString:end];
            NSString *str = [responsestring substringWithRange:NSMakeRange(starting.location + starting.length, ending.location - (starting.location + starting.length))];
            
            APP.userID = [[NSString stringWithString:str] stringByReplacingOccurrencesOfString:@"https://api.sugarsync.com/user/" withString:@""];
            
            //NSLog(@"%@",APP.userID);
            [self getUserInfo];
        }
    }
    
    else if(connection == Connection3){
         //update history table 
        NSString *strHistory=@"Successfully Login in SugarSync";
        [ApplicationDelegate UpdateDatabase:strHistory];
        
      //  NSString *responsestring= [[NSString alloc] initWithData:ResponseData3 encoding:NSUTF8StringEncoding];
        //    NSLog(@"responsestring = %@",responsestring);
        
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:ResponseData3];
        XMLParser *parser = [[XMLParser alloc] initXMLParser];
        [xmlParser setDelegate:parser];
        BOOL success = [xmlParser parse];
        
        if(success){
            //NSLog(@"No Errors In XML Parsing");
        }
        else{
            //NSLog(@"Error In XMLParsing");
        }
        //NSLog(@"APP.folders = %@",APP.arrSugerSyncFolder);
        
        //[activity stopAnimating];
        [ApplicationDelegate.HUD setHidden:TRUE];
       
        loginButton.userInteractionEnabled = TRUE;
        
        File *obj=(File *)[ApplicationDelegate.arrSugerSyncFolder objectAtIndex:0];
        currentFile=obj;
        //  workspaceContent *objWork;
        SelectWorkspace *objWork;
        if (isIpad) {
            objWork=[[SelectWorkspace alloc] initWithNibName:@"SelectWorkspace_ipad" bundle:nil];
        }
        else{
            objWork=[[SelectWorkspace alloc] initWithNibName:@"SelectWorkspace" bundle:nil];}
        objWork.title=obj.strDisplayName;
        //        objWork.navigationItem.hidesBackButton=TRUE;
        
        [self.navigationController pushViewController:objWork animated:YES];
        //    FilesViewController *filesview;
        //        if(isIpad)
        //        {
        //            filesview=[[FilesViewController alloc] initWithNibName:@"FilesViewController_ipad" bundle:nil];
        //        }
        //        else
        //        {
        //            filesview=[[FilesViewController alloc] initWithNibName:@"FilesViewController" bundle:nil];
        //        }
        //        [self.navigationController pushViewController:filesview animated:YES];
        
    }
}

/**
 * this method will load userID of sugersync user .
 * it starts new connection  , and update User object in (connectionDidFinishLoading) on successful login  method
 */
-(void)getUserID{
    
    NSString *xmlString = [NSString stringWithFormat:
                           @"<tokenAuthRequest> \
                           <accessKeyId>%@</accessKeyId> \
                           <privateAccessKey>%@</privateAccessKey> \
                           <refreshToken>%@</refreshToken> \
                           </tokenAuthRequest>",APP.accessKeyId,APP.privateAccessKey,APP.refreshToken];
    
    NSData *thumbsupData = [xmlString dataUsingEncoding: NSASCIIStringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@authorization",BaseURL];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest addValue:@"application/xml; charset=UTF-8" forHTTPHeaderField:@"Content-type"];
    [theRequest setHTTPBody:thumbsupData];
    
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
         [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        Connection2 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if(Connection2) {
            
            ResponseData2 = [[NSMutableData alloc] init];
        }
        
        else {
            //NSLog(@"Error, Invalid Request");
        }
    }
}

/**
 * this method will load User info .
 * it starts new connection to load user info , and update User object in (connectionDidFinishLoading) on successful login  method
 */
-(void)getUserInfo{
    //loads userinfo of sugersync
    
    NSString *urlString = [NSString stringWithFormat:@"%@user/%@",BaseURL,APP.userID];
    NSURL* theURL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    
    [theRequest setValue:APP.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"GET"];
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
         [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        Connection3 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if(Connection3) {
            
            ResponseData3 = [[NSMutableData alloc] init];
        }
        
        else {
            //NSLog(@"Error, Invalid Request");
        }
    }
}

// Perform SSL

enum SSLResolution {
    kSSLResolutionDefault,
    kSSLResolutionAllowAll,
    kSSLResolutionDenyAll,
    kSSLResolutionProvideCert
};

typedef enum SSLResolution SSLResolution;
static SSLResolution sSSLResolution = kSSLResolutionProvideCert;

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    BOOL result = FALSE;
    
    assert(protectionSpace != nil);
    
    // Just for fun, print out the certificates in the trust.
    if (NO)
    {
        SecTrustRef trust;
        trust = [protectionSpace serverTrust];
        //NSLog(@"canAuthenticateAgainstProtectionSpace");
        //NSLog(@"authmethod: %@", [protectionSpace authenticationMethod]);
        if (trust != NULL)
        {
            // [self logTrusts:trust];
        }
    }
    
    if ([[protectionSpace authenticationMethod] isEqual:NSURLAuthenticationMethodServerTrust])
    {
        sSSLResolution = kSSLResolutionAllowAll;
        result = YES;
    }
    else if ([[protectionSpace authenticationMethod] isEqual:NSURLAuthenticationMethodClientCertificate])
    {
        sSSLResolution = kSSLResolutionProvideCert;
        result = YES;
    }
    else
    {
        if (sSSLResolution == kSSLResolutionDefault)
        {
            result = NO;
        }
    }
    return result;
}

- (void)connection:(NSURLConnection *)conn
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    id<NSURLAuthenticationChallengeSender>  sender;
    
    //assert(conn == self.connection);
    assert(challenge != nil);
    
    sender = [challenge sender];
    assert(sender != nil);
    
    if (NO) {
        //NSLog(@"didReceiveAuthenticationChallenge");
        //NSLog(@"  proposedCredential = %@", [challenge proposedCredential]);
    }
    
    switch (sSSLResolution) {
        case kSSLResolutionDefault: {
            assert(NO); // We should never get here, but if we do treat it as a cancel.
            [sender cancelAuthenticationChallenge:challenge];
            break;
            
        }
        case kSSLResolutionProvideCert: {
            NSURLProtectionSpace *                  protectionSpace;
            NSURLCredential *                       credential;
            
            protectionSpace = [challenge protectionSpace];
            assert(protectionSpace != nil);
            
            ////////NSLog(@"ProtectionSpace: %@", [protectionSpace authenticationMethod]);
            
            if (idRef==nil || idArray==nil) {
                
                ////////NSLog(@"idRef and idArray are required with client cert");
                //status = @"Error: No identity provided (bad filename or password?)";
                [sender cancelAuthenticationChallenge:challenge];
            } else {
                
                
                credential = [NSURLCredential credentialWithIdentity:idRef certificates:idArray persistence:NSURLCredentialPersistenceNone];
                assert(credential != nil);
                ////////NSLog(@"Telling sender to use credential with Client Cert");
                
                
                [sender useCredential:credential forAuthenticationChallenge:challenge];
            }
            break;
        }
        case kSSLResolutionAllowAll: {
            
            
            NSURLProtectionSpace *                  protectionSpace;
            SecTrustRef                             trust;
            NSURLCredential *                       credential;
            
            protectionSpace = [challenge protectionSpace];
            assert(protectionSpace != nil);
            
            trust = [protectionSpace serverTrust];
            
            
            
            assert(trust != NULL);
            
            // It doesn't matter what trust you use here, just that you pass
            // a valid, non-nil credential to -useCredential:forAuthenticationChallenge:.
            credential = [NSURLCredential credentialForTrust:trust];
            assert(credential != nil);
            
            
            [sender useCredential:credential forAuthenticationChallenge:challenge];
            break;
        }
        case kSSLResolutionDenyAll: {
            [sender cancelAuthenticationChallenge:challenge];
            break;
        }
    }
}
#pragma mark -GoogleDrive
-(BOOL)isAuthorized
{
    GTMOAuth2Authentication *auth =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:kClientSecret];
    BOOL check =[auth canAuthorize]?YES:NO;
    return check;
    
}

@end