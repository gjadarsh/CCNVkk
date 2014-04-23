//
//  AboutCCNVviewController.m
//  CCNV
//
//  Created by  Linksware Inc. on 1/16/2013.
//
//

#import "AboutCCNVviewController.h"

@interface AboutCCNVviewController ()

@end

@implementation AboutCCNVviewController

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
    
    self.navigationItem.leftBarButtonItem=nil;
    UIButton *btnsettings=[UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *settingimg=[UIImage imageNamed:@"setting.png"];
    btnsettings.frame=CGRectMake(0, 0, 32, 32);
    [btnsettings setImage:settingimg forState:UIControlStateNormal];
    [btnsettings addTarget:self action:@selector(Settings_clicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *Setting = [[UIBarButtonItem alloc]initWithCustomView:btnsettings];
    self.navigationItem.leftBarButtonItem = Setting;

    //get version info from plist file of app 
//    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
//    [dateformatter setDateFormat:@"yyyy-MM-dd hh:mm"];
    
    //load application version info from plist file
    NSLog(@"%@",[[NSBundle mainBundle] infoDictionary]);
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
     NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    lblVersionInfo.text=[NSString stringWithFormat:@"Version %@", version]; //show info
    //CFBundleShortVersionString

    lblbuildinfo.text=[NSString stringWithFormat:@"Build Version: %@ %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Bundle Date"], build];
    
    
    ///get file data 
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CCNV-mobile_ソフトウェア使用許諾契約書_issue08" ofType:@"doc"];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
 
   
    //load data in webview 
    [webview loadRequest:request];

    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

@end
