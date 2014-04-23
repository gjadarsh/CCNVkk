//
//  MoviePlayerController.h
//  CCNV
//
//  Created by  Linksware Inc. on 9/14/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "File.h"
#import <MessageUI/MessageUI.h>
@interface MoviePlayerController : UIViewController<UIActionSheetDelegate,MFMailComposeViewControllerDelegate,UITextFieldDelegate, NSURLConnectionDownloadDelegate>{
  
    MPMoviePlayerController *moviePlayer;
  //  NSMutableDictionary *dictFile;
    NSMutableData *ResponseData1;
    File *objFile;
    NSURLConnection *Connection1;
    NSString *fileUrl;
    
    IBOutlet UIScrollView *scrollview;
    IBOutlet UIBarButtonItem *btnPlay;
    IBOutlet UIView *MvView;
    IBOutlet UISlider *progress;
       NSTimer *timer;
    
    NSMutableData *ResponseData3;
    NSURLConnection *Connection3;
    
    BOOL isPlaying;
    BOOL isRepeat;
    BOOL isSendingMail;
    
    UIActionSheet *actionsSheet;
    
    UILabel *lblTitle;
    UITextField *txtTitle;
    
    long bytesReceived;
    long expectedBytes;
    float percentComplete;
    float progressCount;
}
@property (nonatomic,strong)NSString *fileUrl;
@property (nonatomic,strong) File *objFile;
@property (nonatomic,strong) NSString *strContent;
@property(nonatomic,strong)MPMoviePlayerController *moviePlayer;

-(IBAction)stopPlayingVideo:(id)sender;
-(void)cancel;
-(void)initPlayer;
//-(void)workspaceFileContent;
-(void)Play;
-(IBAction)PlayPause:(id)sender;
-(IBAction)progressValueChange:(id)sender;
-(void)ChngeSliderValue;
-(void)StartTimer;
-(NSString*)GetFileUrl;
-(IBAction)repeat:(id)sender;
-(IBAction)SaveToLib:(id)sender;
@end
