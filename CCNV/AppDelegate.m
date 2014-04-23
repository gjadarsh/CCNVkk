//
//  AppDelegate.m
//  SugarSynDemo
//
//  Created by  Linksware Inc. on 20/08/12.
//  Copyright © VINAS Co., Ltd. 2011 - 2013. All rights reserved.
//

#import "AppDelegate.h"
#import "Global.h"
#import "CCNVLoginViewConroller.h"
#import "User.h"
#import "VIdbConfig.h"
#import "Reachability.h"
#import "EvernoteSDK.h"
#import "GoogleDriveManager.h"
@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize applicationID,accessKeyId,privateAccessKey,refreshToken,userID,accessToken;
@synthesize albumContent,content_str,imageXML;
@synthesize player,HUD,arrSugerSyncFolder;
@synthesize currentUser,selectedindex,connectionRequired;
@synthesize monthName,ThumbCount,TokenExpired,TokenRequestStarted;
//@synthesize firstTemp;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self evernoteEnabilingStep];
    [self setUpGoogleDriveMAnager];
   // [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    TokenExpired=FALSE;
    arrImageFileList=[[NSMutableArray alloc] init];
    arrImageListForCal=[[NSMutableArray alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
      
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"CCNV" message:@"current version of CCNV is not supported in ios 4.0 or lesser version " delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert setTag:111];
        [alert show];
        
    }
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        isIpad=TRUE;
         self.viewController = [[CCNVLoginViewConroller alloc] initWithNibName:@"CCNVLoingViewController_ipad" bundle:nil];
        
    }else{
         isIpad=FALSE;
        
              
         self.viewController = [[CCNVLoginViewConroller alloc] initWithNibName:@"CCNVLoginViewConroller" bundle:nil];
    }
    
    //open database if its close
    
    db = [VIDatabase databaseWithName:kDBName];
    if (![db open]) {
        NSLog(@"Could not open db.");
    }else {
        NSLog(@"Open db.");
    }
    //set currentUser 
    currentUser=[[User alloc] init];
    currentFile=[[File alloc] init];
    
    navController = [[UINavigationController alloc]initWithRootViewController:self.viewController];
    navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    
    //add activity indicator 
    [self SetUpHudView];
    
    [self setCloseButton];    
//    [self showCloseButton];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(RefreshAccessToken) name:@"RefreshAccessToken" object:nil];
   //   [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(done:) name:@"DismissPhotoViewer" object:nil];
    
    //Change the host name here to change the server your monitoring
 
	//hostReach = [Reachability reachabilityWithHostName: @"www.google.co.in"] ;
    hostReach = [Reachability reachabilityWithHostname:@"www.google.com"];
	[hostReach startNotifier];

	
    internetReach = [Reachability reachabilityForInternetConnection];
	[internetReach startNotifier];

    
    wifiReach = [Reachability reachabilityForLocalWiFi] ;
	[wifiReach startNotifier];

    
    connectionRequired=[self isInternetReachable];

    return YES;
}
#pragma mark -Add Common HUD View
-(void)SetUpHudView
{
    HUD = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
    [HUD setHidden:TRUE];
}


#pragma mark -Evernote EnabilingStep
-(void)evernoteEnabilingStep
{
    //EverNote Sdk
    //http://blog.letzflow.com/twitter-integration-on-ios-6/
    //http://stackoverflow.com/questions/11600621/iphone-twitter-api-get-users-followers-following
    
    // Initial development is done on the sandbox service
    // Change this to BootstrapServerBaseURLStringUS to use the production Evernote service
    // Change this to BootstrapServerBaseURLStringCN to use the Yinxiang Biji production service
    // Bootstrapping is supported by default with either BootstrapServerBaseURLStringUS or BootstrapServerBaseURLStringCN
    // BootstrapServerBaseURLStringSandbox does not support the  Yinxiang Biji service
    NSString *EVERNOTE_HOST = BootstrapServerBaseURLStringUS;
    
    // Fill in the consumer key and secret with the values that you received from Evernote
    // To get an API key, visit http://dev.evernote.com/documentation/cloud/
    
    /*
     Consumer Key: ccnv2014
     Consumer Secret: 8f4defa870df60f6
     userID adarshkudavoor1
     password adarshkudavoor1
     */
    NSString *CONSUMER_KEY = @"gjadarsh-6231";
    NSString *CONSUMER_SECRET = @"abadf0d32bc07bc8";
    
    
    // set up Evernote session singleton
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST
                              consumerKey:CONSUMER_KEY
                           consumerSecret:CONSUMER_SECRET];
    
    
    

}
#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==111){
        exit(0);
    }
    else if (alertView.tag==222){
        if(buttonIndex==1){
            //call method for stop current download.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopDownload" object:nil];
            
            [self hideCloseButton];
            [HUD setHidden:TRUE];
        }

    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.tag==2000){
        isNotificationShow=FALSE;
        return;
    }
}
/*
- (void) configureTextField: (UITextField*) textField imageView: (UIImageView*) imageView reachability: (Reachability*) curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
   // connectionRequired= [curReach connectionRequired];
    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Access Not Available";
          
            //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
            connectionRequired= YES;
        
            if(!isNotificationShow){
                isNotificationShow=TRUE;
            
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"Please check your internet connection and Try Again.." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                alert.tag=2000;
                [alert show];
            }
            break;
        }
            
        case ReachableViaWWAN:
        {
            statusString = @"Reachable WWAN";
            connectionRequired=NO;
        
            break;
        }
        case ReachableViaWiFi:
        {
            statusString= @"Reachable WiFi";
            connectionRequired=NO;
          
            break;
        }
    }
    if(connectionRequired)
    {
        NSLog( @"%@, Connection Required", statusString);
  
    }
}

- (void) configureConnection: (Reachability*) curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    connectionRequired= [curReach connectionRequired];
    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Access Not Available";
            //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
            connectionRequired= NO;
            isWifiON = NO;
            break;
        }
            
        case ReachableViaWWAN:
        {
            statusString = @"Reachable WWAN";
            isWifiON= NO;
            break;
        }
        case ReachableViaWiFi:
        {
            statusString= @"Reachable WiFi";
            
            isWifiON = YES;
           // int imageCount;
         //   imageCount = [app.sk lookupTotalCountFrom:@"Images"];
//            if (imageCount>0) {
              //  if (self.isWifiON) {
             //       [self showWifiConnectionAlert];
              //  }
           // }
            
            break;
        }
    }
    if(connectionRequired)
    {
        statusString= [NSString stringWithFormat: @"%@, Connection Required", statusString];
    }
    
    if(!is3Gor4G && connectionRequired){
        if(!isNotificationShow){
            isNotificationShow=TRUE;
            connectionRequired=TRUE;
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"Please check your internet connection and Try Again.." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alert.tag=2000;
            [alert show];
        }
    }
    NSLog(@"%@",statusString);
}


- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    if(curReach == hostReach)
	{
		[self configureConnection:curReach];
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
         connectionRequired= [curReach connectionRequired];
        
        if(connectionRequired)
        {
            NSLog(@"Cellular data network is available.\n  Internet traffic will be routed through it after a connection is established.") ;
            is3Gor4G=FALSE;
        }
        else
        {
            is3Gor4G=TRUE;
            NSLog(@"Cellular data network is active.\n  Internet traffic will be routed through it.");
        }
    }
    
	if(curReach == internetReach)
	{
		[self configureConnection:curReach];
	}
	if(curReach == wifiReach)
	{
		[self configureConnection:curReach];
	}
	
}
*/
//Called by Reachability whenever status changes.

- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	connectionRequired=![self isInternetReachable];
}

/**
 * this method called to update history table of database

 */
-(void)UpdateDatabase :(NSString *)history
{
   ///update databse for history 
    
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM,dd YYYY HH:mm:SS"];
    NSString *hDateTime=[formatter stringFromDate:[NSDate date]];
   // NSLog(@"cdate :%@",hDateTime);
    
    NSString *strQuery=[NSString stringWithFormat:@"INSERT INTO History (Hname,hDateTime) VALUES ('%@','%@')",history,hDateTime];
    
    
    [db executeUpdate:strQuery];
    
//    NSLog(@"lastInsertRowId:%lld",[db lastInsertRowId]);
//    NSLog(@"Event Name = %@",history);

}

/**
 * this method called to load history from database
 */
-(NSMutableArray *)loadHistory{
    
    ///loads history from database
    
    NSMutableArray *arrhistory=[[NSMutableArray alloc] init ];
    
    rs = [db executeQuery:@"select * from History"];
    
    while ([rs next]) {
       // int hid=[rs intForColumnIndex:0];
        NSString *strname=[rs stringForColumnIndex:1];
        NSString *strTime=[rs stringForColumnIndex:2];
           
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
        [dict setObject:strname forKey:@"name"];
        [dict setObject:strTime forKey:@"time"];
       
        [arrhistory addObject:dict];
       
    }

    return arrhistory;
}

- (void)done:(id)sender {
    if(isImageFromCalView){
        isImageFromCalView=FALSE;
        
        [navController popViewControllerAnimated:YES];
    }
    else{
        [navController dismissViewControllerAnimated:YES completion:nil];
    }
    
}
#pragma mark - UIInterfaceOrientation
-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
//    firstTemp = 0;
    return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    
//    int interfaceOrientation = 0;
//    
//    if (!isCalViewOriantation) {
//        // NSLog(@"=====OrientationMaskAll=====");
//        interfaceOrientation = UIInterfaceOrientationMaskAll;
//    }
//    
//    else{
//      
//        interfaceOrientation = UIInterfaceOrientationMaskPortrait;
//    }
//    firstTemp = 0;
    return UIInterfaceOrientationMaskAll;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
//    NSDateFormatter *dateformater=[[NSDateFormatter alloc] init];
//    [dateformater setDateFormat:@"dd/MM/yyyy hh:mm:ss"];
//    NSLog(@"date in ResignActive: %@",[dateformater stringFromDate:[NSDate date]]);
    [[NSUserDefaults standardUserDefaults]setObject:[NSDate date] forKey:@"dateWhenAppBecomeInactive"];
    
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    NSDateFormatter *dateformater=[[NSDateFormatter alloc] init];
    [dateformater setDateFormat:@"dd/MM/yyyy hh:mm:ss"];
    
    NSDate *resigntime=[[NSUserDefaults standardUserDefaults]valueForKey:@"dateWhenAppBecomeInactive"];
    
    NSTimeInterval timeinterval=[[NSDate date] timeIntervalSinceDate:resigntime] ;
    double hours = floor(timeinterval / 60 / 60);
      NSLog(@"date in EnterForeground: %@ and timeinterval:%f",[dateformater stringFromDate:resigntime],hours);
    if(timeinterval>3600){
      //  [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshAccessToken" object:nil];
//        NSArray *arrNavController=[navController viewControllers];
//        [navController popToViewController:[arrNavController objectAtIndex:1] animated:NO];
//        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"Your session is expired please connect again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
    }
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[EvernoteSession sharedSession] handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //remove all temp file from NSDocumentDirectory
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSFileManager *fileMgr = [NSFileManager defaultManager];
//    NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:[paths objectAtIndex:0] error:nil];
//    for (NSString *filename in fileArray)  {
//        
//        [fileMgr removeItemAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:filename] error:NULL];
//    }
//
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL canHandle = NO;
    if ([[NSString stringWithFormat:@"en-%@", [[EvernoteSession sharedSession] consumerKey]] isEqualToString:[url scheme]] == YES) {
        canHandle = [[EvernoteSession sharedSession] canHandleOpenURL:url];
    }
    return canHandle;
}


/**
 * this method add cancel download button on window
 * frame of cancel button will set in MBProgressHUD class .
 */
- (void)setCloseButton {
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.tag = 200;
    [closeBtn setImage:[UIImage imageNamed:@"whitecross.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(stopDownload) forControlEvents:UIControlEventTouchUpInside];
    
    closeBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    

    [self.HUD addSubview:closeBtn];
    [closeBtn setHidden:TRUE];
}

/**
 * sets hidden flag false of cancel download button .
 
 */
- (void) showCloseButton{
    if (!closeBtn) {
        [self setCloseButton];
    }
    [closeBtn setHidden:FALSE];

    [self.HUD bringSubviewToFront:closeBtn];
}

/**
 * sets hidden flag true of cancel download button .
 */
- (void)hideCloseButton {
    [closeBtn setHidden:TRUE];
    HUD.labelText = @"Loading...";
    [HUD setLabelText:@"Loading..."];
//    [self.window bringSubviewToFront:closeBtn];
}

/**
 * shows alert for cancel downloading any file.
 */
- (void)stopDownload {
    NSLog(@"stop it now");
    
   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""  message:@"Are you sure you want to stop downloading ?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES ", nil];
    alert.tag=222;
    [alert show];
    
}

- (BOOL)isInternetReachable
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    if(reachability == NULL)
        return false;
    
    if (!(SCNetworkReachabilityGetFlags(reachability, &flags)))
        return false;
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
        // if target host is not reachable
        return false;
    
    
    BOOL isReachable = false;
    
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        // if target host is reachable and no connection is required
        //  then we'll assume (for now) that your on Wi-Fi
        isReachable = true;
    }
    
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            // ... and no [user] intervention is needed
            isReachable = true;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        // ... but WWAN connections are OK if the calling application
        //     is using the CFNetwork (CFSocketStream?) APIs.
        isReachable = true;
    }    
    return isReachable;   
}

+ (NSString*)weekdayForDate:(NSString*)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yyyy"];
    
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    // set swedish locale
    dateFormatter.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_EN"];
    
//    dateFormatter.dateFormat=@"MMMM";
//    NSString * monthString = [[dateFormatter stringFromDate:date] capitalizedString];
//    NSLog(@"month: %@", monthString);
    
    dateFormatter.dateFormat=@"EEEE";
    NSString * dayString = [[dateFormatter stringFromDate:date] capitalizedString];
//    NSLog(@"day: %@", dayString);
    
    return dayString;
}

#pragma mark - getAccessToken
-(void)RefreshAccessToken{
    //get user id
    if (ApplicationDelegate.TokenRequestStarted) {
        return;
    }
   
    ApplicationDelegate.TokenRequestStarted=TRUE;

//    [[[UIAlertView alloc]initWithTitle:@"" message:@"Access token expired. Please wait while application refreshes the AccessToken." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];

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
#pragma mark -NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
   
    
    if(connection == Connection2)
        ResponseData2 = nil;
    
   }

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
        
     if(connection == Connection2){
        [ResponseData2 setLength:0];
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSDictionary* headers = [httpResponse allHeaderFields];
        APP.accessToken = [headers valueForKey:@"Location"];
        NSLog(@"Access Token = %@",APP.accessToken );
        
        //        ApplicationDelegate.accessToken=ApplicationDelegate.refreshToken;
        //         NSLog(@"Access Token = %@",APP.accessToken );
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
      
     if(connection == Connection2)
        [ResponseData2 appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
   //user info
        
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
          //  [self getUserInfo];
        }
    [ApplicationDelegate.HUD setHidden:TRUE];
      ApplicationDelegate.TokenRequestStarted=FALSE;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TokenRefreshed" object:nil];
   // id obj= [navController.viewControllers objectAtIndex:[navController.viewControllers count]-1];

}

-(void)setUpGoogleDriveMAnager
{
    GoogleDriveManager *shareManager =[GoogleDriveManager sharedGoogleDriveManager];
    shareManager.driveService = [[GTLServiceDrive alloc] init];

    shareManager.driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                         clientID:kClientID
                                                                                     clientSecret:kClientSecret];

}
@end