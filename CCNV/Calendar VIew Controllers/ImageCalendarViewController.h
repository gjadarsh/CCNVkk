//
//  ImageCalendarViewController.h
//  CCNV
//
//  Created by  Linksware Inc. on 12/26/2012.
//
//

#import <UIKit/UIKit.h>
#import "WorkSpaceCell.h"
#import "KalViewController.h"
@class workspaceContent;
@interface ImageCalendarViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *tableview;
  // NSMutableArray *arrImageListForCal;
     NSMutableArray *arrImageListForListView;
    IBOutlet WorkSpaceCell *customCell;
    KalViewController* kal;
    id dataSource;
    UINavigationController *navController;
}
//@property(nonatomic,retain) NSMutableArray *arrImageListForCal;
@property(nonatomic,strong) NSMutableArray *arrImageListForListView;
@property(nonatomic,strong) NSArray *photos;
//-(void)LoadDeletaolview;
@end
