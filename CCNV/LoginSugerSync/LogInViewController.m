//
//  ViewController.m
//  SugarSynDemo
//
//  Created by  Linksware Inc. on 20/08/12.
//  Copyright © VINAS Co., Ltd. 2011 - 2013. All rights reserved.
//

#import "LogInViewController.h"
#import "ServerSelectionViewController.h"
#import "workspaceContent.h"
#import "File.h"
#import "GTLServiceDrive.h"
#import "HelpViewController.h"
#import "GoogleDriveContentListingViewController.h"
#import "GTMOAuth2SignIn.h"
#import <QuartzCore/QuartzCore.h>
#define kUserName @"nishiyama21@gmail.com"
#define kPassWord @"nishi_2013"


@implementation LogInViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
//login: ashish.lalwani@regius.co.in
//pass : ashish89
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (isIpad) {
        mainview.layer.borderWidth=2;
        mainview.layer.borderColor=[[UIColor blackColor]CGColor];

        self.view.layer.borderWidth=2;
        self.view.layer.borderColor=[[UIColor blackColor]CGColor];
        
        tableview.backgroundView = [[UIView alloc] initWithFrame:tableview.frame];
    }
    
    //set login values of CCNV.
    lblUserID.text=ApplicationDelegate.currentUser.strUserName;
    lblType.text=ApplicationDelegate.currentUser.strProductValue;
    
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd hh:mm"];
    
    //load application version info from plist file
    NSLog(@"%@",[[NSBundle mainBundle] infoDictionary]);
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    lblVersionInfo.text=[NSString stringWithFormat:@"Version %@", version]; //show info
    //CFBundleShortVersionString
    
//    lblbuildinfo.text=[NSString stringWithFormat:@" %@ Build Version:%@ ",[dateformatter stringFromDate:[NSDate date]], build];
//    NSLog(@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Bundle Date"]);
    lblbuildinfo.text=[NSString stringWithFormat:@"Build Version: %@ %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Bundle Date"], build];
    
    
    //load agreement file data 
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CCNV-mobile_ソフトウェア使用許諾契約書_issue08" ofType:@"doc"];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    //load file data  in webview 
    [webview loadRequest:request];

    arrServerlist=[[NSMutableArray alloc] initWithObjects:@"Storage",@"About CCNV",@"CCNV Help", nil];
    loginView.hidden=FALSE;
    AboutView.hidden=TRUE;
    
    isGridViewActive=FALSE;
    self.navigationItem.title = @"Storage";
    
    //set sugersyc keys
    APP.applicationID = @"/sc/3641183/222_198946960";
    APP.accessKeyId = @"MzY0MTE4MzEzNDgyMDMwNTIxODU";
    APP.privateAccessKey = @"YmFlMjBiMDMyMDA5NDFiNDg4MzI2N2ZhZGRjYjI3MGM";
   
    
    //  [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(getUserID) name:@"RefreshAccessToken" object:nil];
    [tableview setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidUnload
{
    //[super viewDidUnload];
        // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        [self buttonLayerSetForIos7:loginButton];
        [self buttonLayerSetForIos7:clearSettingButton];
        [self buttonLayerSetForIos7:rememberButton];
        [self buttonLayerSetForIos7:SugarSynButton];
        [self buttonLayerSetForIos7:vinasButton];
        [self buttonLayerSetForIos7:googleDriveButton];



        
    }
    

    

    rememberButton.userInteractionEnabled = TRUE;
    userName.userInteractionEnabled = TRUE;
    password.userInteractionEnabled = TRUE;
    loginButton.userInteractionEnabled = TRUE;
    
    [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.4];
       
    //get loging values 
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"usernameSS"]&&![[[NSUserDefaults standardUserDefaults] valueForKey:@"usernameSS"]isEqualToString:@""]) {
        
        userName.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"usernameSS"];
        password.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"passwordSS"];
        rememberButton.selected = TRUE;
//        userName.enabled=FALSE;
//        password.enabled=FALSE;
    }
    else{
        
        userName.text = @"";
        password.text = @"";
//        userName.enabled=TRUE;
//        password.enabled=TRUE;
    }
    [self SetNavigationBar];
}

/**
 *  this method used for customized navigation bar which is top of the view.
 */
-(void)SetNavigationBar{
    //set leftbar button
    if(!isIpad){
        
        
        self.navigationItem.leftBarButtonItem=nil;
        UIButton *btnsettings=[UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *settingimg=[UIImage imageNamed:@"setting.png"];
        btnsettings.frame=CGRectMake(0, 0, 32, 32);
        [btnsettings setImage:settingimg forState:UIControlStateNormal];
        [btnsettings addTarget:self action:@selector(Settings_clicked) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *Setting = [[UIBarButtonItem alloc]initWithCustomView:btnsettings];
        self.navigationItem.leftBarButtonItem = Setting;
        
    }else{
        UIBarButtonItem *logout = [[UIBarButtonItem alloc]initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout_clicked)];
        self.navigationItem.rightBarButtonItem=logout;
        
        [self.navigationItem setHidesBackButton:YES];
        self.navigationItem.title = @"";
        
        UILabel *lblTitle =[[UILabel alloc] initWithFrame:CGRectMake(0, 0,mainview.frame.size.width,40)];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        lblTitle.text=@"Settings";
        lblTitle.font=[UIFont boldSystemFontOfSize:18];
        lblTitle.textColor=[UIColor whiteColor];
        lblTitle.textAlignment=NSTextAlignmentCenter;
        [self.navigationController.navigationBar addSubview:lblTitle];
        
        lblSubTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0,320,40)];
        [lblSubTitle setBackgroundColor:[UIColor clearColor]];
        lblSubTitle.text=[arrServerlist objectAtIndex:0];
        lblSubTitle.textColor=[UIColor whiteColor];
        lblSubTitle.font=[UIFont boldSystemFontOfSize:18];
        lblSubTitle.textAlignment=NSTextAlignmentCenter;
        
        if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft||[[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight){
            
            lblSubTitle.frame=CGRectMake(300, 0, 724, lblSubTitle.frame.size.height);
            
        }
        else{
            lblSubTitle.frame=CGRectMake(300, 0, 468, lblSubTitle.frame.size.height);
        }
        
        [self.navigationController.navigationBar addSubview:lblSubTitle];
        
        lblSubTitle.text=[arrServerlist objectAtIndex:0];
        selectionview.hidden=FALSE;
        loginView.hidden=TRUE;
        AboutView.hidden=TRUE;
        
        [tableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    loginView_iphone.hidden=TRUE;
    selectionview.hidden=FALSE;
}

-(void)buttonLayerSetForIos7:(UIButton *)button
{
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    button.layer.cornerRadius = 8;
    button.layer.masksToBounds = YES;
}

/**
 * This method navigate controller to the Sugar Syncc Login view.
 */

-(IBAction)sugersync_clicked:(id)sender;
{
    [self login_Clicked:nil];
    
    /*
    if(!isIpad){
        
    selectionview.hidden=TRUE;
    loginView_iphone.hidden=FALSE;
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.45];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[loginView_iphone layer] addAnimation:animation forKey:@"loginview"];
    
        self.navigationItem.title=@"SugerSync";
        self.navigationItem.leftBarButtonItem=nil;
        btnback=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnback setImage:[UIImage imageNamed:@"btn-back.png"] forState:UIControlStateNormal];
        [btnback setFrame:CGRectMake(0, 0, 50, 30)];
        [btnback addTarget:self action:@selector(ShowSelectionView) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *back=[[UIBarButtonItem alloc] initWithCustomView:btnback];
        self.navigationItem.leftBarButtonItem=back;
    }
    else{
        selectionview.hidden=TRUE;
        loginView.hidden=FALSE;
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.45];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[loginView layer] addAnimation:animation forKey:@"loginview"];
        
        lblSubTitle.text=@"SugerSync";
        self.navigationItem.leftBarButtonItem=nil;
        btnback=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnback setImage:[UIImage imageNamed:@"btn-back.png"] forState:UIControlStateNormal];
        [btnback setFrame:CGRectMake(300,7, 50, 30)];
        [btnback addTarget:self action:@selector(ShowSelectionView) forControlEvents:UIControlEventTouchUpInside];
       
        [self.navigationController.navigationBar addSubview:btnback];

    }
     */
}

/**
 * This method used for animated view when user want to go back from sugar syncc login page.
 */
-(void)ShowSelectionView{
    [userName resignFirstResponder];
    [password resignFirstResponder];
    if(!isIpad){
        selectionview.hidden=FALSE;
        loginView_iphone.hidden=TRUE;
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.45];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromLeft];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[selectionview layer] addAnimation:animation forKey:@"loginview"];
    
        self.navigationItem.title=@"Storage";
        [btnback removeFromSuperview];
        [self SetNavigationBar];
    }
    else{
        selectionview.hidden=FALSE;
        loginView.hidden=TRUE;
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.45];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromLeft];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[selectionview layer] addAnimation:animation forKey:@"loginview"];
    
        lblSubTitle.text=@"Storage";
        btnback=nil;
        [btnback removeFromSuperview];
     //   [self SetNavigationBar];

    }
}

/**
 * This method used for further use as its functionality is not defined.
 */
-(IBAction)vinas_clicked:(id)sender{
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Under Construction" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

/**
 * This method used for save SugarSync credentials.
 */

-(void)Settings_clicked{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * this method will do logout.
 * it will reset refreshtoken.
 */

-(IBAction)logout_clicked{
    
    APP.refreshToken = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/**
 * This method used if user want to save their SugarSync credentials.
 */

-(IBAction)rememberMe_clicked:(id)sender{

    // save loging deatials in to NSUserdefalut keys
    if(segment.selectedSegmentIndex==0){
        
        UIButton *btn = (UIButton*)(id)sender;
        btn.selected = !btn.selected;
        [[NSUserDefaults standardUserDefaults] setBool:btn.selected forKey:@"RememberForSuger"];
        
        userName_str = userName.text;
        password_str = password.text;
        
        [USERDEFAULTS setValue:userName_str forKey:@"usernameSS"];
        [USERDEFAULTS setValue:password_str forKey:@"passwordSS"];
        [USERDEFAULTS  synchronize];
        
    }
    
    if(!isIpad){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [btnback removeFromSuperview];
        [self ShowSelectionView];
    }
}

/**
 * This will clear both username and password fields and set to be blank.
 */

-(IBAction)Clear_clicked:(id )sender
{
    userName.text=@"";
    password.text=@"";
    
    
    userName_str = userName.text;
    password_str = password.text;
    
    
    userName.enabled=TRUE;
    password.enabled=TRUE;
    
    if(segment.selectedSegmentIndex==0){
        
        [USERDEFAULTS setValue:userName_str forKey:@"usernameSS"];
        [USERDEFAULTS setValue:password_str forKey:@"passwordSS"];
        [USERDEFAULTS  synchronize];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    if(isIpad){
        [self loadBanner];
        adTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(loadBanner) userInfo:nil repeats:YES];
    }
  
    [super viewDidAppear:animated];
}



- (void)loadBanner {
    [bannerview performSelectorInBackground:@selector(loadImageFromURL) withObject:nil];
}
- (void)viewDidDisappear:(BOOL)animated{
    [adTimer invalidate];
    adTimer = nil;
    
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    btnback? [btnback removeFromSuperview]:nil;

    for (id titleView in [self.navigationController.navigationBar subviews]) {
        if ([titleView isKindOfClass:[UILabel class]]) {
            [titleView removeFromSuperview];
        }
    }
}


#pragma mark - tableview delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
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
    
    cell.textLabel.text = [arrServerlist objectAtIndex:indexPath.section];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    lblSubTitle.text=[arrServerlist objectAtIndex:indexPath.section];
    //show selected view
    if(indexPath.section==0)
    {
        selectionview.hidden=FALSE;
        loginView.hidden=TRUE;
        AboutView.hidden=TRUE;
        
    }
    else if (indexPath.section==1)
    {
        selectionview.hidden=TRUE;
        loginView.hidden=TRUE;
        AboutView.hidden=false;
    }
    else if (indexPath.section==2){
        HelpViewController *helpview=[[HelpViewController alloc]initWithNibName:@"HelpViewController_ipad" bundle:nil];
        [self.navigationController pushViewController:helpview animated:YES];
    }
    
   // [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

/**
 * this method will call login webservice in connection .
 * it pops alert if username or password value is blank , and update User object in (connectionDidFinishLoading) on successful login  method
 */

-(IBAction)login_Clicked:(id)sender{
    
  
//     [ApplicationDelegate.HUD setHidden:FALSE];//shoe indicator
    
    //set all flags 
    [userName resignFirstResponder];
    [password resignFirstResponder];
    userName.userInteractionEnabled = FALSE;
    password.userInteractionEnabled = FALSE;
    loginButton.userInteractionEnabled = FALSE;
    rememberButton.userInteractionEnabled = FALSE;
    if (!self.isAuthorized) {
        
        SHOW_ALERT(@"Google Drive", @"Please Login to Google Drive", nil, @"OK", nil, nil)
    }else{
        GoogleDriveContentListingViewController *googleDriveListViewcontroller =[[GoogleDriveContentListingViewController alloc]initWithNibName:@"GoogleDriveContentListingViewController_iPad" bundle:nil];
        googleDriveListViewcontroller.checkRoot=YES;
        [self.navigationController pushViewController:googleDriveListViewcontroller animated:YES];
    }
    /*
    
    //pop alert if username or password in blank 
    if ([userName.text isEqualToString:@""] || [password.text isEqualToString:@""]) {
        SHOW_ALERT(@"SugerSync", @"Username or password cannot be blank", nil, @"OK", nil, nil)
        userName.userInteractionEnabled = TRUE;
        password.userInteractionEnabled = TRUE;
        loginButton.userInteractionEnabled = TRUE;
        rememberButton.userInteractionEnabled = TRUE;
     
         [ApplicationDelegate.HUD setHidden:TRUE];
        return;
    }

    //login 
    NSString *xmlString = [NSString stringWithFormat:
                           @"<appAuthorization> \
                           <username>%@</username> \
                           <password>%@</password> \
                           <application>%@</application> \
                           <accessKeyId>%@</accessKeyId> \
                           <privateAccessKey>%@</privateAccessKey> \
                           </appAuthorization>",userName.text,password.text,APP.applicationID,APP.accessKeyId,APP.privateAccessKey];
    
    NSData *thumbsupData = [xmlString dataUsingEncoding: NSASCIIStringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:@"%@app-authorization",BaseURL];
    theURL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest addValue:@"application/xml; charset=UTF-8" forHTTPHeaderField:@"Content-type"];
    [theRequest setHTTPBody:thumbsupData];
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
        [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        APP.refreshToken=nil;
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

#pragma mark - 
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
    
    if (connection == Connection1)
    {
        //set access token 
        [ResponseData1 setLength:0];
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSDictionary* headers = [httpResponse allHeaderFields];
       // NSLog(@"Refresh Token: %@",[headers valueForKey:@"Location"]);
        
        if (![headers valueForKey:@"Location"]) {
            SHOW_ALERT(@"CCNV", @"Username or password incorrect", nil, @"OK", nil, nil)
            userName.userInteractionEnabled = TRUE;
            password.userInteractionEnabled = TRUE;
            loginButton.userInteractionEnabled = TRUE;
            rememberButton.userInteractionEnabled = TRUE;
         
             [ApplicationDelegate.HUD setHidden:TRUE];
            return;
        }

        APP.refreshToken = [NSString stringWithFormat:@"%@",[[headers valueForKey:@"Location"]stringByReplacingOccurrencesOfString:@"https://api.sugarsync.com/app-authorization/" withString:@""]];
        
        ApplicationDelegate.refreshToken=[headers valueForKey:@"Location"];
         NSLog(@"Refresh Token: %@", ApplicationDelegate.refreshToken);
        
        
    }
    
    else if(connection == Connection2){
         [ResponseData2 setLength:0];
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSDictionary* headers = [httpResponse allHeaderFields];
        APP.accessToken = [headers valueForKey:@"Location"];
        NSLog(@"Access Token = %@",APP.accessToken );
        
//        ApplicationDelegate.accessToken=ApplicationDelegate.refreshToken;
//         NSLog(@"Access Token = %@",APP.accessToken );
        
    }
       
    else if(connection == Connection3){
         [ResponseData3 setLength:0];
      //  NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        //NSLog(@"Status code : %d",[httpResponse statusCode]);
     //   NSDictionary* headers = [httpResponse allHeaderFields];
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
    
    if (connection == Connection1){ //login responce
       
        
        NSString *responsestring= [[NSString alloc] initWithData:ResponseData1 encoding:NSUTF8StringEncoding];
        NSLog(@"responsestring = %@",responsestring);

        if(![responsestring isEqualToString:@""]){
            NSString *start = @"<h3>";
            NSRange starting = [responsestring rangeOfString:start];
            if(starting.location != NSNotFound){
                NSString *end = @"</h3>";
                NSRange ending = [responsestring rangeOfString:end];
                NSString *str = [responsestring substringWithRange:NSMakeRange(starting.location + starting.length, ending.location - (starting.location + starting.length))];
                
                if(![str isEqualToString:@"invalid user credentials"]){
                    [self getUserID];//get user id
                }
                
            }
        }
        else if (ApplicationDelegate.refreshToken){
            [self getUserID];
        }
       
    }
    else if(connection == Connection2){ //user info 
        
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
        
        NSString *responsestring= [[NSString alloc] initWithData:ResponseData3 encoding:NSUTF8StringEncoding];
        NSLog(@"responsestring = %@",responsestring);
        
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
              
        //set all flags 
        [ApplicationDelegate.HUD setHidden:TRUE];
        userName.userInteractionEnabled = TRUE;
        password.userInteractionEnabled = TRUE;
        loginButton.userInteractionEnabled = TRUE;
        rememberButton.userInteractionEnabled = TRUE;

        //set NSUserdefault value
        if(!isIpad){
                [USERDEFAULTS setValue:userName.text forKey:@"usernameSS"];
                [USERDEFAULTS setValue:password.text forKey:@"passwordSS"];
                [USERDEFAULTS  synchronize];
        
        }
        // navigate to selcted workspace
        
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

        
        [self.navigationController pushViewController:objWork animated:YES];
        
        
//        FilesViewController *filesview;
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
    //get user id
    NSString *xmlString = [NSString stringWithFormat:
                           @"<tokenAuthRequest> \
                           <accessKeyId>%@</accessKeyId> \
                           <privateAccessKey>%@</privateAccessKey> \
                           <refreshToken>%@</refreshToken> \
                           </tokenAuthRequest>",APP.accessKeyId,APP.privateAccessKey,APP.refreshToken];
    
    NSData *thumbsupData = [xmlString dataUsingEncoding: NSASCIIStringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@authorization",BaseURL];
    theURL = [NSURL URLWithString:urlString];
    
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
 * This method gives loged in Users info.
 */

-(void)getUserInfo{
    ///get user info 
    NSString *urlString = [NSString stringWithFormat:@"%@user/%@",BaseURL,APP.userID];
    theURL = [NSURL URLWithString:urlString];

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)SegmentChange:(id)sender{
    if (segment.selectedSegmentIndex == 0) {
        userName.placeholder = @"SugarSync ID";
    }
    else {
        userName.placeholder = @"Vinas ID";
        
        [[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"We are working hard to get it done very soon!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        segment.selectedSegmentIndex = 0;
        [self SegmentChange:segment];
    }
}

#pragma mark - UIInterfaceOrientation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft||toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        
        lblSubTitle.frame=CGRectMake(300, 0, 724, lblSubTitle.frame.size.height);
        
    }
    else{
        lblSubTitle.frame=CGRectMake(300, 0, 468, lblSubTitle.frame.size.height);
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        
        lblSubTitle.frame=CGRectMake(300, 0, 724, lblSubTitle.frame.size.height);
        
    }
    else{
        lblSubTitle.frame=CGRectMake(300, 0, 468, lblSubTitle.frame.size.height);
    }
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
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

- (IBAction)googleDriveAuthButtonClicked:(id)sender {
    if (!self.isAuthorized) {
        // Sign in.
        SEL finishedSelector = @selector(viewController:finishedWithAuth:error:);
        GTMOAuth2ViewControllerTouch *authViewController =
        [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
                                                   clientID:kClientID
                                               clientSecret:kClientSecret
                                           keychainItemName:kKeychainItemName
                                                   delegate:self
                                           finishedSelector:finishedSelector];
        NSDictionary *params = [NSDictionary dictionaryWithObject:@"en"
                                                           forKey:@"hl"];
        authViewController.signIn.additionalAuthorizationParameters=params;
        [self presentViewController:authViewController animated:YES completion:nil];
    } else {
        // Sign out
        [[[UIAlertView alloc]initWithTitle:@"Sign Out" message:@"Do you want to sign out" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No", nil]show ];
            }
}
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (error) {
        SHOW_ALERT(@"CCNV", @"Google Drive Login failed", nil, @"OK", nil, nil);

    }else{
                [self isAuthorizedWithAuthentication:auth];
    }

    
}
- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth
{
    NSLog(@"isAuthorizedWithAuthentication:");
    GoogleDriveManager *driverManager=[GoogleDriveManager sharedGoogleDriveManager];
    [[self driveService] setAuthorizer:auth];
    [[driverManager driveService] setAuthorizer:auth];
    
   // NSLog(@"AccessToken%@",auth.accessToken);
    
    if (auth.accessToken) {
      driverManager.accessTokenValue=auth.accessToken;
    }
    
    // and finally here you can load all files
   // NSLog(@"*ACCESS,,%@",auth.refreshToken);
    ;
}

- (GTLServiceDrive *)driveService
{
    NSLog(@"driveService");
    
    static GTLServiceDrive *service = nil;
    
    if (!service)
    {
        service = [[GTLServiceDrive alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    }
    
    return service;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
        //[self googleDriveAuthButtonClicked:nil];
    }else{
        
    }
}

@end