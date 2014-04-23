//
//  SelectWorkspace.m
//  SugarSynDemo
//
//  Created by  Linksware Inc. on 21/08/12.
//  Copyright © VINAS Co., Ltd. 2011 - 2013. All rights reserved.
//

#import "SelectWorkspace.h"
#import "AppDelegate.h"
#import "Global.h"
#import "MoviePlayerController.h"
#import "PlayerViewController.h"
#import "File.h"
#import "ServerSelectionViewController.h"

@implementation SelectWorkspace
@synthesize selectedFolderName;
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
    [super viewDidLoad];

    
    self.navigationItem.title = @"Home";

    UIBarButtonItem *logout = [[UIBarButtonItem alloc]initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout_clicked)];
    self.navigationItem.rightBarButtonItem = logout;
    album_arr=[[NSMutableArray alloc]init ];
    
    UIButton *btnsettings=[UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *settingimg=[UIImage imageNamed:@"setting.png"];
    btnsettings.frame=CGRectMake(0, 0, 32, 32);
    [btnsettings setImage:settingimg forState:UIControlStateNormal];
    [btnsettings addTarget:self action:@selector(Settings_clicked) forControlEvents:UIControlEventTouchUpInside];
   // UIBarButtonItem *Setting = [[UIBarButtonItem alloc]initWithCustomView:btnsettings];
   // self.navigationItem.leftBarButtonItem = Setting;
 
    [album_arr addObjectsFromArray:ApplicationDelegate.arrSugerSyncFolder];

}
-(void)viewDidAppear:(BOOL)animated{
   // if(!isIpad){
       
        [self loadBanner];
        adTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(loadBanner) userInfo:nil repeats:YES];
   // }
}
- (void)loadBanner {
    [bannerview performSelectorInBackground:@selector(loadImageFromURL) withObject:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    tableview.userInteractionEnabled = TRUE;
    self.navigationItem.hidesBackButton=TRUE;
    //NSLog(@"APP.album_arr = %@", APP.albumContent);
    
}

/**
 * this method will pop the navigation controller to ServerSelectionViewController in iPhone .
 * and pops navigation controller to loginviewController in iPad.
 */
-(IBAction)Settings_clicked{
    if(!isIpad){
        for (UIViewController* viewController in self.navigationController.viewControllers) {
            if([viewController isKindOfClass:[ServerSelectionViewController class]])
            {
                [self.navigationController popToViewController:viewController animated:YES];
            }
            NSLog(@"%@",viewController.nibName);
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 * Logout.
 * and pops navigation controller to RootviewController in iPad.
 */

-(IBAction)logout_clicked{
    
    APP.refreshToken = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)viewDidDisappear:(BOOL)animated{
    [adTimer invalidate];
    adTimer = nil;
   
}
#pragma mark - UItableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [album_arr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    }
    
    File *obj=(File *)[album_arr objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.text = obj.strDisplayName;
    
    if([obj.strMediaType isEqualToString:@"folder"]||[obj.strMediaType isEqualToString:@"syncFolder"])
    {
        cell.imageView.image=[UIImage imageNamed:@"folder.png"];
    }
    else if([obj.strMediaType isEqualToString:@"application/pdf"])
    {
        
        cell.imageView.image=[UIImage imageNamed:@"pdf.png"];
    }
    else if([obj.strMediaType isEqualToString:@"image/jpeg"]||[obj.strMediaType isEqualToString:@"image/png"]||[obj.strMediaType isEqualToString:@"image/gif"])
    {
        
        cell.imageView.image=[UIImage imageNamed:@"imgIcon.png"];
    }
    else if([obj.strMediaType isEqualToString:@"audio/mpeg"]||[obj.strMediaType isEqualToString:@"audio/m4a"]||[obj.strMediaType isEqualToString:@"audio/mp4"])
    {
        cell.imageView.image=[UIImage imageNamed:@"audio.png"];
    } 
    else if([obj.strMediaType isEqualToString:@"video/quicktime"]||[obj.strMediaType isEqualToString:@"video/mp4"]||[obj.strMediaType isEqualToString:@"video/mpeg"]||[obj.strMediaType isEqualToString:@"video/mpeg4"]||[obj.strMediaType isEqualToString:@"video/3gp"]||[obj.strMediaType isEqualToString:@"video/x-msvideo"])
    {
        cell.imageView.image=[UIImage imageNamed:@"video.png"];
    } else{
        cell.imageView.image=[UIImage imageNamed:@"folder.png"];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   // dict = [[album_arr objectAtIndex:indexPath.row]valueForKey:@"ref"];
    tableview.userInteractionEnabled = FALSE;
    File *obj=(File *)[album_arr objectAtIndex:indexPath.row];
    
    if([obj.strMediaType isEqualToString:@"folder"]||[obj.strMediaType isEqualToString:@"syncFolder"])
    {
        currentFile=obj;
        workspaceContent *objWork;
        if (isIpad) {
            objWork=[[workspaceContent alloc] initWithNibName:@"workspaceContent_ipad" bundle:nil];
        }
        else{
            objWork=[[workspaceContent alloc] initWithNibName:@"workspaceContent" bundle:nil];}
        objWork.title=obj.strDisplayName;
        [self.navigationController pushViewController:objWork animated:YES];
    }
    else if([obj.strMediaType isEqualToString:@"image/jpeg"]||[obj.strMediaType isEqualToString:@"application/pdf"]||[obj.strMediaType isEqualToString:@"image/png"]||[obj.strMediaType isEqualToString:@"image/gif"])
    {
//        AlbumContent *file;
//        if(isIpad){
//            file = [[AlbumContent alloc]initWithNibName:@"AlbumContent_ipad" bundle:nil];
//        }else{
//            file = [[AlbumContent alloc]initWithNibName:@"AlbumContent" bundle:nil];
//        }
//        file.title=obj.strDisplayName;
//        UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:file action:@selector(logout_clicked)];
//        self.navigationItem.backBarButtonItem = back;
//        file.fileDict=obj;
//        [self.navigationController pushViewController:file animated:YES];
        
    }
    else if([obj.strMediaType isEqualToString:@"audio/mpeg"]||[obj.strMediaType isEqualToString:@"audio/m4a"]||[obj.strMediaType isEqualToString:@"audio/mp4"])
    {
        // NSString *strExt=[[dict1 objectForKey:@"displayName"] pathExtension];
        PlayerViewController *player;
        if(isIpad){
            player=[[PlayerViewController alloc] initWithNibName:@"PlayerViewController_ipad" bundle:nil];}
        else{
            player=[[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
        }
        player.fileUrl=obj.ref;
        player.objFile=obj;
        [self.navigationController pushViewController:player animated:YES];
        //video/quicktime
    } 
    else if([obj.strMediaType isEqualToString:@"video/quicktime"]||[obj.strMediaType isEqualToString:@"video/mp4"]||[obj.strMediaType isEqualToString:@"video/mpeg"]||[obj.strMediaType isEqualToString:@"video/mpeg4"]||[obj.strMediaType isEqualToString:@"video/3gp"]||[obj.strMediaType isEqualToString:@"video/x-msvideo"])
    {
        // NSString *strExt=[[dict1 objectForKey:@"displayName"] pathExtension];
        //mpeg
        MoviePlayerController *player;
        if(isIpad)
        {
            player=[[MoviePlayerController alloc] initWithNibName:@"MoviePlayerController_ipad" bundle:nil];
        }
        else{
            player=[[MoviePlayerController alloc] initWithNibName:@"MoviePlayerController" bundle:nil];}
        player.fileUrl=obj.ref;
        player.objFile=obj;
        [self.navigationController pushViewController:player animated:YES];
        //video/quicktime
    }
    else{
        currentFile=obj;
        workspaceContent *objWork;
        if (isIpad) {
            objWork=[[workspaceContent alloc] initWithNibName:@"workspaceContent_ipad" bundle:nil];
        }
        else{
            objWork=[[workspaceContent alloc] initWithNibName:@"workspaceContent" bundle:nil];}
        objWork.title=obj.strDisplayName;
        [self.navigationController pushViewController:objWork animated:YES];

    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
     return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - http connection method

-(void)retrieveContent{
    [ApplicationDelegate.HUD setHidden:FALSE];
    NSURL *theURL;
//    if([selectedFolderName isEqualToString:@"folders"]){
//    NSString *urlString =[NSString stringWithFormat:@"https://api.sugarsync.com/user/3983483/%@/contents",selectedFolderName];
//        theURL = [NSURL URLWithString:urlString];
//    }else{
        theURL = [NSURL URLWithString:selectedFolderName];
//}

    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:APP.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"GET"];
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
         [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if(theConnection) {
            
            ResponseData = [[NSMutableData alloc] init];
        }
        
        else {
            //NSLog(@"Error, Invalid Request");
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    ResponseData = nil;   
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    NSLog(@"content length : %llu",[response expectedContentLength]);
    NSLog(@"Status Code : %d",code);
    
    if (code == 401 & [response expectedContentLength] == 315) {
        ApplicationDelegate.TokenExpired = TRUE;
    }

    [ResponseData setLength:0];
//    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
//    NSDictionary* headers = [httpResponse allHeaderFields];

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [ResponseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    NSString *responsestring= [[NSString alloc] initWithData:ResponseData encoding:NSUTF8StringEncoding];
    NSLog(@"responsestring = %@",responsestring);
    
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
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:ResponseData];
        XMLParser *parser = [[XMLParser alloc] initXMLParser];
        [xmlParser setDelegate:parser];
        BOOL success = [xmlParser parse];
    
        if(success){
            //NSLog(@"No Errors In XML Parsing");
        }
        else{
            //NSLog(@"Error In XMLParsing");
        }   
        [album_arr addObjectsFromArray:ApplicationDelegate.albumContent];
        //NSLog(@"album array : %@",album_arr);
        [tableview reloadData];
        [ApplicationDelegate.albumContent removeAllObjects];
        [ApplicationDelegate.HUD setHidden:TRUE];
    }
}
-(void)workSpaceContent{
    
}
-(void)workspaceFileContent{
    
}
@end