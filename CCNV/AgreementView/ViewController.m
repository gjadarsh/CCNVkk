//
//  ViewController.m
//  CCNV
//
//  Created by Harshal on 10/26/12.
//
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

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
    [super viewDidLoad];
    /// show activity indicator /////////////////////////////////////////
    [spinner startAnimating];
    
    /// get file content ///////////////////////////////////////////////
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CCNV-mobile_ソフトウェア使用許諾契約書_issue08" ofType:@"doc"];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    
    /// load file in webview /////////////////////////////////////////
    [webView loadRequest:request];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
* this method called on click of accept button 
* it will change value for "AgreementAccepted" key of Userfault
* and dismiss the modelviewcontroller.
*/
- (IBAction)accept:(id)sender {
    // dismiss the view when user accepts agreement //
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"AgreementAccepted"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 * this method called on click of cancel button
 * it pops alert to make sure cancel event.
 * and close the application on click on ok button of alert.
 */
- (IBAction)cancel:(id)sender
{
    // pop an alert if user cancels the agreement //
    [[[UIAlertView alloc] initWithTitle:@"CCNV" message:@"Cancel will close the application.\nAre you sure?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No", nil] show];
}

#pragma mark UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [spinner startAnimating];
    acceptBtn.enabled = FALSE;
    cancelBtn.enabled = FALSE;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [spinner stopAnimating];
    acceptBtn.enabled = TRUE;
    cancelBtn.enabled = TRUE;    
}
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        // close the application //
        exit(0);
    }
}

#pragma mark - UIInterfaceOrientation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft||toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        
       // lblSubTitle.frame=CGRectMake(300, 0, 724, lblSubTitle.frame.size.height);
        
    }
    else{
       // lblSubTitle.frame=CGRectMake(300, 0, 468, lblSubTitle.frame.size.height);
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight){
   //     lblSubTitle.frame=CGRectMake(300, 0, 724, lblSubTitle.frame.size.height);
    }
    else{
    //    lblSubTitle.frame=CGRectMake(300, 0, 468, lblSubTitle.frame.size.height);
    }
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    // return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end