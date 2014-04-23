//
//  CCNVLoginViewConroller.h
//  CCNV
//
//  Created by  Linksware Inc. on 9/21/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VIdbConfig.h"
#import "TPKeyboardAvoidingScrollView.h"
@interface CCNVLoginViewConroller : UIViewController<UITextFieldDelegate>{
    
    IBOutlet UITextField *txtEmail,*txtPass;
    IBOutlet UIButton *btnLogin,*btnCheckmark;
    IBOutlet UIButton *buttonOne;
    IBOutlet UIButton *buttonTwo;

    NSURLConnection *Connection;
    NSMutableData *ResponseData;
}
@property (unsafe_unretained, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
-(IBAction)login;
-(IBAction)btnCheckmark_clicked:(id)sender;
-(IBAction)btnSignUpClicked:(id)sender;
-(IBAction)ForgotPass_Clicked:(id)sender;
@end
