//
//  Global.h
//  SugarSynDemo
//
//  Created by  Linksware Inc. on 20/08/12.
//  Copyright © VINAS Co., Ltd. 2011 - 2013. All rights reserved.
//

#ifndef SugarSynDemo_Global_h
#define SugarSynDemo_Global_h

#define APP ((AppDelegate*)[UIApplication sharedApplication].delegate)
#define SHOW_ALERT(title,msg,del,cancel,other,...) { \
UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:del cancelButtonTitle:cancel otherButtonTitles:other, ##__VA_ARGS__]; \
[alert show]; \
}

#define BaseURL @"https://api.sugarsync.com/"
#define USERDEFAULTS [NSUserDefaults standardUserDefaults]
#define KCCNVurl @"http://support.vinas.com/rms/index.php?"
#define KBannerUrl @"http://support.vinas.com/rms/index.php?"
#import "BannerImageView.h"
#import "AppDelegate.h"
#import "LogInViewController.h"
#import "BannerAsyncimageview.h"
#import "SelectWorkspace.h"
#import "XMLParser.h"
#import "workspaceContent.h"
#import "imageXML.h"
//#import "AlbumContent.h"
#import "File.h"
//#import "ImageEditViewController.h"
File *currentFile;

#define Authtoken @"Auth token expired. Please re-obtain token."

//NSMutableDictionary *currentDict;
#endif