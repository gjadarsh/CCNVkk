//
//  HelpDetailViewController.m
//  CCNV
//
//  Created by  Linksware Inc. on 06/02/13.
//
//

#import "HelpDetailViewController.h"

@interface HelpDetailViewController ()

@end

@implementation HelpDetailViewController
@synthesize strtitle;

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
    
    self.navigationItem.title=strtitle;
    //@"SugarSyncとは ",@"接続トップ画面",@"表示の切り替え",@"画像の編集"
    
    ///set document for help option
    if([strtitle isEqualToString:@"SugarSyncとは "]){
        [self LoadHelpDocuments :0];
        
    }else if ([strtitle isEqualToString:@"接続トップ画面"]){
        [self LoadHelpDocuments :1];
    }
    else if ([strtitle isEqualToString:@"表示の切り替え"]){
        [self LoadHelpDocuments :2];
    }
    else if ([strtitle isEqualToString:@"画像の編集"]){
        [self LoadHelpDocuments :3];
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * this method loads PDF file for help option.
 * used in iPhone/Ipod only
 */
-(void)LoadHelpDocuments :(int )index{
    
//   NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%02i-1",index+1] ofType:@"pdf"];
//    
//    NSData *htmlData = [NSData dataWithContentsOfFile:path];
//
//    [webview loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];

    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%02i-1",index+1] ofType:@"pdf"];
    NSLog(@"filePath%@",path);
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [webview loadRequest:request];
    
   // [webview setScalesPageToFit:YES];
    
    
    [webview sizeToFit];
    
}

#pragma mark - uiwebviewdelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    [ApplicationDelegate.HUD setHidden:FALSE];
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [ApplicationDelegate.HUD setHidden:TRUE];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [ApplicationDelegate.HUD setHidden:TRUE];
}

@end