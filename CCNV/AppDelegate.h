//
//  AppDelegate.h
//  SugarSynDemo
//
//  Created by  Linksware Inc. on 20/08/12.
//  Copyright © VINAS Co., Ltd. 2011 - 2013. All rights reserved.

//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"

#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)
@class  CCNVLoginViewConroller,User;
@class Reachability;
@interface AppDelegate : UIResponder <UIApplicationDelegate,AVAudioPlayerDelegate>{
    
    UINavigationController *navController;
    NSString *applicationID;
    NSString *accessKeyId;
    NSString *privateAccessKey;
    NSString *refreshToken;
    NSString *userID;
    NSString *accessToken;
    NSMutableArray *albumContent;
    NSMutableString *content_str;
    NSMutableArray *arrSugerSyncFolder;
    NSMutableArray *imageXML;
    NSMutableDictionary *imageRef;
    MBProgressHUD *HUD;
    AVAudioPlayer *player;
    
    User *currentUser;
     int selectedindex;
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
    
    BOOL connectionRequired;
    BOOL isNotificationShow;
    BOOL isWifiON;
    BOOL is3Gor4G;
    UIButton *closeBtn;
    
    NSString *monthName;
    
    NSURLConnection *Connection2;
    NSMutableData *ResponseData2;
}

@property (nonatomic, strong) NSString *monthName;
@property (nonatomic)BOOL TokenExpired;
@property (nonatomic)BOOL TokenRequestStarted;
@property(nonatomic)BOOL connectionRequired;
@property(nonatomic,readwrite) int selectedindex;
@property(nonatomic,readwrite) int ThumbCount;
@property(nonatomic,strong)User *currentUser;
@property(nonatomic,strong)NSMutableArray *arrSugerSyncFolder;
@property (nonatomic,strong)AVAudioPlayer *player;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (strong, nonatomic)CCNVLoginViewConroller *viewController;
@property (strong,nonatomic) NSString *applicationID;
@property (strong,nonatomic) NSString *accessKeyId;
@property (strong,nonatomic) NSString *privateAccessKey;
@property (strong,nonatomic) NSString *refreshToken;
@property (strong,nonatomic) NSString *userID;
@property (strong,nonatomic) NSString *accessToken;
@property (strong,nonatomic) NSMutableArray *albumContent;
@property (strong,nonatomic) NSMutableString *content_str;
@property (strong,nonatomic) NSMutableArray *imageXML;
//@property (nonatomic, readwrite) int firstTemp;

-(void)UpdateDatabase :(NSString *)history;
-(NSMutableArray *)loadHistory;
- (void)hideCloseButton;
- (void)showCloseButton;
- (BOOL)isInternetReachable;
+ (NSString*)weekdayForDate:(NSString*)dateStr;
-(void)RefreshAccessToken;
@end
