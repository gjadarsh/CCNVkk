//
//  TextEditViewController.h
//  CCNV
//
//  Created by  Linksware Inc. on 10/08/2012.
//
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "File.h"
#import <MessageUI/MessageUI.h>
@class TPKeyboardAvoidingScrollView;

@interface TextEditViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate,MFMailComposeViewControllerDelegate>
{
    IBOutlet UITextView *textview;
    NSMutableData *ResponseData1;
    NSMutableData *ResponseData2;
    NSMutableData *ResponseData3;
    
    NSURLConnection *Connection1;
    NSURLConnection *Connection2;
    NSURLConnection *Connection3;
    
    UILabel *lblTitle;
    UITextField *txtTitle;
}

@property(nonatomic,strong)File *fileDict;
-(void)UpdateFile;
-(void)getFileData;
-(NSString*)GetFileUrl;
-(void)EditText;
@end
