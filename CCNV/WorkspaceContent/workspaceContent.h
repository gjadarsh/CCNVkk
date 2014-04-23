//
//  workspaceContent.h
//  SugarSynDemo
//
//  Created by  Linksware Inc. on 22/08/12.
//  Copyright © VINAS Co., Ltd. 2011 - 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "WorkSpaceCell.h"
#import "BannerAsyncimageview.h"
#import "File.h"
@interface workspaceContent : UIViewController<UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate>{//MWPhotoBrowserDelegate
    
    IBOutlet UITableView *tableview;
    NSMutableDictionary *dict;
    
    NSMutableData *ResponseData1;
    NSMutableData *ResponseData2;
    NSMutableData *ResponseDataDelete;
    NSMutableData *ResponseDataThumb;
    NSURLConnection *Connection1;
    NSURLConnection *Connection2;
    NSURLConnection *ConnectionDelete;
    NSURLConnection *ConnectionThumb;
    NSArray *photos;
    NSMutableArray *arrContentList;
    NSMutableArray *arrThumbdata;
    File *currentThumbFolder;
    IBOutlet WorkSpaceCell *customCell;
    //IBOutlet CVCell *cvcell;
    UIActionSheet *action;
    IBOutlet UIScrollView *scroll;
    IBOutlet UIView *thumbnailView;
    IBOutlet UISegmentedControl *segment;
   // ImageEditViewController *imgEditObj;
    int KMaxViewInRow;
    IBOutlet BannerAsyncimageview *bannerview;
    NSTimer *timer;
    NSTimer *adTimer;
    
}
@property (nonatomic,strong) NSMutableArray *arrContentList;
@property (nonatomic,strong)NSMutableDictionary *dict;
@property(nonatomic,strong)NSMutableArray *photos;

-(void)RealoadTableView;
-(void)workSpaceContent;
-(void)workspaceFileContent;
//- (void) loadInfoInBackground:(NSArray *)urlAndTagReference ;
//- (void)assignInfoTotableView:(NSArray *)imgAndTagReference;
//-(void)Short:(int)type;
-(IBAction)SegmentChange:(id)sender;
-(void)openActionSheet;
-(IBAction)Back_Clicked;
-(IBAction)ActionButtonClicked:(id)sender;
-(void)CalenderViewClicked;
-(void)LoadAllinfo;
-(IBAction)HomeClicked;
-(IBAction)SettingsClicked;
-(void)loadFilesOfThumbFolder:(File *)fileobj;
-(void)LoadThumbForImage:(File *)file;
-(void)LoadThumbForImages:(NSMutableDictionary *)files;
@end
