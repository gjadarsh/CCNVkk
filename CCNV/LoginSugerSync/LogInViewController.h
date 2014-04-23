//
//  ViewController.h
//  SugarSynDemo
//
//  Created by  Linksware Inc. on 20/08/12.
//  Copyright © VINAS Co., Ltd. 2011 - 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "BannerAsyncimageview.h"
@interface LogInViewController: UIViewController
{
    IBOutlet BannerAsyncimageview *bannerview;
    IBOutlet UITextField *userName;
    IBOutlet UITextField *password;
    IBOutlet UIButton *loginButton;
    IBOutlet UIButton *rememberButton;
    IBOutlet UIButton *SugarSynButton;
    IBOutlet UIButton *vinasButton;
    IBOutlet UIButton *clearSettingButton;
    IBOutlet UIButton *googleDriveButton;

   // IBOutlet UIButton *loginButton;

    NSString *userName_str;
    NSString *password_str;
    
    NSMutableData *ResponseData1;
    NSMutableData *ResponseData2;
    NSMutableData *ResponseData3;
    
    NSURLConnection *Connection1;
    NSURLConnection *Connection2;
    NSURLConnection *Connection3;

    SecIdentityRef idRef;
    NSArray *idArray;
    NSURL *theURL;
    NSURL *newURL;
    
    IBOutlet UIActivityIndicatorView *activity;
    
    IBOutlet UIView *loginView;
    IBOutlet UIView *AboutView;
    IBOutlet UIView *mainview;
    IBOutlet UIView *selectionview;
    IBOutlet UIView *loginView_iphone;
    IBOutlet UITableView *tableview;
    IBOutlet UILabel *lblVersionInfo;
    IBOutlet UIWebView *webview;
    IBOutlet UILabel *lblbuildinfo;
    NSMutableArray *arrServerlist;
    
    IBOutlet UISegmentedControl *segment;
    IBOutlet UILabel *lblUserID;
    IBOutlet UILabel *lblType;
    UILabel *lblSubTitle;
    UIButton *btnback;
    
        NSTimer *adTimer;
}
- (IBAction)googleDriveAuthButtonClicked:(id)sender;

-(IBAction)sugersync_clicked:(id)sender;
-(IBAction)vinas_clicked:(id)sender;
-(IBAction)logout_clicked;
-(IBAction)login_Clicked:(id)sender;
-(void)getUserID;
-(void)getUserInfo;
-(IBAction)rememberMe_clicked:(id)sender;
-(IBAction)Clear_clicked:(id)sender;
-(IBAction)SegmentChange:(id)sender;
@end
