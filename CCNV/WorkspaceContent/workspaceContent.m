
//  workspaceContent.m
//  SugarSynDemo
//
//  Created by  Linksware Inc. on 22/08/12.
//  Copyright © VINAS Co., Ltd. 2011 - 2013. All rights reserved.
//

#import "MWPhotoBrowser.h"

#import "workspaceContent.h"
#import "PlayerViewController.h"
#import "MoviePlayerController.h"
#import "TextEditViewController.h"
//#import "CVCell.h"
#import "XMLParserSharedFolder.h"
#import "ImageCalendarViewController.h"
#import "AsyncImageview.h"
#import "PDFViewerController.h"
#import "HistoryViewController.h"
#define KHeight 60
#define KWeidth 60
#define KWeidth_ipad 137
#define KHeight_ipad 137

#define btnProductTag 1000
#define lblNameTag 2000
#define ImgProductTag 3000
//#define btnProductTag_ipad 2000
//#define lblNameTag_ipad 4000
//#define ImgProductTag_ipad 6000

#define loadingTag 4000

@interface workspaceContent () <MWPhotoBrowserDelegate>

@end
@implementation workspaceContent
@synthesize dict,arrContentList;

@synthesize photos = _photos;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma  mark - remove photoviewer
- (void)done:(id)sender {
    if(isImageFromCalView){
        isImageFromCalView=FALSE;
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    infoCount=0;
    [APP.imageXML removeAllObjects];
    
    //Customise UISegmentController
    [self customSegmentedControll];
    
    //if IOS7 tableview Change
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
 
    self.navigationItem.title=currentFile.strDisplayName;
    
    //set flags
    thumbnailView.hidden =TRUE;
    tableview.hidden=FALSE;
    
    //init array
    arrContentList=[[NSMutableArray alloc] init];
    arrThumbdata=[[NSMutableArray alloc] init];
         bannerview.hidden=TRUE;
    
    //Hide bannerview if its not webArchive
    if([self.title isEqualToString:@"webArchive"]){
        bannerview.hidden=FALSE;
    }
    else{
        tableview.frame=CGRectMake(tableview.frame.origin.x, tableview.frame.origin.y, tableview.frame.size.width, tableview.frame.size.height +44);
    }
    
    
    //load selected folder data
    [self workSpaceContent];
    
    ////set Logout button on top right side .
    
    UIBarButtonItem *logout = [[UIBarButtonItem alloc]initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout_clicked)];
    self.navigationItem.rightBarButtonItem = logout;
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(RealoadTableView) name:@"RealoadTableView" object:nil];
 //  [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(done:) name:@"DismissPhotoViewer" object:nil];
}
#pragma mark-Customise UISegmented Controll
-(void)customSegmentedControll
{
    UIFont *Boldfont = [UIFont systemFontOfSize:14];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:Boldfont forKey:UITextAttributeFont];
    [attributes setValue:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    
    [segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [segment setBackgroundColor:[UIColor colorWithRed:5/255.f green:96/255.f blue:140/255.f alpha:1]];
}
-(void)RealoadTableView{
    [tableview reloadData];
    tableview.hidden?[self performSelector:@selector(CreateView) withObject:self afterDelay:0.2]:Nil;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationItem.hidesBackButton=TRUE;
    [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.4];
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(workSpaceContent) name:@"TokenRefreshed" object:nil];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     if([self.title isEqualToString:@"webArchive"]){
         [self loadBanner];
         adTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(loadBanner) userInfo:nil repeats:YES];
     }
}

- (void)loadBanner {
    [bannerview performSelectorInBackground:@selector(loadImageFromURL) withObject:nil];
}
- (void)viewDidDisappear:(BOOL)animated{
    [adTimer invalidate];
    adTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)LoadInfoInForAlldata{
    
           for (File *obj in arrContentList) {
            NSArray *arr=[obj.strMediaType componentsSeparatedByString:@"/"];
            NSString *strExtention=[arr objectAtIndex:0];
            if(![strExtention isEqualToString:@"folder"]&![strExtention isEqualToString:@"syncFolder"]){
                // Create a new NSOperation object using the NSInvocationOperation subclass.
                [ApplicationDelegate.HUD setHidden:NO];

                //[self.view setUserInteractionEnabled:NO];
//                  [self performSelector:@selector(startDownload:) withObject:obj];
                
                [self performSelectorOnMainThread:@selector(startDownload:) withObject:obj waitUntilDone:YES];
//                [self performSelectorInBackground:@selector(startDownload:) withObject:obj];
//                NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
//                                                                                        selector:@selector(startDownload:)
//                                                                                          object:obj];
                //                // Add the operation to the queue and let it to be executed.
//                [operationQueue addOperation:operation];
            }
        }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"RealoadTableView" object:nil];

    [ApplicationDelegate.HUD setHidden:YES];
   // [self.view setUserInteractionEnabled:YES];
}
-(void)startDownload:(File *)file{
    NSArray *arr=[file.strMediaType componentsSeparatedByString:@"/"];
    NSString *strExtention=[arr objectAtIndex:0];
    NSLog(@"%@", strExtention);
   // if(![strExtention isEqualToString:@"folder"]&![strExtention isEqualToString:@"syncFolder"]){
        
        NSString *urlString =[NSString stringWithFormat:@"%@",file.ref];
        NSURL *theURL = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
        //NSLog(@"Access token = %@",APP.accessToken);
        [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
        [theRequest setHTTPMethod:@"GET"];
        
        if(ApplicationDelegate.connectionRequired){
            SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
            [ApplicationDelegate.HUD setHidden:TRUE];
        }else{
            NSError *error;
            NSHTTPURLResponse *response = nil;
            NSData *data=[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
            
//            [NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *responce, NSData *data, NSError *error)
//                             {
                                 if(data!=nil){
                                     
                                     NSString *responsestring= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                     //        NSLog(@"responsestring = %@",responsestring);
                                     
                                     NSString *start = @"<size>";
                                     NSRange starting = [responsestring rangeOfString:start];
                                     if(starting.location != NSNotFound){
                                         /////////////size formatting///////////////////////////////////////
                                         NSString *end = @"</size>";
                                         NSRange ending = [responsestring rangeOfString:end];
                                         NSString *str = [responsestring substringWithRange:NSMakeRange(starting.location + starting.length, ending.location - (starting.location + starting.length))];
                                         file.size=[str intValue];
                                         NSLog(@"XXXXX%@.....",str);
                                         file.strSize=[self ChangeStringSize:str];//[self size:str];//adarsh
                                         
                                         
                                         ////date formatting/////////////////////////////////////////////////
                                         
                                         NSString *start1 = @"<timeCreated>";
                                         NSRange starting1 = [responsestring rangeOfString:start1];
                                         if(starting1.location != NSNotFound){
                                             NSString *end1 = @"</timeCreated>";
                                             NSRange ending1 = [responsestring rangeOfString:end1];
                                             NSString *str1 = [responsestring substringWithRange:NSMakeRange(starting1.location + starting1.length, ending1.location - (starting1.location + starting1.length))];
                                             
                                             NSString *date1=[str1 substringToIndex:10];
                                             //                NSLog(@"%@",date1);
                                             NSString *time=[str1 substringWithRange:NSMakeRange(11, 8)];
                                             //                 NSLog(@"%@",time);
                                             if([file.strDateTime isEqualToString:@""]){
                                                 file.strDateTime=[NSString stringWithFormat:@"%@ %@",date1,time];}
                                             isGridViewActive = TRUE;
                                             
                                             
                                         }
                                         
                                         start1 = @"<lastModified>";
                                         starting1 = [responsestring rangeOfString:start1];
                                         if(starting1.location != NSNotFound){
                                             NSString *end1 = @"</lastModified>";
                                             NSRange ending1 = [responsestring rangeOfString:end1];
                                             NSString *str1 = [responsestring substringWithRange:NSMakeRange(starting1.location + starting1.length, ending1.location - (starting1.location + starting1.length))];
                                             str1 = [str1 stringByReplacingOccurrencesOfString:@":" withString:@""];
                                             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                             [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HHmmss.SSSZZZZ"];
                                             [dateFormatter setLocale:[NSLocale currentLocale]];
                                             NSDate *date = [dateFormatter dateFromString:str1];
                                             
                                             [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                                             NSString *date1=[dateFormatter stringFromDate:date];
                                             //  NSLog(@"%@",date1);
                                             [dateFormatter setDateFormat:@"HH:mm:ss"];
                                             NSString *time=[dateFormatter stringFromDate:date];
                                             //  NSLog(@"%@",time);
                                             
                                             //                NSString *date1=[str1 substringToIndex:10];
                                             //                NSLog(@"%@",date1);
                                             //                NSString *time=[str1 substringWithRange:NSMakeRange(11, 8)];
                                             //                NSLog(@"%@",time);
                                             file.strLastModified=[NSString stringWithFormat:@"%@ %@",date1,time];
                                             // [tableview reloadData];
                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"RealoadTableView" object:nil];
                                             // lbldateTime.text=[NSString stringWithFormat:@"Date: %@" ,file.strLastModified];
                                         }
                                         
                                         file.isInfoLoaded = TRUE;
                                         CFBridgingRetain(file);
                                     }
                                 }

                             }
//                             ];
//            
//        }
//  }
}

-(NSString *)size:(NSString *)size
{
    
    //size calculation
    NSString *returnstring;
    int x=[size intValue];
    float kb,mb,gb;
    if(x>1000)
    {
        kb=x/1000;
        returnstring=[NSString stringWithFormat:@"%0.2f KB",kb];
        
        if(kb>1000)
        {
            mb=kb/1000;
            returnstring=[NSString stringWithFormat:@"%0.2f MB",mb];
            
            if(mb >1000){
                gb=mb/1000;
                returnstring=[NSString stringWithFormat:@"%0.2f GB",gb];
            }

        }
    }
       return returnstring;
}
//adarsh
- (id)ChangeStringSize:(id)value
{
    
    double convertedValue = [value doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (convertedValue >= 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

-(void)LoadAllinfo{
    //load  file info in baground
    NSOperationQueue *operationQueue = [NSOperationQueue new];

    for (File *obj in arrThumbdata) {
        
             
             // Create a new NSOperation object using the NSInvocationOperation subclass.
    
       NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                selector:@selector(LoadThumbForImage:)
                                                object:obj];
       // Add the operation to the queue and let it to be executed.
        [operationQueue addOperation:operation];
                 
    }
    segment.enabled = TRUE;
}

-(void)LoadAllinfoForFile:(File*)Tobj OriginalFile:(File*)Pobj{
    //load  file info in baground
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    
    NSMutableDictionary *fileDict = [[NSMutableDictionary alloc] init];
    [fileDict setObject:Tobj forKey:@"ThumbObj"];
    [fileDict setObject:Pobj forKey:@"ParentObj"];
    
    if(!timer){
        timer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(RealoadTableView) userInfo:nil repeats:YES];
    }
    // Create a new NSOperation object using the NSInvocationOperation subclass.
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(LoadThumbForImages:)
                                                                              object:fileDict];
    // Add the operation to the queue and let it to be executed.
    [operationQueue addOperation:operation];

    [operation setCompletionBlock:^{
        [tableview reloadData];
        [timer invalidate];
        timer=nil;
    
    }];
    segment.enabled = TRUE;
}

-(void)LoadThumbForImage:(File *)file{
    ApplicationDelegate.ThumbCount ++;
    NSArray *arr=[file.strMediaType componentsSeparatedByString:@"/"];
    NSString *strExtention=[arr objectAtIndex:0];
    
    if ([strExtention isEqualToString:@"video"]||[file.strMediaType isEqualToString:@"image/jpg"]||[file.strMediaType isEqualToString:@"image/jpeg"]) {
        [file loadThumbnailImage]; //load image if not loaded before
        
        
        NSArray *arr=[file.strMediaType componentsSeparatedByString:@"/"];
        NSString *strExtention=[arr objectAtIndex:0];
        NSString *urlString ;
        if([strExtention isEqualToString:@"video"]){
            urlString=[NSString stringWithFormat:@"%@",file.filedata];
        }
        else{
            urlString=[NSString stringWithFormat:@"%@",file.filedata];
        }
        NSURL *theURL = [NSURL URLWithString:urlString];
        
        //NSLog(@"URL = %@",urlString);
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
        NSLog(@"Access token = %@",APP.accessToken);
        [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
        //[theRequest setValue:@"image/jpeg; pxmax=140; pymax=140; sq=(1);r=(0)" forHTTPHeaderField:@"Accept"];
        [theRequest setHTTPMethod:@"GET"];
        
        
        if(ApplicationDelegate.connectionRequired){
            SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
            [ApplicationDelegate.HUD setHidden:TRUE];
        }else{
            NSError *error;
            NSHTTPURLResponse *response = nil;
            NSData *data=[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
            
            if(data!=nil){
                ///
                UIImage *image1=[UIImage imageWithData:data
                                 ];
                // [fileTypeImage setImage:image1];
                file.thumbnail=image1;
                CGImageSourceRef mySourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
                
                NSDictionary *myMetadata = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(mySourceRef,0,NULL);
                NSLog(@"exifDic properties: %@", myMetadata); //all data
                NSDictionary *exifDic = [myMetadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
                
                NSLog(@"%@ %@",file.thumbnail,NSStringFromCGSize(file.thumbnail.size));
                
                NSArray *arr=[[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeOriginal]componentsSeparatedByString:@" "];
                 file.strDateTime=[NSString stringWithFormat:@"%@ %@",[[arr objectAtIndex:0]stringByReplacingOccurrencesOfString:@":" withString:@"-"],[arr objectAtIndex:1]];
                NSLog(@"file origin date %@ ",file.strDateTime);
            }
            else{
                NSLog(@"NO DATA");
            }
            
        }
        
    }
    ApplicationDelegate.ThumbCount --;
    if(ApplicationDelegate.ThumbCount==0){
        
        //        for (int i=0; i<[arrContentList count]; i++) {
        //            File *file1=(File *)[arrContentList objectAtIndex:i];
        //
        //            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"strDisplayName CONTAINS[cd] %@",file1.strDisplayName];
        //            NSMutableArray *arr=(NSMutableArray *)[arrThumbdata filteredArrayUsingPredicate:predicate];
        //
        //            if([arr count]>0){
        //                File *file2=(File *)[arr objectAtIndex:0];
        //                file1.strDateTime=file2.strDateTime;
        //                NSLog(@"file1 :%@     file2: %@",file1.strDisplayName,file2.strDisplayName);
        //             }
        //
        //        }
        //        [tableview reloadData];
        [ApplicationDelegate.HUD setHidden:TRUE];
    }
}


-(void)LoadThumbForImages:(NSMutableDictionary *)files{
    
    File *file = [files objectForKey:@"ThumbObj"];
    File *oFile = [files objectForKey:@"ParentObj"];
//    ApplicationDelegate.ThumbCount ++;
    NSArray *arr=[file.strMediaType componentsSeparatedByString:@"/"];
    NSString *strExtention=[arr objectAtIndex:0];

    if ([strExtention isEqualToString:@"video"]||[file.strMediaType isEqualToString:@"image/jpg"]||[file.strMediaType isEqualToString:@"image/jpeg"]) {
        [file loadThumbnailImage]; //load image if not loaded before
        
        
        NSArray *arr=[file.strMediaType componentsSeparatedByString:@"/"];
        NSString *strExtention=[arr objectAtIndex:0];
        NSString *urlString ;
        if([strExtention isEqualToString:@"video"]){
            urlString=[NSString stringWithFormat:@"%@",file.filedata];
        }
        else{
            urlString=[NSString stringWithFormat:@"%@",file.filedata];
        }
        NSURL *theURL = [NSURL URLWithString:urlString];
        
        //NSLog(@"URL = %@",urlString);
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
        NSLog(@"Access token = %@",APP.accessToken);
        [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
        //[theRequest setValue:@"image/jpeg; pxmax=140; pymax=140; sq=(1);r=(0)" forHTTPHeaderField:@"Accept"];
        [theRequest setHTTPMethod:@"GET"];
        
        
        if(ApplicationDelegate.connectionRequired){
            SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
            [ApplicationDelegate.HUD setHidden:TRUE];
        }else{
            NSError *error;
            NSHTTPURLResponse *response = nil;
            NSData *data=[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
            
            if(data!=nil){
                ///
                UIImage *image1=[UIImage imageWithData:data
                                 ];
                // [fileTypeImage setImage:image1];
                file.thumbnail=image1;
                CGImageSourceRef mySourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
                
                NSDictionary *myMetadata = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(mySourceRef,0,NULL);
                NSLog(@"exifDic properties: %@", myMetadata); //all data
                NSDictionary *exifDic = [myMetadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
                
                NSLog(@"%@ %@",file.thumbnail,NSStringFromCGSize(file.thumbnail.size));
                NSArray *arr1=[[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeOriginal]componentsSeparatedByString:@" "];
                oFile.strDateTime=[NSString stringWithFormat:@"%@ %@",[[arr1 objectAtIndex:0]stringByReplacingOccurrencesOfString:@":" withString:@"-"],[arr1 objectAtIndex:1]];
                oFile.thumbnail=image1;
                NSLog(@"file origin date %@ ",file.strDateTime);
            }
            else{
                NSLog(@"NO DATA");
            }
        }
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"RealoadTableView" object:nil];
}

/*
 * this method will pop up the navigation controller to SelectWorkSpaceController.
 */
-(IBAction)HomeClicked{
    for (UIViewController* viewController in self.navigationController.viewControllers) {
        NSLog(@"%@",viewController.nibName);
        
        if(!isIpad){
            if([viewController.nibName isEqualToString:@"SelectWorkspace"]){
                [self.navigationController popToViewController:viewController animated:YES];
            }
        }
        else{
            if([viewController.nibName isEqualToString:@"SelectWorkspace_ipad"]){
                [self.navigationController popToViewController:viewController animated:YES];
            }
        }
    }
}

/**
 *  pop ups navigation controller to previous Controller.
 */
-(IBAction)Back_Clicked{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *  pop ups navigation controller to ServerSelectionViewController in iPhone.
 *  pop ups navigation controller to LogInViewController in iPad.
 */
-(IBAction)SettingsClicked{
    
    for (UIViewController* viewController in self.navigationController.viewControllers) {
        NSLog(@"%@",viewController.nibName);
        
        if(!isIpad){
            if([viewController.nibName isEqualToString:@"ServerSelectionViewController"]){
                [self.navigationController popToViewController:viewController animated:YES];
            }
        }
        else{
            if([viewController.nibName isEqualToString:@"LogInViewController_ipad"]){
                [self.navigationController popToViewController:viewController animated:YES];
            }
        }
    }
}

/**
 *  this method will open actionsheet for diffrent view option.
 */
-(void)ActionButtonClicked:(id)sender{
    int N=0;
    for(File *objfile in arrContentList){
        NSArray *arr=[objfile.strMediaType componentsSeparatedByString:@"/"];
        NSString *strExtention=[arr objectAtIndex:0];
        NSLog(@"%@", strExtention);
        if([strExtention isEqualToString:@"folder"]||[strExtention isEqualToString:@"syncFolder"]||objfile.isInfoLoaded)
        {
            N++;
        }
    }
    
    ///open UIActionSheet for view option
    
    UIActionSheet *action1=[[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Calendar View",@"Grid View",@"List View", nil];
    [action1 setTag:2222];
    [action1 showInView:self.view];
    
    
}
/**
 * Logout.
 * and pops navigation controller to RootviewController in iPad.
 */

-(void)logout_clicked{
    
    //update history table
    NSString *strHistory=@"Logout";
    [ApplicationDelegate UpdateDatabase:strHistory];
    
    APP.refreshToken = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/**
 * it will show list of file and folder in list
 */

-(void)listView_clicked{
    //show list view and hide other views
    thumbnailView.hidden= TRUE;
    tableview.hidden=FALSE;
    [tableview reloadData];
}

/**
 * it will show list of file and folder in grid
 */
-(void)gridView_clicked{
    //show gridview hide other view
    
    thumbnailView.hidden = FALSE;
    tableview.hidden=TRUE;
    if (isGridViewActive)
        [self CreateView];// create gridview
    else
        return;
}

/**
 * this method will create grid view .
 */
-(void)CreateView
{
    //Create Grid View
    
    //remove all subviews
    for(UIView *subview in [scroll subviews]) {
        [subview removeFromSuperview];
    }
    
    ///variable init
    float x;
    float y;
    int N=0;
    
    // NSLog(@"%d",[[UIDevice currentDevice] orientation]);
    if(isIpad){
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
            x = 13.83;
            KMaxViewInRow = 5;

        }
        else{
            x=28.857;
        }
        
        y=12;
    }
    else{
        
        x=4;
        y=4;
    }
    
    for (int i=0; i<[arrContentList count]; i++) {
        for (int k=0;k< KMaxViewInRow; k++) {
            if(N<[arrContentList count])
            {
                // BOOL isPng=FALSE;
                File *obj=(File *)[arrContentList objectAtIndex:N];
                AsyncImageview *imgFrame;
                if (isIpad){
                    imgFrame=[[AsyncImageview alloc] initWithFrame:CGRectMake(x, y, KWeidth_ipad, KHeight_ipad)];
                    imgFrame.tag=ImgProductTag+1+N;
                    //[imgFrame loadThumbnailImage:obj];
                }
                else{
                    imgFrame=[[AsyncImageview alloc] initWithFrame:CGRectMake(x, y, KWeidth, KHeight)];
                    imgFrame.tag=ImgProductTag+1+N;
                    //[imgFrame loadThumbnailImage:obj];
                }
                
                imgFrame.backgroundColor=[UIColor clearColor];
                //                [imgFrame setImage:obj.thumbnail];
                
                UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
                
                if (isIpad){
                    btn.frame=CGRectMake(x, y,KWeidth_ipad, KWeidth_ipad);
                    btn.tag=btnProductTag+1+N;
                }
                else{
                    btn.frame=CGRectMake(x, y, KWeidth, KHeight);
                    btn.tag=btnProductTag+1+N;
                }
                
                [btn addTarget:self action:@selector(explorObj:) forControlEvents:UIControlEventTouchUpInside];
                btn.contentMode = UIViewContentModeScaleToFill;
                
                [btn setImage:[UIImage imageNamed:@"box_frame.png"] forState:UIControlStateNormal];
                [btn setBackgroundColor:[UIColor clearColor]];
                
                UILabel *lblName;
                if (isIpad)
                    lblName=[[UILabel alloc] initWithFrame:CGRectMake(x+18,y+KHeight+65, KWeidth+40,40)];
                else
                    lblName=[[UILabel alloc] initWithFrame:CGRectMake(x+5,y+KHeight-03, KWeidth+10,30)];
                
                lblName.tag=lblNameTag+1+N;
                lblName.backgroundColor=[UIColor clearColor];
                lblName.font=[UIFont fontWithName:@"Helvetica" size:11];
                lblName.textColor=[UIColor blackColor];
                lblName.textAlignment=NSTextAlignmentCenter;
                lblName.text=obj.strDisplayName;
                
                [imgFrame setImage:obj.thumbnail];
                NSArray *arr=[obj.strMediaType componentsSeparatedByString:@"/"];
                NSString *strExtention=[arr objectAtIndex:0];
                
                //set file icon as per file type
                if([strExtention isEqualToString:@"folder"]||[strExtention isEqualToString:@"syncFolder"])
                {
                    imgFrame.image=[UIImage imageNamed:@"folder.png"];
                    //                    isFolder = TRUE;
                }
                else if([obj.strMediaType isEqualToString:@"application/pdf"])
                {
                    imgFrame.image=[UIImage imageNamed:@"pdf.png"];
                }
                else if([strExtention isEqualToString:@"text"])
                {
                    imgFrame.image=[UIImage imageNamed:@"txt.png"];
                }
                else if([strExtention isEqualToString:@"image"])
                {
                    imgFrame.image=[UIImage imageNamed:@"imgIcon.png"];
                }
                else if([strExtention isEqualToString:@"audio"])
                {
                    imgFrame.image=[UIImage imageNamed:@"audio.png"];
                }
                else if([strExtention isEqualToString:@"video"])
                {
                    imgFrame.image=[UIImage imageNamed:@"video.png"];
                }
                else if([obj.strMediaType isEqualToString:@"application/msword"]||[obj.strMediaType  isEqualToString:@"application/vnd.openxmlformats-officedocument.wordprocessingml.document"])
                {
                    imgFrame.image=[UIImage imageNamed:@"Word.png"];
                }
                else if([obj.strMediaType isEqualToString:@"application/vnd.ms-excel"])
                {
                    imgFrame.image=[UIImage imageNamed:@"xls.png"];
                }
                else if([obj.strMediaType isEqualToString:@"application/vnd.ms-powerpoint"])
                {
                    imgFrame.image=[UIImage imageNamed:@"ppt.png"];
                }
                else{
                    imgFrame.image=[UIImage imageNamed:@"brokenfile.png"];
                }
                
                ///load thumbnail for video and image file
                if(obj.thumbnail && ([obj.strMediaType isEqualToString:@"image/jpeg"] ||[obj.strMediaType isEqualToString:@"image/jpg"]||[obj.strMediaType isEqualToString:@"image/png"]||[strExtention isEqualToString:@"video"]))
                {

               // if ([strExtention isEqualToString:@"video"]||[obj.strMediaType isEqualToString:@"image/jpg"]||[obj.strMediaType isEqualToString:@"image/jpeg"]||[obj.strMediaType  isEqualToString:@"image/png"]) {
                    if (isIpad) {
                        if (obj.thumbnail) {
                            [imgFrame setImage:obj.thumbnail]; //set thumbnail image
                        }
                        else{
                            [imgFrame loadThumbnailImage:obj]; //load thumnail image if thumnail image is nil
                            
                            
                        }
                    }
                    else
                    {
                        if (obj.thumbnail) {
                            [btn setImage:obj.thumbnail forState:UIControlStateNormal];}
                        else{
                            [imgFrame loadThumbnailImage:obj];
                            
                        }
                        
                        
                    }
                }
                ///------adding to scrollview-------///////
                [scroll addSubview:imgFrame];
                [scroll addSubview:btn];
                [scroll addSubview:lblName];
                
                ////// set X and Y value for row in gridview
                if (isIpad) {
                    float space;
                    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
                        space = 13.83;
                    }
                    else{
                        space=28.857;
                    }
                    
                    x=x+KWeidth_ipad + space;
                    N++;
                }
                else{
                    x=x+KWeidth +3;
                    N++;
                }
            }
            else{
                
            }
        }
        
        ////// set X and Y value for coloum  in gridview
        if (isIpad) {
            if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
                x = 13.83;
            }
            else{
                x=28.857;
            }
            y = y+KHeight+100;
        }
        else{
            x = 4;
            y = y+KHeight+28;
        }
    }
    
    [scroll setShowsVerticalScrollIndicator:YES];
    
    //set scrollview content size
    if(y>scroll.frame.size.height){
        if (isIpad){
            float h=y/4; //-scroll.frame.size.height;
            // [scroll setContentSize:CGSizeMake(scroll.frame.size.width,(scroll.frame.size.height+h))];
            
            int hght = [arrContentList count] / KMaxViewInRow;
            int hght1 = [arrContentList count] % KMaxViewInRow;
            
            if (hght1 > 0) {
                hght++;
            }
            [scroll setContentSize:CGSizeMake(self.view.frame.size.width,h)];
        }else{
            float h=y/5; //-scroll.frame.size.height;
            // [scroll setContentSize:CGSizeMake(scroll.frame.size.width,(scroll.frame.size.height+h))];
            [scroll setContentSize:CGSizeMake(scroll.frame.size.width,h+20)];
        }
        
    }

    NSLog(@"scroll content size : %@",NSStringFromCGSize(scroll.contentSize));
}

/*
 * this method call on click of any thumbnail in grid view.
 */
-(IBAction)explorObj:(id)sender{
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
        [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        
        UIButton *btn=sender;
        
        
        INDEXPATH = btn.tag-1000-1;
        //   NSLog(@"INDEXPATH = %d",INDEXPATH);
        
        
        File *obj=(File *)[arrContentList objectAtIndex:INDEXPATH];
        NSArray *arr=[obj.strMediaType componentsSeparatedByString:@"/"];
        NSString *strExtention=[arr objectAtIndex:0];
        NSLog(@"%@", strExtention);
        // NSLog(@"file type: %@ ",obj.strMediaType);
        
        //open editor according to type of selected file
        
        if([obj.strMediaType isEqualToString:@"folder"]||[obj.strMediaType isEqualToString:@"syncFolder"])
        {
            
            NSString *strHistory=[NSString stringWithFormat:@"%@ folder Opened",obj.strDisplayName];
            [ApplicationDelegate UpdateDatabase:strHistory]; //update history table
            
            
            //load workspace content
            currentFile=obj;
            workspaceContent *objWork;
            if (isIpad) {
                objWork=[[workspaceContent alloc] initWithNibName:@"workspaceContent_ipad" bundle:nil];
            }
            else{
                objWork=[[workspaceContent alloc] initWithNibName:@"workspaceContent" bundle:nil];}
            objWork.title=obj.strDisplayName;
            [self.navigationController pushViewController:objWork animated:YES];
        }
        else if([strExtention isEqualToString:@"image"])
        {
            NSString *strHistory=[NSString stringWithFormat:@"%@ image Opened",obj.strDisplayName];
            [ApplicationDelegate UpdateDatabase:strHistory]; //update history table
            //  imgEditObj.selectedImageName = [NSString stringWithFormat:@"%@",obj.strDisplayName];
            
            [arrImageFileList removeAllObjects]; //reset array
            
            int N=0;
            //load image file in array
            for (File *fileobj1 in arrContentList) {
                NSArray *arr1=[fileobj1.strMediaType componentsSeparatedByString:@"/"];
                NSString *strExt=[arr1 objectAtIndex:0];
                if([strExt isEqualToString:@"image"])
                {
                    [arrImageFileList addObject:fileobj1];
                    /*
                    MyPhoto *objPhoto=[[MyPhoto alloc]initWithImageURL:[NSURL URLWithString:fileobj1.filedata] name:fileobj1.strDisplayName];
                    [arr addObject:objPhoto];
                    NSLog(@"%@",fileobj1.filedata);
                    
                    if (fileobj1==obj) {
                        ApplicationDelegate.selectedindex=N;
                    }
                    N++;
                     */
                    
                    MWPhoto *photoObject = [MWPhoto photoWithURL:[NSURL URLWithString:fileobj1.filedata] checkalue:YES];
                    photoObject.caption = fileobj1.strDisplayName;
                    [self.photos addObject:photoObject];
                    
                    if (fileobj1==obj) {
                        ApplicationDelegate.selectedindex=N;
                    }
                    N++;
                    

                }
                
                          }
            
            
            // open photoviewer
           // self.photos=arr;
            if([self.photos count] >0){
                /*
                MyPhotoSource *source = [[MyPhotoSource alloc] initWithPhotos:arr];
                
                EGOPhotoViewController *photoController = [[EGOPhotoViewController alloc] initWithPhotoSource:source];
                isImageFromCalView = NO;
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:photoController];
                
                navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                navController.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:navController animated:YES completion:nil];
                */
                MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
                // Set options
                browser.wantsFullScreenLayout = YES; // Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
                browser.displayActionButton = YES; // Show action button to save, copy or email photos (defaults to NO)
                //[browser setInitialPageIndex:ApplicationDelegate.selectedindex]; // Example: allows second image to be presented first
                // Present
                [browser setCurrentPhotoIndex:ApplicationDelegate.selectedindex];
                [self.navigationController pushViewController:browser animated:YES];
                

            }
        }
        else if([strExtention isEqualToString:@"text"])
        {
            
            NSString *strHistory=[NSString stringWithFormat:@"%@ file Opened",obj.strDisplayName];
            [ApplicationDelegate UpdateDatabase:strHistory]; //update history table
            
            
            //open text editor
            TextEditViewController *file;
            if(isIpad){
                file = [[TextEditViewController alloc]initWithNibName:@"TextEditViewController_ipad" bundle:nil];
            }else{
                file = [[TextEditViewController alloc]initWithNibName:@"TextEditViewController" bundle:nil];
            }
            file.title=obj.strDisplayName;
            UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
            self.navigationItem.backBarButtonItem = back;
            file.fileDict=obj;
            [self.navigationController pushViewController:file animated:YES];
            
        }
        else if([strExtention isEqualToString:@"audio"])
        {
            NSString *strHistory=[NSString stringWithFormat:@"%@ Audio file Opened",obj.strDisplayName];
            [ApplicationDelegate UpdateDatabase:strHistory];//update history table
            
            //open audio player
            PlayerViewController *player;
            if(isIpad){
                player=[[PlayerViewController alloc] initWithNibName:@"PlayerViewController_ipad" bundle:nil];}
            else{
                player=[[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
            }
            player.fileUrl=obj.ref;
            player.objFile=obj;
            UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
            self.navigationItem.backBarButtonItem = back;
            [self.navigationController pushViewController:player animated:YES];
            //video/quicktime
        }
        else if([strExtention isEqualToString:@"video"])
        {
            NSString *strHistory=[NSString stringWithFormat:@"%@ Video File Opened",obj.strDisplayName];
            [ApplicationDelegate UpdateDatabase:strHistory]; //update history table
            
            
            //open video player
            MoviePlayerController *player;
            if(isIpad)
            {
                player=[[MoviePlayerController alloc] initWithNibName:@"MoviePlayerController_ipad" bundle:nil];
            }
            else{
                player=[[MoviePlayerController alloc] initWithNibName:@"MoviePlayerController" bundle:nil];}
            player.fileUrl=obj.ref;
            player.objFile=obj;
            UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
            self.navigationItem.backBarButtonItem = back;
            [self.navigationController pushViewController:player animated:YES];
            //video/quicktime
        }
        else if([obj.strMediaType  isEqualToString:@"application/pdf"]||[obj.strMediaType  isEqualToString:@"application/msword"]||[obj.strMediaType  isEqualToString:@"application/vnd.ms-excel"]||[obj.strMediaType  isEqualToString:@"application/vnd.ms-powerpoint"]||[obj.strMediaType  isEqualToString:@"application/vnd.openxmlformats-officedocument.wordprocessingml.document"]){
            
            //open pdf view controller
            PDFViewerController *pdfviewer;
            if(isIpad){
                pdfviewer=[[PDFViewerController alloc] initWithNibName:@"PDFViewerController_ipad" bundle:nil];
            }
            else{
                pdfviewer=[[PDFViewerController alloc] initWithNibName:@"PDFViewerController" bundle:nil];
            }
            pdfviewer.objfile=obj;
            [self.navigationController pushViewController:pdfviewer animated:YES];
        }
        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - sorting

/*
 * this method cwill open actionsheet to give sorting option for files and folder in iPhone
 */
-(void)openActionSheet{
    
    //open action sheet for sorting array in iPhone/iPod
    action=[[UIActionSheet alloc]initWithTitle:@"Sort list " delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Name",@"Size",@"Date", nil];
    action.tag=1111;
    [action showInView:self.view];
    
}
/*
 * actionSheet delegate method
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag==1111){
        
        //sort array/////////////////
        
        if(buttonIndex==0)
        {
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"strDisplayName"
                                                                           ascending:NO];
            
            sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"strDisplayName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            arrContentList =(NSMutableArray *)[arrContentList sortedArrayUsingDescriptors:sortDescriptors];
            
            
        }
        else if(buttonIndex==1)
        {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"size"
                                                                           ascending:YES];
            
            //sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"size" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            arrContentList =(NSMutableArray *)[arrContentList sortedArrayUsingDescriptors:sortDescriptors];
        }
        else if(buttonIndex==2)
        {
            //            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"strDateTime"
            //                                                                           ascending:YES];
            //
            //            sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"strDateTime" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"strDateTime"
                                                                           ascending:YES];
            
            sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"strDateTime" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            arrContentList =(NSMutableArray *)[arrContentList sortedArrayUsingDescriptors:sortDescriptors];
        }
        [tableview reloadData];
        if(tableview.hidden){
            [self performSelector:@selector(CreateView) withObject:self afterDelay:0.2];}
        action=nil;
    }
    else if (actionSheet.tag==2222)
    {
        
        if(buttonIndex==0)
        {
            [self CalenderViewClicked]; ///load calenderview
        }
        else if (buttonIndex==1)
        {
            [self gridView_clicked];  ///load gridview
        }
        else if (buttonIndex==2)
        {
            
            [self listView_clicked]; /// load listview
        }
        //        else if (buttonIndex==3)
        //        {
        //            [self HistoryViewClicked]; ///load historyview
        //        }
        //        else if (buttonIndex==3)
        //        {
        //            [self logout_clicked]; //logout
        //        }
        
    }
    
}

/*
 * it will load History view
 */

-(void)HistoryViewClicked{
    
    ///load history view
    HistoryViewController *historyview;
    if(isIpad){
        historyview=[[HistoryViewController alloc] initWithNibName:@"HistoryViewController_ipad" bundle:nil];
        
    }
    else{
        historyview=[[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil];
        
    }
    [self.navigationController pushViewController:historyview animated:YES];
}

/*
 * it will load Calender view
 * its filter list of files and folder  for  images and show as per date in Calender view
 */
-(void)CalenderViewClicked{
    
    //filter array for image list
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    for (File *fileobj1 in arrContentList) {
        NSArray *arr1=[fileobj1.strMediaType componentsSeparatedByString:@"/"];
        NSString *strExt=[arr1 objectAtIndex:0];
        if(([strExt isEqualToString:@"image"] && fileobj1.isInfoLoaded)||([strExt isEqualToString:@"video"] && fileobj1.isInfoLoaded))
        {
            //NSArray *ar = [fileobj1.strDateTime componentsSeparatedByString:@" "];            
            NSArray *ar = [fileobj1.strDateTime componentsSeparatedByString:@" "];
            [customCell fillCellWithObject:fileobj1];
            fileobj1.dateStr = [ar objectAtIndex:0];
            //     NSLog(@"%@",fileobj1.thumbnail);video
            [arr addObject:fileobj1];
        }
    }
    
    [arrImageListForCal removeAllObjects]; //reset array before adding new list
    
    ///load calenderview
    ImageCalendarViewController *calView;
    if(isIpad){
        calView=[[ImageCalendarViewController alloc] initWithNibName:@"ImageCalendarViewController_ipad" bundle:nil];
    }
    else{
        calView=[[ImageCalendarViewController alloc] initWithNibName:@"ImageCalendarViewController" bundle:nil];
    }
    
    [calView.arrImageListForListView addObjectsFromArray:arr];
    [arrImageListForCal addObjectsFromArray:arr];
    [self.navigationController pushViewController:calView animated:YES];
}

/*
 * this method will sort the list of files and folder .
 * and then refresh the view.
 */
-(IBAction)SegmentChange:(id)sender{
    // UISegmentedControl *segment=sender;
    
    
    ///sorting array
    
    
    if(segment.selectedSegmentIndex==0)
    {
        
        if(![[segment titleForSegmentAtIndex:segment.selectedSegmentIndex] isEqualToString:@"Title ▲"]) {
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"strDisplayName"
                                                                           ascending:YES];
            
            sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"strDisplayName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            arrContentList =(NSMutableArray *)[arrContentList sortedArrayUsingDescriptors:sortDescriptors];
            [segment setTitle:@"Title ▲" forSegmentAtIndex:segment.selectedSegmentIndex];
        }
        else {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"strDisplayName"
                                                                           ascending:NO];
            
            sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"strDisplayName" ascending:NO selector:@selector(caseInsensitiveCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            arrContentList =(NSMutableArray *)[arrContentList sortedArrayUsingDescriptors:sortDescriptors];
            [segment setTitle:@"Title ▼" forSegmentAtIndex:segment.selectedSegmentIndex];
        }
        
    }
    else if(segment.selectedSegmentIndex==1)
    {
        if(![[segment titleForSegmentAtIndex:segment.selectedSegmentIndex] isEqualToString:@"Size ▲"]) {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"size"
                                                                           ascending:YES];
            
            // sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"size" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            arrContentList =(NSMutableArray *)[arrContentList sortedArrayUsingDescriptors:sortDescriptors];
            [segment setTitle:@"Size ▲" forSegmentAtIndex:segment.selectedSegmentIndex];
        }
        else {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"size"
                                                                           ascending:NO];
            
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            arrContentList =(NSMutableArray *)[arrContentList sortedArrayUsingDescriptors:sortDescriptors];
            [segment setTitle:@"Size ▼" forSegmentAtIndex:segment.selectedSegmentIndex];
        }
    }
    else if(segment.selectedSegmentIndex==2)
    {
        if(![[segment titleForSegmentAtIndex:segment.selectedSegmentIndex] isEqualToString:@"Date ▲"]) {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"strDateTime"
                                                                           ascending:YES];
            
            sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"strDateTime" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            arrContentList =(NSMutableArray *)[arrContentList sortedArrayUsingDescriptors:sortDescriptors];
            [segment setTitle:@"Date ▲" forSegmentAtIndex:segment.selectedSegmentIndex];
        }
        else {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"strDateTime"
                                                                           ascending:NO];
            sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"strDateTime" ascending:NO selector:@selector(caseInsensitiveCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            arrContentList =(NSMutableArray *)[arrContentList sortedArrayUsingDescriptors:sortDescriptors];
            [segment setTitle:@"Date ▼" forSegmentAtIndex:segment.selectedSegmentIndex];
        }
    }
    
    
    //refresh view
    if(tableview.hidden)
    {
        [self CreateView]; ///refresh the view if its grid view selected
    }
    else{
        if(tableview.hidden){
            [self performSelector:@selector(CreateView) withObject:self afterDelay:0.2];}
        [tableview reloadData]; //refresh the view if its table view selected
    }
}

#pragma mark - tableview delegate method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrContentList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *customIdentifier = @"KtblCellView";
//    customIdentifier = @"tblCellView";
    
    WorkSpaceCell *cell = (WorkSpaceCell*)[tableView dequeueReusableCellWithIdentifier:customIdentifier];
    if(cell == nil) {
        if(isIpad)
        {
            [[NSBundle mainBundle] loadNibNamed:@"WorkSpaceCell_ipad" owner:self options:nil];
        }
        else{
            [[NSBundle mainBundle] loadNibNamed:@"WorkSpaceCell" owner:self options:nil];}
    }
    
    
    File *obj=(File *)[arrContentList objectAtIndex:indexPath.row];
    customCell.arrContentListCount = [arrContentList count];
    [customCell fillCellWithObject:obj];
    
    customCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    // NSLog(@"file type: %@ ",obj.strMediaType);
    return customCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
        [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        INDEXPATH = indexPath.row;
        
        File *obj=(File *)[arrContentList objectAtIndex:INDEXPATH];
        NSArray *arr=[obj.strMediaType componentsSeparatedByString:@"/"];
        NSString *strExtention=[arr objectAtIndex:0];
        NSLog(@"%@", strExtention);
        // NSLog(@"file type: %@ ",obj.strMediaType);
        
        //open editor according to type of selected file
        
        if([obj.strMediaType isEqualToString:@"folder"]||[obj.strMediaType isEqualToString:@"syncFolder"])
        {
            NSString *strHistory=[NSString stringWithFormat:@"%@ folder Opened",obj.strDisplayName];
            [ApplicationDelegate UpdateDatabase:strHistory]; //update history table
            
            currentFile=obj;
            workspaceContent *objWork;
            if (isIpad) {
                objWork=[[workspaceContent alloc] initWithNibName:@"workspaceContent_ipad" bundle:nil];
            }
            else{
                objWork=[[workspaceContent alloc] initWithNibName:@"workspaceContent" bundle:nil];}
            objWork.title=obj.strDisplayName;
            [self.navigationController pushViewController:objWork animated:YES];
        }
        else if([strExtention isEqualToString:@"image"])
        {
            NSString *strHistory=[NSString stringWithFormat:@"%@ image Opened",obj.strDisplayName];
            [ApplicationDelegate UpdateDatabase:strHistory]; //update history table
            
            
            [arrImageFileList removeAllObjects];//reset array
           ////////////New Photo Viewer
            int N =0;
            self.photos = [[NSMutableArray alloc]init];
            for (File *fileobj1 in arrContentList) {
                NSArray *arr1=[fileobj1.strMediaType componentsSeparatedByString:@"/"];
                NSString *strExt=[arr1 objectAtIndex:0];
                if([strExt isEqualToString:@"image"])
                {
                    NSLog(@"FILEDATA%@",fileobj1.filedata);
//
                    MWPhoto *photoObject = [MWPhoto photoWithURL:[NSURL URLWithString:fileobj1.filedata] checkalue:YES];
                    //MWPhoto *photoObject = [MWPhoto photoWithImage:[UIImage imageNamed:@"o_15226dab79869a00001.png"]];

                    photoObject.caption = fileobj1.strDisplayName;
                    [self.photos addObject:photoObject];
                    
                    if (fileobj1==obj) {
                        ApplicationDelegate.selectedindex=N;
                    }
                    N++;
                }
                
            }
//            [self.photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_b.jpg"]]];
//			[self.photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b_b.jpg"]]];
//			[self.photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3364/3338617424_7ff836d55f_b.jpg"]]];
//			[self.photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b_b.jpg"]]];
//
            
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            // Set options
            browser.wantsFullScreenLayout = YES; // Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
            browser.displayActionButton = YES; // Show action button to save, copy or email photos (defaults to NO)
          //  [browser setInitialPageIndex:ApplicationDelegate.selectedindex]; // Example: allows second image to be presented first
            [browser setCurrentPhotoIndex:ApplicationDelegate.selectedindex];
            // Present
            [self.navigationController pushViewController:browser animated:YES];
            

            //////////////////old portion of Photo Viewer
            //create new array of images
/*
            int N=0;
            
            NSMutableArray *arr=[[NSMutableArray alloc]init];
            for (File *fileobj1 in arrContentList) {
                NSArray *arr1=[fileobj1.strMediaType componentsSeparatedByString:@"/"];
                NSString *strExt=[arr1 objectAtIndex:0];
                if([strExt isEqualToString:@"image"])
                {
                    [arrImageFileList addObject:fileobj1];
                    MyPhoto *objPhoto=[[MyPhoto alloc]initWithImageURL:[NSURL URLWithString:fileobj1.filedata] name:fileobj1.strDisplayName];
                    [arr addObject:objPhoto];
                    
                    
                    if (fileobj1==obj) {
                        ApplicationDelegate.selectedindex=N;
                    }
                    N++;
                }
                
            }
            // open photo editor
            
            self.photos=arr;
            if([self.photos count] >0){
                MyPhotoSource *source = [[MyPhotoSource alloc] initWithPhotos:arr];
                
                EGOPhotoViewController *photoController = [[EGOPhotoViewController alloc] initWithPhotoSource:source];
                isImageFromCalView = NO;
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:photoController];
                
                navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                navController.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentModalViewController:navController animated:YES];
                
            }*/
        }
        else if([strExtention isEqualToString:@"text"])
        {
            
            NSString *strHistory=[NSString stringWithFormat:@"%@ file Opened",obj.strDisplayName];
            [ApplicationDelegate UpdateDatabase:strHistory]; //update history table
            
            
            //open text editor
            TextEditViewController *file;
            if(isIpad){
                file = [[TextEditViewController alloc]initWithNibName:@"TextEditViewController_ipad" bundle:nil];
            }else{
                file = [[TextEditViewController alloc]initWithNibName:@"TextEditViewController" bundle:nil];
            }
            file.title=obj.strDisplayName;
            UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
            self.navigationItem.backBarButtonItem = back;
            file.fileDict=obj;
            [self.navigationController pushViewController:file animated:YES];
            
        }
        else if([strExtention isEqualToString:@"audio"])
        {
            NSString *strHistory=[NSString stringWithFormat:@"%@ Audio file Opened",obj.strDisplayName];
            [ApplicationDelegate UpdateDatabase:strHistory]; //update history table
            
            
            ///open audio player
            PlayerViewController *player;
            if(isIpad){
                player=[[PlayerViewController alloc] initWithNibName:@"PlayerViewController_ipad" bundle:nil];}
            else{
                player=[[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
            }
            player.fileUrl=obj.ref;
            player.objFile=obj;
            UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
            self.navigationItem.backBarButtonItem = back;
            [self.navigationController pushViewController:player animated:YES];
            
        }
        else if([strExtention isEqualToString:@"video"])
        {
            NSString *strHistory=[NSString stringWithFormat:@"%@ Video File Opened",obj.strDisplayName];
            [ApplicationDelegate UpdateDatabase:strHistory]; //update history table
            
            
            //open video player
            MoviePlayerController *player;
            if(isIpad)
            {
                player=[[MoviePlayerController alloc] initWithNibName:@"MoviePlayerController_ipad" bundle:nil];
            }
            else{
                player=[[MoviePlayerController alloc] initWithNibName:@"MoviePlayerController" bundle:nil];}
            player.fileUrl=obj.ref;
            player.objFile=obj;
            UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
            self.navigationItem.backBarButtonItem = back;
            [self.navigationController pushViewController:player animated:YES];
            //video/quicktime
        }
        else if([obj.strMediaType  isEqualToString:@"application/pdf"]||[obj.strMediaType  isEqualToString:@"application/msword"]||[obj.strMediaType  isEqualToString:@"application/vnd.ms-excel"]||[obj.strMediaType  isEqualToString:@"application/vnd.ms-powerpoint"]||[obj.strMediaType  isEqualToString:@"application/vnd.openxmlformats-officedocument.wordprocessingml.document"]){
            
            //open PDFviewerController
            
            PDFViewerController *pdfviewer;
            if(isIpad){
                pdfviewer=[[PDFViewerController alloc] initWithNibName:@"PDFViewerController_ipad" bundle:nil];
            }
            else{
                pdfviewer=[[PDFViewerController alloc] initWithNibName:@"PDFViewerController" bundle:nil];
            }
            pdfviewer.objfile=obj;
            [self.navigationController pushViewController:pdfviewer animated:YES];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return TRUE;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle==UITableViewCellEditingStyleDelete)
    {
        // pop up alert to make sure delete function
        INDEXPATH = indexPath.row;
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Deleting a file is irreversible" message:@"Files deleted in this way are permanently removed from the system and cannot be recovered" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [alert setTag:2001];
        [alert show];
    }
}
/**
 * this method delete files permanently from Sugersync
 * start new NSMutableURLRequest for deleting file.
 * on sucess of deletion in(connectionDidFinishLoading) method refresh the view and file and folder list.
 */
-(void)DeleteFile
{
    //delete files permanently
    
    [ApplicationDelegate.HUD setHidden:FALSE];
    File *obj=(File *)[arrContentList objectAtIndex:INDEXPATH];
    
    NSString *urlString =[NSString stringWithFormat:@"%@",obj.ref];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
    // NSLog(@"URL = %@",urlString);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    //NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"DELETE"];
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
        [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        ConnectionDelete = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if(ConnectionDelete) {
            
            ResponseDataDelete = [[NSMutableData alloc] init];
        }
    }
    NSString *strHistory=[NSString stringWithFormat:@"%@ file deleted",obj.strDisplayName];
    [ApplicationDelegate UpdateDatabase:strHistory]; //update history table
}
#pragma mark - alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==2001) {
        if(buttonIndex==1){
            [self DeleteFile];
        }// delete file permanently
    }
}
#pragma mark - Http connection method
-(void)workSpaceContent{   //////Load Folder Information (not content)
    //load folder info
    
    [ApplicationDelegate.HUD setHidden:FALSE];
    NSString *urlString =[NSString stringWithFormat:@"%@",currentFile.ref];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:APP.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"GET"];
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
        [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        Connection1 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        NSLog(@"request started to load detail of folder");
        if(Connection1) {
            
            ResponseData1 = [[NSMutableData alloc] init];
        }
        
        else {
            //NSLog(@"Error, Invalid Request");
        }
    }
}

/**
 * this method Load folder or file detail from Sugersync
 * start new NSMutableURLRequest to load folder data.
 * in(connectionDidFinishLoading) method refresh the view and file and folder list.
 */
-(void)workspaceFileContent{ //loading selected folder content list
    
    //load folder data
    
    NSString *urlString =[NSString stringWithFormat:@"%@",APP.content_str];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    //NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:APP.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"GET"];
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
        [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        
        Connection2 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        NSLog(@"request started to load subfolder and files of sub folder");
        if(Connection2) {
            
            ResponseData2 = [[NSMutableData alloc] init];
        }
        else {
            //NSLog(@"Error, Invalid Request");
        }
    }
}
-(void)loadFilesOfThumbFolder:(File *)fileobj{
    //load folder data
    
    NSString *urlString =[NSString stringWithFormat:@"%@",currentThumbFolder.ref];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    //NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:APP.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"GET"];
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
        [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        
        ConnectionThumb = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if(ConnectionThumb) {
            
            ResponseDataThumb = [[NSMutableData alloc] init];
        }
        else {
            //NSLog(@"Error, Invalid Request");
        }
    }

}
#pragma mark - HTTP connection methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    if (connection == Connection1)
        ResponseData1 = nil;
    
    else if(connection == Connection2)
        ResponseData2 = nil;
    else if(connection == ConnectionDelete)
        ResponseDataDelete = nil;
    else if(connection == ConnectionThumb)
        ResponseDataThumb = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == Connection1){ // Loading Folder Info COnnection
        [ResponseData1 setLength:0];
        //NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        //  NSDictionary* headers = [httpResponse allHeaderFields];
        //NSLog(@"Header Response = %@",headers);
    }
    
    else if(connection == Connection2){ //loadinf folder content list
        [ResponseData2 setLength:0];
        // NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        //  NSDictionary* headers = [httpResponse allHeaderFields];
        //NSLog(@"Header Response = %@",headers);
    }
    else if(connection == ConnectionDelete){
        [ResponseDataDelete setLength:0];
        //  NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        //  NSDictionary* headers = [httpResponse allHeaderFields];
        //   NSLog(@"Header Response = %@",headers);
    }
    else if(connection == ConnectionThumb){
        [ResponseDataThumb setLength:0];
        //  NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        //  NSDictionary* headers = [httpResponse allHeaderFields];
        //   NSLog(@"Header Response = %@",headers);
    }
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    NSLog(@"content length : %llu",[response expectedContentLength]);
    NSLog(@"Status Code : %d",code);
    
    if (code == 401 & [response expectedContentLength] == 315) {
        ApplicationDelegate.TokenExpired = TRUE;
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == Connection1)
        [ResponseData1 appendData:data];
    
    else if(connection == Connection2)
        [ResponseData2 appendData:data];
    
    else if(connection == ConnectionDelete)
        [ResponseDataDelete appendData:data];
    else if(connection == ConnectionThumb)
        [ResponseDataThumb appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    NSString *Authtoken=@"Auth token expired. Please re-obtain token.";
//    BOOL TokenExpired=FALSE;
    
    if (connection == Connection1) { /// folder info responce
        NSString *responsestring= [[NSString alloc] initWithData:ResponseData1 encoding:NSUTF8StringEncoding];
        NSLog(@"responsestring of folder detail = %@",responsestring);
         
      
        NSString *start1 = @"<h3>";
        NSRange starting1 = [responsestring rangeOfString:start1];
        if(starting1.location != NSNotFound){
            NSString *end1 = @"</h3>";
            NSRange ending1 = [responsestring rangeOfString:end1];
            NSString *str1 = [responsestring substringWithRange:NSMakeRange(starting1.location + starting1.length, ending1.location - (starting1.location + starting1.length))];
           ApplicationDelegate.TokenExpired=[str1 isEqualToString:Authtoken];
        }

        if(ApplicationDelegate.TokenExpired){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshAccessToken" object:nil];
            ApplicationDelegate.TokenExpired=FALSE;
        }
        else {
            if([currentFile.strDisplayName isEqualToString:@"receivedShares"]){
                // parse XMLdata if receivedShares id parent folder
                
                NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:ResponseData1];
                XMLParserSharedFolder *parser = [[XMLParserSharedFolder alloc] initXMLParser];
                [xmlParser setDelegate:parser];
                BOOL success = [xmlParser parse];
                
                if(success){
                    //NSLog(@"No Errors In XML Parsing");
                }
                else{
                    //NSLog(@"Error In XMLParsing");
                }
                
                //populate array with new content
                [arrContentList addObjectsFromArray:ApplicationDelegate.albumContent];
                //start loading info in background
                // [self performSelectorInBackground:@selector(LoadAllinfo) withObject:nil];
                
                //refresh tableview
                [tableview reloadData];
                if(tableview.hidden){
                    [self performSelector:@selector(CreateView) withObject:self afterDelay:0.2];}
                
                [ApplicationDelegate.albumContent removeAllObjects];//reset album conent array
                [ApplicationDelegate.HUD setHidden:TRUE];
            }
            else{
                //get folder data url
                NSString *start = @"<contents>";
                NSRange starting = [responsestring rangeOfString:start];
                if(starting.location != NSNotFound){
                    NSString *end = @"</contents>";
                    NSRange ending = [responsestring rangeOfString:end];
                    NSString *str = [responsestring substringWithRange:NSMakeRange(starting.location + starting.length, ending.location - (starting.location + starting.length))];
                    
                    APP.content_str = [[NSString stringWithString:str]mutableCopy];
                    
                    [self workspaceFileContent]; //load folder data
                }
            }

        }
    }
    else if(connection == ConnectionThumb){
        NSString *responsestring= [[NSString alloc] initWithData:ResponseDataThumb encoding:NSUTF8StringEncoding];
    //    NSLog(@"responsestring = %@",responsestring);
        NSLog(@"responsestring of loading all thumnail of Thumb folder = %@",responsestring);

        
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:ResponseDataThumb];
        XMLParser *parser = [[XMLParser alloc] initXMLParser];
        [xmlParser setDelegate:parser];
        BOOL success = [xmlParser parse];
        
        if(success){
            //NSLog(@"No Errors In XML Parsing");
        }
        else{
            //NSLog(@"Error In XMLParsing");
        }
            
        //populate array with new content
        [arrThumbdata addObjectsFromArray:ApplicationDelegate.albumContent];
        [ApplicationDelegate.albumContent removeAllObjects];
        
        NSLog(@"arrThumbdata : %@",arrThumbdata);
        if([arrThumbdata count]>0){
            for (int i=0; i<[arrContentList count]; i++) {
                File *file1=(File *)[arrContentList objectAtIndex:i];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"strDisplayName CONTAINS[cd] %@",[file1.strDisplayName stringByDeletingPathExtension]];
                NSMutableArray *arr=(NSMutableArray *)[arrThumbdata filteredArrayUsingPredicate:predicate];
                
                if([arr count]>0){
                    File *file2=(File *)[arr objectAtIndex:0];
//                    file1.strDateTime=file2.strDateTime;
                    NSLog(@"file1 :%@     file2: %@",file1.strDisplayName,file2.strDisplayName);
                    [self LoadAllinfoForFile:file2 OriginalFile:file1];
                }
            }
            if(tableview.hidden){
                [self performSelector:@selector(CreateView) withObject:self afterDelay:0.2];}
            [tableview reloadData];
//            [self LoadAllinfo];
        }
    }
    else if(connection == Connection2){  //folder content data responce
        
         NSString *responsestring= [[NSString alloc] initWithData:ResponseData2 encoding:NSUTF8StringEncoding];
        // NSLog(@"responsestring = %@",responsestring);
        NSLog(@"responsestring of list of subfolder and files of current folder = %@",responsestring);

        
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:ResponseData2];
        XMLParser *parser = [[XMLParser alloc] initXMLParser];
        [xmlParser setDelegate:parser];
        BOOL success = [xmlParser parse];
        
        if(success){
            //NSLog(@"No Errors In XML Parsing");
        }
        else{
            //NSLog(@"Error In XMLParsing");
        }
        
        for(int i=0;i < [ApplicationDelegate.albumContent count] ; i++){
            File *objfile = [ApplicationDelegate.albumContent objectAtIndex:i];
            if([objfile.strDisplayName isEqualToString:@"Thumb"]||[objfile.strDisplayName isEqualToString:@"thumb"])
            {
                currentThumbFolder=[[File alloc] init];
                currentThumbFolder.strDisplayName=objfile.strDisplayName;
                currentThumbFolder.strMediaType=objfile.strMediaType;
                currentThumbFolder.ref=objfile.ref;
                currentThumbFolder.strDateTime=objfile.strDateTime;
                
                CFBridgingRetain(currentThumbFolder);
                NSInteger index = [ApplicationDelegate.albumContent indexOfObject:objfile];
                NSLog(@"Object at %d",index);
                [ApplicationDelegate.albumContent removeObjectAtIndex:index];
            }
        }
        
        [arrContentList removeAllObjects];
        //populate array with new content
        [arrContentList addObjectsFromArray:ApplicationDelegate.albumContent];

         [ApplicationDelegate.HUD setHidden:YES];
        
        //start loading info for file in background
        //  [self performSelectorInBackground:@selector(LoadAllinfo) withObject:nil];
        
        //refresh tableview
//        [tableview reloadData];
        
        [self performSelectorInBackground:@selector(LoadInfoInForAlldata) withObject:nil];
        
        

        
//        [self LoadInfoInForAlldata];

        NSLog(@"%@",currentThumbFolder);
        if (currentThumbFolder) {
            [self loadFilesOfThumbFolder:nil];
        }
        
        [ApplicationDelegate.albumContent removeAllObjects];
       // [ApplicationDelegate.HUD setHidden:TRUE];
    }
    else if(connection == ConnectionDelete){ //delete responce
        NSString *responsestring= [[NSString alloc] initWithData:ResponseDataDelete encoding:NSUTF8StringEncoding];
        //  NSLog(@"responsestring = %@",responsestring);
        NSString *start1 = @"<h3>";
        NSRange starting1 = [responsestring rangeOfString:start1];
        if(starting1.location != NSNotFound){
            NSString *end1 = @"</h3>";
            NSRange ending1 = [responsestring rangeOfString:end1];
            NSString *str1 = [responsestring substringWithRange:NSMakeRange(starting1.location + starting1.length, ending1.location - (starting1.location + starting1.length))];
            ApplicationDelegate.TokenExpired=[str1 isEqualToString:Authtoken];
        }
        
        if(ApplicationDelegate.TokenExpired){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshAccessToken" object:nil];
            ApplicationDelegate.TokenExpired=FALSE;
        }
        else{

        
            NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:ResponseDataDelete];
            XMLParser *parser = [[XMLParser alloc] initXMLParser];
            [xmlParser setDelegate:parser];
            BOOL success = [xmlParser parse];
            
            if(success){
                //NSLog(@"No Errors In XML Parsing");
            }
            else{
                //NSLog(@"Error In XMLParsing");
            }
            [arrContentList removeAllObjects];
            
            [self workSpaceContent];//refresh all data
            
            [ApplicationDelegate.HUD setHidden:TRUE];
        }
        
    }
}



#pragma mark - UIInterfaceOrientation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        KMaxViewInRow = 5;
    }
    else{
        
        if(isIpad)
        {
            KMaxViewInRow = 6;
            //[thumbnailView setFrame:CGRectMake(0, 0,1024,768)];
        }
        else{
            KMaxViewInRow = 7;
            CGSize result = [[UIScreen mainScreen] bounds].size;
            if(result.height==568){
                KMaxViewInRow = 9;
            }
            // [thumbnailView setFrame:CGRectMake(0, 0,480,320)];
        }
    }
    
    if(tableview.hidden){
        [self performSelector:@selector(CreateView) withObject:self afterDelay:0.2];}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        KMaxViewInRow = 5;
        
    }
    else{
        
        if(isIpad)
        {
            KMaxViewInRow = 6;
            //   [thumbnailView setFrame:CGRectMake(0, 0,1024,768)];
        }
        else{
            KMaxViewInRow = 7;
            CGSize result = [[UIScreen mainScreen] bounds].size;
            if(result.height==568){
                KMaxViewInRow = 9;
            }
            // [thumbnailView setFrame:CGRectMake(0, 0,480,320)];
        }
    }
    if(tableview.hidden){
        [self CreateView];//load gridview
    }
    
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - MWPhotoBrowserDelegate Method

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    NSLog(@"Photos Array Count : %d", self.photos.count);
    return self.photos.count;
}
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    NSLog(@"Photo Object array :%d", self.photos.count);
//    MWPhoto *photo = [self.photos objectAtIndex:index];
    if (index < self.photos.count)
        return [self.photos objectAtIndex:index];
    return nil;
}
@end