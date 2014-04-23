//
//  ServerSelectionViewController.h
//  CCNV
//
//  Created by  Linksware Inc. on 9/11/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerSelectionViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *tableview;
    NSMutableArray *arrServerlist;
    
    NSMutableData *ResponseData1;
    NSMutableData *ResponseData2;
    NSMutableData *ResponseData3;
    
    NSURLConnection *Connection1;
    NSURLConnection *Connection2;
    NSURLConnection *Connection3;
    
    SecIdentityRef idRef;
    NSArray *idArray;
    
    IBOutlet UIButton *loginButton;
    
    IBOutlet UILabel *lblUserID;
    IBOutlet UILabel *lblType;
    
    IBOutlet BannerAsyncimageview *bannerview;
    
    NSTimer *adTimer;
}
@property(nonatomic,strong)NSMutableArray *arrServerlist;
@property(nonatomic,strong)IBOutlet UITableView *tableview;
-(IBAction)login_Clicked:(id)sender;
-(IBAction)logout_clicked;
@end
