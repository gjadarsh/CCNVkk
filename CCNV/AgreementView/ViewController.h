//
//  ViewController.h
//  CCNV
//
//  Created by Harshal on 10/26/12.
//
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    IBOutlet UIBarButtonItem *acceptBtn;
    IBOutlet UIBarButtonItem *cancelBtn;
    IBOutlet UIWebView *webView;
    IBOutlet UIActivityIndicatorView *spinner;
}

- (IBAction)accept:(id)sender;
- (IBAction)cancel:(id)sender;

@end
