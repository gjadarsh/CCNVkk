//
//  SelectWorkspace.h
//  SugarSynDemo
//
//  Created by  Linksware Inc. on 21/08/12.
//  Copyright © VINAS Co., Ltd. 2011 - 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "XMLParser.h"
#import "BannerAsyncimageview.h"
@interface SelectWorkspace : UIViewController<UITableViewDelegate,UITableViewDataSource>{

    IBOutlet UITableView *tableview;
    NSMutableData *ResponseData;
    NSMutableArray *album_arr;
    
    NSMutableDictionary *dict;
    
    NSMutableData *ResponseData1;
    NSMutableData *ResponseData2;
    
    NSURLConnection *Connection1;
    NSURLConnection *Connection2;
   
    NSString *selectedFolderName;
    
    IBOutlet BannerAsyncimageview *bannerview;
    NSTimer *adTimer;
}
@property(nonatomic,strong) NSString *selectedFolderName;
-(void)workSpaceContent;
-(void)workspaceFileContent;
-(void)retrieveContent;
-(IBAction)Settings_clicked;

@end
