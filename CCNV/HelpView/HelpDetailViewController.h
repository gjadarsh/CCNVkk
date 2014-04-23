//
//  HelpDetailViewController.h
//  CCNV
//
//  Created by  Linksware Inc. on 06/02/13.
//
//

#import <UIKit/UIKit.h>

@interface HelpDetailViewController : UIViewController<UIWebViewDelegate>
{
     IBOutlet UIImageView *screenimag;
        IBOutlet UIWebView *webview;
    NSString *strtitle;
    
}
@property (nonatomic,strong)  NSString *strtitle;
@end
