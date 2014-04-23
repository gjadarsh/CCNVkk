//
//  PlayerViewController.h
//  CCNV
//
//  Created by  Linksware Inc. on 9/12/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "File.h"
#import <MessageUI/MessageUI.h>
@interface PlayerViewController : UIViewController<AVAudioPlayerDelegate,MFMailComposeViewControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate>
{
    NSString *fileUrl;
    File *objFile;
    IBOutlet UIImageView *ImgAlbumArt;
    IBOutlet UIButton *btnNext,*btnPrivios;
    IBOutlet UISlider *progress;
    IBOutlet UIBarButtonItem *btnPlay;
    NSMutableData *ResponseData1;
    NSMutableData *ResponseData2;
    NSMutableData *ResponseData3;
    
    NSURLConnection *Connection1;
    NSURLConnection *Connection2;
    NSURLConnection *Connection3;

    NSString *strContent;
    
    NSTimer *timer;
    BOOL isRepeat;
    
    UIActionSheet *actionsSheet;
    
    UILabel *lblTitle;
    UITextField *txtTitle;
    
    long bytesReceived;
    long expectedBytes;
    float percentComplete;
    float progressCount;
}
@property(nonatomic)BOOL isRepeat;
@property (nonatomic,strong) File *objFile;;
@property (nonatomic,strong) NSString *strContent;
@property (nonatomic,strong) IBOutlet UIImageView *ImgAlbumArt;
@property (nonatomic,strong) NSString *fileUrl;
@property (nonatomic,strong) IBOutlet UISlider *progress;
-(IBAction)Play:(id)sender;
//-(IBAction)progressValueChange:(id)sender;
-(void)initPlayer;
//-(void)workspaceFileContent;
-(void)ChngeSliderValue;
-(void)Back;
-(NSString*)GetFileUrl;
//-(void)setAlbumArtwork;
-(IBAction)repeat:(id)sender;
@end
