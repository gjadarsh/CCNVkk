//
//  HelpViewController.h
//  CCNV
//
//  Created by  Linksware Inc. on 06/02/13.
//
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>{
    IBOutlet UITableView *tblview;
    IBOutlet UIView *mainview;
    IBOutlet UIView *detailview;
    IBOutlet UIImageView *screenimag;
    IBOutlet UIWebView *webview;
    
    UILabel *lblSubTitle;
    NSMutableArray *arrServerlist;
}


@end
