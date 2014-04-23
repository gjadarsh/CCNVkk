//
//  HistoryViewController.h
//  CCNV
//
//  Created by  Linksware Inc. on 1/18/2013.
//
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *tblview;
    NSMutableArray *arrHistory;
}
 
@end
