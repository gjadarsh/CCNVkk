//
//  PDFViewerController.h
//  CCNV
//
//  Created by  Linksware Inc. on 9/19/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@interface PDFViewerController : UIViewController<UIWebViewDelegate,UITextFieldDelegate,MFMailComposeViewControllerDelegate>
{
    IBOutlet UIWebView *webview;
    NSString *fileUrl;
    File *objfile;
    
    NSMutableData *ResponseData1;
    NSMutableData *ResponseData2;
    NSMutableData *ResponseData3;
    
    NSURLConnection *Connection1;
    NSURLConnection *Connection2;
    NSURLConnection *Connection3;

    UILabel *lblTitle;
    UITextField *txtTitle;

    long bytesReceived;
    long expectedBytes;
    float percentComplete;
    float progressCount;
}
@property(nonatomic,strong) NSString *fileUrl;
@property(nonatomic,strong) File  *objfile;
-(void)UpdateFile;
-(void)getFileData;
-(NSString*)GetFileUrl;
@end
