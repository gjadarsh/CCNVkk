//
//  ImageCalendarViewController.m
//  CCNV
//
//  Created by  Linksware Inc. on 12/26/2012.
//
//

#import "ImageCalendarViewController.h"
#import "WorkSpaceCell.h"
#import "File.h"
#import "AppDelegate.h"
#import "Kal.h"
#import "Holiday.h"
#import "ImageDataSourceForCal.h"
#import "workspaceContent.h"
#import "MWPhotoBrowser.h"

@interface ImageCalendarViewController ()<MWPhotoBrowserDelegate>

@end

@implementation ImageCalendarViewController
@synthesize arrImageListForListView;
@synthesize photos = _photos;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    if(!isIpad){
        isCalViewOriantation=TRUE;
    }
    
    //add notification observer to call detailview method for image from any controller//////////////////////////////
    
    NSDateFormatter * df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    Caldate = [df stringFromDate:[NSDate date]];   //yyyy-MM-dd
    CFBridgingRetain(Caldate);

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoadDeletaolview:) name:@"CalDetailView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAndSelectToday) name:@"setTodayDate" object:nil];
    
    [super viewDidLoad];
   
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
     /// add calender controller as subview /////////////////////////////////////////
    [self LOadCalView];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - calDetailView
/**
 * this method will filter image array by selected date
 * and then load EGOPhotoview controller
 */
-(void)LoadDeletaolview:(NSNotification *)notif {
    
    [ApplicationDelegate.HUD setHidden:FALSE];
  
    isImageFromCalView=TRUE;   ///set bool value to set behavior of  EGOPhotoviewer.

    
    [navController dismissViewControllerAnimated:YES completion:nil]; /// dissmis KalView
    

    File *obj=[arrImageListForCal objectAtIndex:0];
    NSArray *arr=[obj.strMediaType componentsSeparatedByString:@"/"];
    NSString *strExtention=[arr objectAtIndex:0];
    NSLog(@"%@", strExtention);
    NSLog(@"file type: %@ ",obj.strMediaType);
    
    
    [arrImageFileList removeAllObjects]; //remove older object before loading new filterd array object
    int N=0;
  
    ApplicationDelegate.selectedindex=0; //sected index for photoviewer
    
    
    /// filtering array for image of same date (selected date)
    NSMutableArray *arrimg=[[NSMutableArray alloc]init];
    NSMutableArray *arrfilterd=[[NSMutableArray alloc]init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateStr LIKE[cd] %@",Caldate];
    arrimg=(NSMutableArray *)[arrImageListForCal filteredArrayUsingPredicate:predicate];
    
    for (File *fileobj1 in arrimg) {
        
        
        if ([Caldate isEqualToString:fileobj1.dateStr]) {
            NSArray *arr1=[fileobj1.strMediaType componentsSeparatedByString:@"/"];
            NSString *strExt=[arr1 objectAtIndex:0];
            if([strExt isEqualToString:@"image"] && fileobj1.isInfoLoaded)
            {

//            [arrImageFileList addObject:fileobj1];
//            
//            //creating obj of MyPhoto for Photoviewer
//            
//            MyPhoto *objPhoto=[[MyPhoto alloc]initWithImageURL:[NSURL URLWithString:fileobj1.filedata] name:fileobj1.strDisplayName];
//            [arrfilterd addObject:objPhoto];
//            
//            
//            NSLog(@"%@ , %@",fileobj1.dateStr ,fileobj1.strDisplayName);
                
                MWPhoto *photoObject = [MWPhoto photoWithURL:[NSURL URLWithString:fileobj1.filedata] checkalue:YES];

                photoObject.caption = fileobj1.strDisplayName;
                [arrfilterd addObject:photoObject];
                
                if (fileobj1==obj) {
                    ApplicationDelegate.selectedindex=N;
                }
                N++;
                           
            }
        }

    }
    
    
    self.photos=arrfilterd;
    if([arrfilterd count] >0){
//        MyPhotoSource *source = [[MyPhotoSource alloc] initWithPhotos:arrfilterd]; //set datasourse of photoviewer
//        
//    
//        EGOPhotoViewController *photoController = [[EGOPhotoViewController alloc] initWithPhotoSource:source];
//        [self.navigationController pushViewController:photoController animated:YES];
//        tempCount = 1;
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        // Set options
        browser.wantsFullScreenLayout = YES; // Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
        browser.displayActionButton = YES; // Show action button to save, copy or email photos (defaults to NO)
      //  [browser setInitialPageIndex:ApplicationDelegate.selectedindex];
        [browser setCurrentPhotoIndex:ApplicationDelegate.selectedindex];
        // Example: allows second image to be presented first
        // Present
        [self.navigationController pushViewController:browser animated:YES];
        

    }
    else{
        File *moviefile=(File *)[arrimg objectAtIndex:0];
        NSString *strHistory=[NSString stringWithFormat:@"%@ Video File Opened",moviefile.strDisplayName];
        [ApplicationDelegate UpdateDatabase:strHistory]; //update history table
        
        
        //open video player
        MoviePlayerController *player;
        if(isIpad)
        {
            player=[[MoviePlayerController alloc] initWithNibName:@"MoviePlayerController_ipad" bundle:nil];
        }
        else{
            player=[[MoviePlayerController alloc] initWithNibName:@"MoviePlayerController" bundle:nil];}
        player.fileUrl=moviefile.ref;
        player.objFile=moviefile;
        UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
        self.navigationItem.backBarButtonItem = back;
        [self.navigationController pushViewController:player animated:YES];
    }
    [ApplicationDelegate.HUD setHidden:TRUE];
}

/**
 * this method loads calender view with images
 * this metho will check device orientation and set the frame size of calenderview.
 * sets calenderviedw delegate and datsourse
 */

-(void)LOadCalView
{
    //set frame of KalView according to UIInterfaceOriantation /////////////////////////////////////////////
    if(isIpad){
        if([[UIApplication sharedApplication]statusBarOrientation]==UIInterfaceOrientationPortrait)
        {
            self.view.frame=CGRectMake(0, 0, 768, 1004);
        }
        else{
            self.view.frame=CGRectMake(0, 0, 1004, 768);
        }
    }
    else{
        if([[UIApplication sharedApplication]statusBarOrientation]==UIInterfaceOrientationPortrait)
        {
            self.view.frame=CGRectMake(0, 0, 320, 480);
        }
        else{
            self.view.frame=CGRectMake(0, 0, 480, 320);
        }
    }
    
    if(!arrImageListForCal)
    {
        arrImageListForCal=[[NSMutableArray alloc] init];
    }
    
    ///Load KalView and set delegate and datasouce of KalView ///////////////////////////////////////
    
        kal = [[KalViewController alloc] init];

        kal.title = @"";

        kal.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(Done)] ;
//        kal.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleBordered target:self action:@selector(showAndSelectToday)];
        dataSource = [[ImageDataSourceForCal alloc] init];
        kal.dataSource = dataSource;
        kal.delegate = dataSource;
  //  if(!isIpad){
   
     navController = [[UINavigationController alloc] initWithRootViewController:kal];
    
    navController.view.superview.frame = CGRectMake((self.view.frame.size.width-320)/2,(self.view.frame.size.height-480)/2,320,480);
    kal.view.frame= CGRectMake((self.view.frame.size.width-320)/2,(self.view.frame.size.height-480)/2,320,480);
    NSString *string = Caldate;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:string];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_EN"];
    dateFormatter.dateFormat=@"YYYYM";
    
    NSMutableString * tempHeadingStr = [[NSMutableString alloc]initWithString:[dateFormatter stringFromDate:date]];
    [tempHeadingStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [tempHeadingStr insertString:@"年" atIndex:4];
    [tempHeadingStr insertString:@"月" atIndex:tempHeadingStr.length];    
    kal.title = tempHeadingStr;
    
        //    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //    navController.modalPresentationStyle = UIModalPresentationFormSheet;

        [self presentViewController:navController animated:YES completion:nil];
//    }
//    if(isIpad){
       // navController.view.superview.frame = CGRectMake((self.view.frame.size.width-320)/2,(self.view.frame.size.height-480)/2,320,480);
        NSLog(@"frame %@",NSStringFromCGRect(self.view.frame));
    //    [self.navigationController pushViewController:kal animated:YES];
//    }}
    
}
/**
 * this method dismiss modele view controller
 * and popview to perent controller 
 * sets calenderviedw delegate and datsourse
 */

-(void)Done
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * this method will show today's date on celendar view
 */
- (void)showAndSelectToday
{
    [kal showAndSelectDate:[NSDate date]];
}

#pragma mark - tableview delegate method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrImageListForCal count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *customIdentifier = @"MyIdentifier";
    customIdentifier = @"tblCellView";
    
    WorkSpaceCell *cell = (WorkSpaceCell*)[tableView dequeueReusableCellWithIdentifier:customIdentifier];
    if(cell == nil) {
        if(isIpad)
        {
            [[NSBundle mainBundle] loadNibNamed:@"WorkSpaceCell_ipad" owner:self options:nil];
        }
        else{
            [[NSBundle mainBundle] loadNibNamed:@"WorkSpaceCell" owner:self options:nil];}
    }
    
    
    File *obj=(File *)[arrImageListForCal objectAtIndex:indexPath.row];
    customCell.arrContentListCount = [arrImageListForCal count];
    [customCell fillCellWithObject:obj];
    
    customCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    // NSLog(@"file type: %@ ",obj.strMediaType);
    return customCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    INDEXPATH = indexPath.row; 
   
     [[NSNotificationCenter defaultCenter] postNotificationName:@"CalDetailView" object:nil];
    [navController dismissViewControllerAnimated:NO completion:nil];
//  [self.navigationController popViewControllerAnimated:YES];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
        return TRUE;
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