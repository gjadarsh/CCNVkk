//
//  CCNVLoginViewConroller.m
//  CCNV
//
//  Created by  Linksware Inc. on 9/21/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import "CCNVLoginViewConroller.h"
#import "AppDelegate.h"
#import "Global.h"
#import "ServerSelectionViewController.h"
#import "ViewController.h"
#import "NSData+Base64.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "Reachability.h"
#import <QuartzCore/QuartzCore.h>
@implementation CCNVLoginViewConroller

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
    self.title = @"CCNV";

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
{
    [self buttonLayerSetForIos7:btnLogin];
    [self buttonLayerSetForIos7:buttonTwo];

    }
       [super viewDidLoad];
    [self.scrollView contentSizeToFit];
    [self.scrollView setContentSize:CGSizeMake(320,480)];

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

    for (id titleView in [self.navigationController.navigationBar subviews]) {
        if ([titleView isKindOfClass:[UILabel class]]) {
            [titleView removeFromSuperview];
        }
    }
    
    [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.4];
    
    isRememberMe=[[NSUserDefaults standardUserDefaults] boolForKey:@"RememberForCCNV"];
    
    //set login values for username and password 
    if (isRememberMe) {
        
        if([[NSUserDefaults standardUserDefaults] valueForKey:@"usernameCCNV"]) {
            
            txtEmail.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"usernameCCNV"];
            txtPass.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"passwordCCNV"];
            btnCheckmark.selected = TRUE;
        }
    }else{
        
        txtEmail.text = @"";
        txtPass.text = @"";
    }

    [super viewWillAppear:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - action events
/**
 * this method opens a forgot password link in safari.
 */
-(IBAction)ForgotPass_Clicked:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://support.vinas.com/ccnv/useractions/forgotpwd"]];

}

/**
 * this method opens a Signup in Vinas page in safari.
 */
-(IBAction)btnSignUpClicked:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://support.vinas.com/ccnv/member_v/aggree_v.html"]];
}
/**
 * this method will call login webservice in connection .
 * it pops alert if username or password value is blank , and update User object in (connectionDidFinishLoading) on successful login  method
 */
-(IBAction)login
{
    [txtEmail resignFirstResponder];
    [txtPass resignFirstResponder];
    
    if ([txtEmail.text isEqualToString:@""] || [txtPass.text isEqualToString:@""]) {
        
        //pop ups alert if any value is blank
        
        SHOW_ALERT(@"CCNV", @"Username and password can not be blank", nil, @"OK", nil, nil);
        return;
    }
    
    [ApplicationDelegate.HUD setHidden:FALSE];
    
    //do loging request

//    if(ApplicationDelegate.connectionRequired){
    if(![self checkReachable]){

        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
        [ApplicationDelegate.HUD setHidden:TRUE];
    }else{

    NSString *strEmail = [[txtEmail.text dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
    NSLog(@"Email  : %@",strEmail);
    NSString * strpass = txtPass.text;
    
    NSString *xmlString = [NSString stringWithFormat:
                       @"<ved version=\"1.0.0.0\"><request>user-authorise</request><fileids><fileids id=\"user\"><property name=\"userid\">%@</property><property name=\"password\">%@</property><property name=\"device_type\">mobile</property></fileids></fileids></ved>",strEmail,strpass];

    NSData *thumbsupData = [xmlString dataUsingEncoding: NSASCIIStringEncoding];

    NSString *urlString = [NSString stringWithFormat:@"%@app-authorization",KCCNVurl];
    NSURL* theURL = [NSURL URLWithString:urlString];

    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];

    [theRequest setHTTPMethod:@"POST"];
    [theRequest addValue:@"application/xml; charset=UTF-8" forHTTPHeaderField:@"Content-type"];
    [theRequest setHTTPBody:thumbsupData];

        Connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if(Connection) {
            ResponseData = [[NSMutableData alloc] init];
        }
   
    }
}

- (void)viewDidAppear:(BOOL)animated {
    // shows agreement view if agreemant is not accepted
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"AgreementAccepted"]) {
        ViewController *controller = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
            // open agreement view as FormSheet //
            [controller setModalPresentationStyle:UIModalPresentationFormSheet];
        }
      
        [self.navigationController presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - httpsconnection methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
//    [[[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    if (connection == Connection)
//        ResponseData = nil;
    [ApplicationDelegate.HUD setHidden:TRUE];


    if(isIpad){
        LogInViewController *serverView;
        serverView=[[LogInViewController alloc] initWithNibName:@"LogInViewController_ipad" bundle:nil];
        [self.navigationController pushViewController:serverView animated:YES];
        
    }else{
        ServerSelectionViewController *serverView;
        serverView=[[ServerSelectionViewController alloc] initWithNibName:@"ServerSelectionViewController" bundle:nil];
        [self.navigationController pushViewController:serverView animated:YES];
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == Connection){
        [ResponseData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (connection == Connection)
        [ResponseData appendData:data];
}

/**
 * NSURLConnection delegate method  .
 * it pops alert if username or password value is not correct , and update User object  on successful login 
 * loads LogInViewController on successful login.
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    if (connection == Connection){ //login responce
        if(ResponseData){
            NSString *responsestring= [[NSString alloc] initWithData:ResponseData encoding:NSUTF8StringEncoding];
            NSLog(@"responsestring = %@",responsestring);
            
            NSString *start = @"<code>";
            NSRange starting = [responsestring rangeOfString:start];
            if(starting.location != NSNotFound){
                
                NSString *end = @"</code>";
                NSRange ending = [responsestring rangeOfString:end];
                NSString *str = [responsestring substringWithRange:NSMakeRange(starting.location + starting.length, ending.location - (starting.location + starting.length))];
                
                
                NSString *product ;
                [ApplicationDelegate.HUD setHidden:TRUE];
                
                if([str isEqualToString:@"OK"]){
                    
                    NSString *start1 = @"<product-value>";
                    NSRange starting1 = [responsestring rangeOfString:start1];
                    if(starting1.location != NSNotFound){
                        NSString *end1 = @"</product-value>";
                        NSRange ending1 = [responsestring rangeOfString:end1];
                        product = [responsestring substringWithRange:NSMakeRange(starting1.location + starting1.length, ending1.location - (starting1.location + starting1.length))];                                                
                    }
                    
                    NSLog(@"responsestring = %@",responsestring);
                    ApplicationDelegate.currentUser.strUserName=txtEmail.text;
                    ApplicationDelegate.currentUser.strProductValue=product;
                    CFBridgingRetain(ApplicationDelegate.currentUser);
                    
                    NSString *strHistory=@"Successfully Login in CCNV";
                    [ApplicationDelegate UpdateDatabase:strHistory]; //update history table
                    
                    ///save loging value in NSUserDefaults
                    [[NSUserDefaults standardUserDefaults] setBool:btnCheckmark.selected forKey:@"RememberForCCNV"];
                    if (btnCheckmark.selected){
                        [USERDEFAULTS setValue:txtEmail.text forKey:@"usernameCCNV"];
                        [USERDEFAULTS setValue:txtPass.text forKey:@"passwordCCNV"];
                        [USERDEFAULTS  synchronize];
                        
                    }
                    else{
                        [USERDEFAULTS setValue:@"" forKey:@"usernameCCNV"];
                        [USERDEFAULTS setValue:@"" forKey:@"passwordCCNV"];
                        [USERDEFAULTS  synchronize];
                    }
                    
                    if(isIpad){
                        LogInViewController *serverView;
                        serverView=[[LogInViewController alloc] initWithNibName:@"LogInViewController_ipad" bundle:nil];
                        [self.navigationController pushViewController:serverView animated:YES];
                        
                    }else{
                        ServerSelectionViewController *serverView;
                        serverView=[[ServerSelectionViewController alloc] initWithNibName:@"ServerSelectionViewController" bundle:nil];
                        [self.navigationController pushViewController:serverView animated:YES];
                    }
                }
                else{
                    
                    //pop ups alert if username or password is not correct
                    SHOW_ALERT(@"CCNV", @"User name or password is not correct", nil, @"OK", nil, nil);
                }
                
            }
        }
    }
}

/**
 * change value of userdefault keys for login
 */
-(IBAction)btnCheckmark_clicked:(id)sender
{
    UIButton *btn = (UIButton*)(id)sender;
    btn.selected = !btn.selected;
    
    // save remember flag value in NSUserDefault 
    [[NSUserDefaults standardUserDefaults] setBool:btn.selected forKey:@"RememberForCCNV"];
    if (btn.selected){
        [USERDEFAULTS setValue:txtEmail.text forKey:@"usernameCCNV"];
        [USERDEFAULTS setValue:txtPass.text forKey:@"passwordCCNV"];
        [USERDEFAULTS  synchronize];
        
    }
    else{
        [USERDEFAULTS setValue:@"" forKey:@"usernameCCNV"];
        [USERDEFAULTS setValue:@"" forKey:@"passwordCCNV"];
        [USERDEFAULTS  synchronize];
    }

}

#pragma mark - UITextFieldDelegate {
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return TRUE;
}

#pragma mark - UIInterfaceOrientation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
   // return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(BOOL)checkReachable
{
    // Allocate a reachability object
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        //my web-dependent code
        return YES;
    }
    else {
        //there-is-no-connection warning
        return NO;

    }
}
@end