//
//  HelpViewController.m
//  CCNV
//
//  Created by  Linksware Inc. on 06/02/13.
//
//

#import "HelpViewController.h"
#import "HelpDetailViewController.h"
@interface HelpViewController ()

@end

@implementation HelpViewController

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
    //Help option array
     arrServerlist=[[NSMutableArray alloc] initWithObjects:@"SugarSyncとは ",@"接続トップ画面",@"表示の切り替え",@"画像の編集",nil];
    
    //set UI as per device //////////////////////////////////////////////////////////////////
    if(isIpad)
    {
        self.navigationItem.leftBarButtonItem=nil;
        self.navigationItem.rightBarButtonItem=nil;
        UIButton *btnsettings=[UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *settingimg=[UIImage imageNamed:@"setting.png"];
        btnsettings.frame=CGRectMake(0, 0, 32, 32);
        [btnsettings setImage:settingimg forState:UIControlStateNormal];
        [btnsettings addTarget:self action:@selector(Settings_clicked) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *Setting = [[UIBarButtonItem alloc]initWithCustomView:btnsettings];
        
        
        UILabel *lblTitle =[[UILabel alloc] initWithFrame:CGRectMake(0, 0,200,40)];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        lblTitle.text=@"CCNV Help";
        lblTitle.font=[UIFont boldSystemFontOfSize:17];
        lblTitle.textColor=[UIColor whiteColor];
        lblTitle.textAlignment=NSTextAlignmentCenter;
        
        UIBarButtonItem *titlebtn = [[UIBarButtonItem alloc]initWithCustomView:lblTitle];
        
        self.navigationItem.leftBarButtonItems =[NSArray arrayWithObjects:Setting,titlebtn, nil];
        
        lblSubTitle=[[UILabel alloc] initWithFrame:CGRectMake(0, 0,468,40)];
        [lblSubTitle setBackgroundColor:[UIColor clearColor]];
        lblSubTitle.text=[arrServerlist objectAtIndex:0];
        lblSubTitle.textColor=[UIColor whiteColor];
        lblSubTitle.font=[UIFont boldSystemFontOfSize:17];
        lblSubTitle.textAlignment=NSTextAlignmentCenter;
        
        if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft||[[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight){
            
            lblSubTitle.frame=CGRectMake(300, 0, 724, lblSubTitle.frame.size.height);
            
        }
        else{
            lblSubTitle.frame=CGRectMake(300, 0, 438, lblSubTitle.frame.size.height);
        }
        UIBarButtonItem *subtitlebtn = [[UIBarButtonItem alloc]initWithCustomView:lblSubTitle];
        
        self.navigationItem.rightBarButtonItem=subtitlebtn;
        
        [super viewDidLoad];
        //    screenimag.layer.borderColor=[[UIColor blackColor]CGColor];
        //    screenimag.layer.borderWidth=2;
        mainview.layer.borderColor=[[UIColor blackColor]CGColor];
        mainview.layer.borderWidth=2;
        
        self.view.layer.borderWidth=2;
        self.view.layer.borderColor=[[UIColor blackColor]CGColor];
        
        
        [self LoadHelpDocuments :0]; ///load document for 1 help 
    }
    else{
        self.navigationItem.leftBarButtonItem=nil;
        self.navigationItem.rightBarButtonItem=nil;
        UIButton *btnsettings=[UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *settingimg=[UIImage imageNamed:@"setting.png"];
        btnsettings.frame=CGRectMake(0, 0, 32, 32);
        [btnsettings setImage:settingimg forState:UIControlStateNormal];
        [btnsettings addTarget:self action:@selector(Settings_clicked) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *Setting = [[UIBarButtonItem alloc]initWithCustomView:btnsettings];
        
        self.navigationItem.leftBarButtonItem=Setting;
        
        self.navigationItem.title=@"CCNV Help";
    }
    // Do any additional setup after loading the view from its nib.
    
     [tblview setBackgroundColor:[UIColor clearColor]];
}

/**
 * this method loads PDF file for help option.
 * used in ipad only
 */
-(void)LoadHelpDocuments :(int )index{
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%02i-1",index+1] ofType:@"pdf"];
//    
//    NSData *htmlData = [NSData dataWithContentsOfFile:path];
//    
//    [webview loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    
   // [webview loadRequest:request];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%02i-1",index+1] ofType:@"pdf"];
    
    NSLog(@"filePath%@",path);
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [webview loadRequest:request];
    
    [webview setScalesPageToFit:YES];
}

/**
 * this method navigate controller to the Settings View.
 */
-(void)Settings_clicked{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [arrServerlist count];
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
    
    //show selected view
   
   lblSubTitle.text=[arrServerlist objectAtIndex:indexPath.section];
    if(!isIpad){
        HelpDetailViewController *Hdetailview=[[HelpDetailViewController alloc] initWithNibName:@"HelpDetailViewController" bundle:nil];
        Hdetailview.strtitle=[arrServerlist objectAtIndex:indexPath.section];
        [self.navigationController pushViewController:Hdetailview animated:YES];
    }
    else{
          [self LoadHelpDocuments :indexPath.section];
    }
    
}

//#pragma mark - uiwebviewdelegate
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//    
//    [ApplicationDelegate.HUD setHidden:FALSE];
//    return YES;
//}
//
//- (void)webViewDidStartLoad:(UIWebView *)webView{
//    
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    [ApplicationDelegate.HUD setHidden:TRUE];
//}
//
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
//    [ApplicationDelegate.HUD setHidden:TRUE];
//}

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
    // Return YES for supported orientations
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight){
         lblSubTitle.frame=CGRectMake(300, 0, 724, lblSubTitle.frame.size.height);
    }
    else{
         lblSubTitle.frame=CGRectMake(300, 0, 468, lblSubTitle.frame.size.height);
    }
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    // return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end