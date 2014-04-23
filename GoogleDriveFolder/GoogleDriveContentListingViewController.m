//
//  GoogleDriveContentListingViewController.m
//  CCNV
//
//  Created by Project Development Department on 2014/04/04.
//
//

#import "GoogleDriveContentListingViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MBProgressHUD.h"
#import "GTLDrive.h"
#import "MWPhotoProtocol.h"
#import "MWPhoto.h"
#import "MWPhotoBrowser.h"
#import "GTMOAuth2SignIn.h"
#import "fillCell.h"
#import "fileCollectionCell.h"
#import "SDImageCache.h"
#import "collectionHeader.h"
#import "FileViewViewController.h"
#import "MusicPlayerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TSQTAViewController.h"
/*
static NSString *const kKeychainItemName = @"SampleDrive";
static NSString *const kClientID = @"483186167704-gkdol3ne5aedsjmbi263gmkgj411hd47.apps.googleusercontent.com";
static NSString *const kClientSecret = @"mlwwVWLOVEs6H0f8kWC76nO6";

*/
@interface GoogleDriveContentListingViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,MBProgressHUDDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,MWPhotoBrowserDelegate,UIActionSheetDelegate>
{
    MBProgressHUD *HUD;
    NSMutableArray *tableArray;
    GTLServiceTicket *ticketService;
    GTLDriveFileList *fileList;
    BOOL checkTable;
    NSMutableArray *photoBrowsePhotoArray;
    int imageSelectedIndex;
    GTLDriveFile *didSelectedDriveFile;
    
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *fileTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *fileCollectionView;
@property (nonatomic, retain)GTLDriveFile *controllerDriveFile;
@property (nonatomic, retain) GTLServiceDrive *driveService;
- (IBAction)segmentedControllerAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonSign;


@end

@implementation GoogleDriveContentListingViewController{
    GoogleDriveManager *driverManager;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _checkRoot=NO;
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"viewDidAppear:");
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    photoBrowsePhotoArray =[NSMutableArray new];
    checkTable=YES;
    self.fileCollectionView.hidden=YES;
    driverManager=[GoogleDriveManager sharedGoogleDriveManager];
    
    //Google Drive Authorize or not
    
    if (!self.isAuthorized) {
        // Sign in.
        [self checkForAuthorization];
    }else{
        [self checkAuthorize];
    }
    
    /*................ Set register Nib for Both CollectionView and TableView............................. */
    
    [self.fileTableView registerNib:[UINib nibWithNibName:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?@"fileCell_iPad" :@"fileCell_iPhone" bundle:nil] forCellReuseIdentifier:isIpad?@"filecellipad":@"fileCell"];
    [self.fileCollectionView registerNib:[UINib nibWithNibName:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?@"fileCollectionCell_iPhone" :@"fileCollectionCell_iPhone" bundle:nil] forCellWithReuseIdentifier:@"fileCollection"];
    [self.fileCollectionView registerNib:[UINib nibWithNibName:@"collectionHeader"  bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionHeaderId"];
    
    /*........................Check Whether FirstView or Not...............................................*/
    
    
    if (_checkRoot) {
        _mainToolBar.hidden=YES;
        _subToolBar.hidden=NO;

    }else{
        _mainToolBar.hidden=NO;
        _subToolBar.hidden=YES;
        

    }

    
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.hidesBackButton=YES;
    NSLog(@"%@",[_segmentedControl titleForSegmentAtIndex:0]);
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated{
}
-(void)didReceiveMemoryWarning
{
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
}

#pragma mark-Check Auth
-(void)checkAuthorize
{
    GTMOAuth2Authentication *auth =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:kClientSecret];
    if ([auth canAuthorize]) {
        NSLog(@"GTMOAuth2ViewControllerTouch%@",auth);
        [self isAuthorizedWithAuthentication:auth];
    }else{
        [self checkForAuthorization];
    }

}
#pragma mark -Google Drive API Authentication
// This method will check the user authentication
// If he is not logged in then it will go in else condition and will present a login viewController
- (void)checkForAuthorization
{
    
    SEL finishedSelector = @selector(viewController:finishedWithAuth:error:);
    GTMOAuth2ViewControllerTouch *authViewController =
    [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
                                               clientID:kClientID
                                           clientSecret:kClientSecret
                                       keychainItemName:kKeychainItemName
                                               delegate:self
                                       finishedSelector:finishedSelector];
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"en"
                                                       forKey:@"hl"];
    authViewController.signIn.additionalAuthorizationParameters=params;
    [self presentViewController:authViewController animated:YES completion:nil];
    
    
    
}

// This method will be call after logged in
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth: (GTMOAuth2Authentication *)auth error:(NSError *)error
{
    NSLog(@"viewController:finishedWithAuth:error:");
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (error == nil)
    {
        [self isAuthorizedWithAuthentication:auth];
        [self checkAuthorize];
    }else{
        SHOW_ALERT(@"CCNV", @"Google Drive Login failed", nil, @"OK", nil, nil);
        [self checkForAuthorization];
    }
}
- (void)awakeFromNib {
}
/*
- (void)awakeFromNib {
    // Get the saved authentication, if any, from the keychain.
    if (self.navigationController.viewControllers.count==1) {
        GTMOAuth2Authentication *auth;
        auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                     clientID:kClientID
                                                                 clientSecret:kClientSecret];
        // Retain the authentication object, which holds the auth tokens
        //
        // We can determine later if the auth object contains an access token
        // by calling its -canAuthorize method
        // [[NSUserDefaults standardUserDefaults]setValue:auth.accessToken forKey:@"TOKEN"];
        // [[NSUserDefaults standardUserDefaults]synchronize];
        NSLog(@"AccessToken**%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"TOKEN"]);
        [self isAuthorizedWithAuthentication:auth];
        
    }
}
 */


// If everthing is fine then initialize driveServices with auth


- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth
{
    NSLog(@"isAuthorizedWithAuthentication:");
    
    [[self driveService] setAuthorizer:auth];
    //NSLog(@"AccessToken%@",auth.accessToken);
    
    if (auth.accessToken) {
        [[NSUserDefaults standardUserDefaults]setValue:auth.accessToken forKey:@"TOKEN"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }

    // and finally here you can load all files
    //NSLog(@"IDD,,%@",_controllerDriveFile.identifier);
   _checkRoot?[self loadDriveFiles:@"root"]:[self loadDriveFiles:_controllerDriveFile.identifier];
;
}

- (GTLServiceDrive *)driveService
{
    NSLog(@"driveService");
    
    static GTLServiceDrive *service = nil;
    
    if (!service)
    {
        service = [[GTLServiceDrive alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    }
    
    return service;
}

-(BOOL)isAuthorized
{
    GTMOAuth2Authentication *auth =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:kClientSecret];
    BOOL check =[auth canAuthorize]?YES:NO;
    return check;
    
}


// Method for loading all files from Google Drive
#pragma mark -Loading All files Specific Folder

-(void)loadDriveFiles:(NSString *)folderId
{
    NSLog(@"loadDriveFileswithFileId%@",folderId);
    tableArray=[[NSMutableArray alloc]init];
    
    UIAlertView *alert =
    [self showWaitIndicator:@"Loading files"];
    [GoogleDriveManager getSubFolderFileList:self.driveService ServiceTicket:ticketService folderId:folderId :^(BOOL success, NSMutableArray *array, NSError *error) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        if (success) {
            tableArray=[array mutableCopy];
            NSLog(@"Array Count%d",tableArray.count);
            ticketService=nil;
        }else{
            [self showAlert:@"Error" message:[error localizedDescription]];
        }
        [self.fileTableView reloadData];
        [self sortBasedOnTitle];
        

    }];
  }
#pragma mark -UITableview Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableArray count];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *sectionArray=tableArray[section];
    return sectionArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSString *simpleTableIdentifier =isIpad?@"filecellipad":@"fileCell";
    
    fillCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[fillCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.driveFile=(GTLDriveFile *)tableArray[indexPath.section][indexPath.row];
    cell.layer.borderWidth=1.0f;
    cell.layer.borderColor=[UIColor lightGrayColor].CGColor;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 59;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self didSelectForTableAndCollectionWithIndexPath:indexPath];
    
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [tableArray count];
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [tableArray count]==1?[self checkFileOrFolder:tableArray[0][0]]:section==0?@"Folder":@"Files";
}
#pragma mark -UICollectionView Delegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSMutableArray *sectionArray=tableArray[section];
    return sectionArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"fileCollection";
    fileCollectionCell *cell = [collectionView
                                dequeueReusableCellWithReuseIdentifier:simpleTableIdentifier
                                forIndexPath:indexPath];
    cell.driveFile=(GTLDriveFile *)tableArray[indexPath.section][indexPath.row];
    cell.layer.borderWidth=1.0f;
    cell.layer.borderColor=[UIColor lightGrayColor].CGColor;
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        
        collectionHeader *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionHeaderId" forIndexPath:indexPath];
        reusableview.HeaderLabel.text=indexPath.section==0?@"Folder":@"Files";
        reusableview.layer.borderWidth=1.0f;
        reusableview.layer.borderColor=[UIColor lightGrayColor].CGColor;
        return reusableview;
    }
    return nil;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self didSelectForTableAndCollectionWithIndexPath:indexPath];
}

#pragma mark - Did select for both collection and tableview

-(void)didSelectForTableAndCollectionWithIndexPath:(NSIndexPath *)indexPath
{
    GTLDriveFile *selectedDriveFile=(GTLDriveFile *)tableArray[indexPath.section][indexPath.row];
    NSLog(@"SLECted%@",selectedDriveFile);

    
    if ([selectedDriveFile.mimeType rangeOfString:@"application/vnd.google-apps.folder"].location != NSNotFound)
    {
        GoogleDriveContentListingViewController *googleDriveListViewController =[[GoogleDriveContentListingViewController alloc]initWithNibName:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ?@"GoogleDriveContentListingViewController_iPad" :@"GoogleDriveContentListingViewController" bundle:nil];
        googleDriveListViewController.controllerDriveFile=selectedDriveFile;
        [self.navigationController pushViewController:googleDriveListViewController animated:YES];
    }
    else if([selectedDriveFile.mimeType rangeOfString:@"image/"].location != NSNotFound)
    {
        didSelectedDriveFile=selectedDriveFile;
        tableArray.count==1?[[self checkFileOrFolder:tableArray[0][0]]isEqualToString:@"Folder"]?nil:[self createPhotoArrayForPhotoBrowser:[self checkImageFiles:tableArray[0]]]:[self createPhotoArrayForPhotoBrowser:[self checkImageFiles:tableArray[1]]];
        [self setPhotoViewer];
    }
    else if([selectedDriveFile.mimeType rangeOfString:@"video/"].location != NSNotFound){
        
        [self fileOpenInFileViewer:selectedDriveFile];
    }
    else if ([selectedDriveFile.mimeType  isEqualToString:@"application/pdf"]||[selectedDriveFile.mimeType  isEqualToString:@"application/msword"]||[selectedDriveFile.mimeType isEqualToString:@"application/vnd.ms-excel"]||[selectedDriveFile.mimeType  isEqualToString:@"application/vnd.ms-powerpoint"]||[selectedDriveFile.mimeType  isEqualToString:@"application/vnd.openxmlformats-officedocument.wordprocessingml.document"]||[selectedDriveFile.mimeType isEqualToString:@"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"]||[selectedDriveFile.mimeType isEqualToString:@"text/plain"])
    {
        [self fileOpenInFileViewer:selectedDriveFile];    }
    else if([selectedDriveFile.mimeType rangeOfString:@"audio/"].location != NSNotFound){
        
        MusicPlayerViewController *musicPlayerViewController=[[MusicPlayerViewController alloc]initWithNibName:isIpad?@"MusicPlayerViewController":@"MusicPlayerViewController_iPhone" bundle:nil];
        musicPlayerViewController.driveFile=selectedDriveFile;
        [self.navigationController pushViewController:musicPlayerViewController animated:YES];
    }
    else
    {
        [[[UIAlertView alloc]initWithTitle:nil message:@"Unable to open file" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil]show];
    }
}
#pragma mark -Create Photo Array
-(NSMutableArray *)checkImageFiles:(NSMutableArray *)arrayFiles
{
    NSMutableArray *imageArray=[NSMutableArray new];
    [arrayFiles enumerateObjectsUsingBlock:^(GTLDriveFile *obj, NSUInteger idx, BOOL *stop) {
        [obj.mimeType rangeOfString:@"image/"].location != NSNotFound?[imageArray addObject:obj]:nil;
    }];
    NSLog(@"COUNTTARRAY%d",imageArray.count);
//    imageSelectedIndex=[imageArray indexOfObject:didSelectedDriveFile];
//    [photoBrowsePhotoArray removeAllObjects];
//    [imageArray enumerateObjectsUsingBlock:^(GTLDriveFile *obj, NSUInteger idx, BOOL *stop) {
//        NSString *stringUrl=[NSString stringWithFormat:@"%@&access_token=%@",obj.downloadUrl,driverManager.accessTokenValue];
//        NSLog(@"IMgeString %@",stringUrl);
//        [photoBrowsePhotoArray addObject:[MWPhoto photoWithImageDriverFile:obj]]; //photoWithURL:[NSURL URLWithString:stringUrl] checkalue:NO]];
//    }];
    return imageArray;
    
}
-(void)createPhotoArrayForPhotoBrowser:(NSMutableArray *)imageArray{
    imageSelectedIndex=[imageArray indexOfObject:didSelectedDriveFile];
    [photoBrowsePhotoArray removeAllObjects];
    [imageArray enumerateObjectsUsingBlock:^(GTLDriveFile *obj, NSUInteger idx, BOOL *stop) {
        //NSString *stringUrl=[NSString stringWithFormat:@"%@&access_token=%@",obj.downloadUrl,driverManager.accessTokenValue];
       // NSLog(@"IMgeString %@",stringUrl);
        [photoBrowsePhotoArray addObject:[MWPhoto photoWithImageDriverFile:obj thumbNail:NO]]; //photoWithURL:[NSURL URLWithString:stringUrl] checkalue:NO]];
    }];

}
#pragma mark - Open file in FileViewController
-(void)fileOpenInFileViewer:(GTLDriveFile *)file{
    
    FileViewViewController *fileViewController=[[FileViewViewController alloc]initWithNibName:isIpad?@"FileViewViewController_iPad":@"FileViewViewController" bundle:nil];
    fileViewController.driveFile=file;
    fileViewController.driveService=_driveService;
    [self.navigationController pushViewController:fileViewController animated:YES];
    
}

#pragma mark -Create PhotoViewer

-(void)setPhotoViewer
{
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    // browser.wantsFullScreenLayout = YES; // iOS 5 & 6 only: Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
    [browser setCurrentPhotoIndex:imageSelectedIndex];
    // Optionally set the current visible photo before displaying
    
    // Present
    [self.navigationController pushViewController:browser animated:YES];
    
    // Manipulate
    
    
}
-(NSString *)checkFileOrFolder:(GTLDriveFile *)files
{
    NSString *fileType=[files.mimeType isEqualToString:@"application/vnd.google-apps.folder"] ?@"Folder":@"Files";
    return fileType;
}
#pragma mark -Custom Alert
- (UIAlertView*)showWaitIndicator:(NSString *)title
{
    UIAlertView *progressAlert;
    progressAlert = [[UIAlertView alloc] initWithTitle:title
                                               message:@"Please wait..."
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil];
    [progressAlert show];
    UIActivityIndicatorView *activityView;
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.center = CGPointMake(progressAlert.bounds.size.width / 2,
                                      progressAlert.bounds.size.height - 45);
    [progressAlert addSubview:activityView];
    [activityView startAnimating];
    return progressAlert;
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle: title
                                       message: message
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
    [alert show];
}
#pragma mark -Navigation Barbutton Item Action
- (IBAction)sigInButton:(UIBarButtonItem *)sender {
    if (!self.isAuthorized) {
        // Sign in.
        [self checkForAuthorization];
    } else {
        // Sign out
        [ticketService cancelTicket];
        ticketService=Nil;
        [self.driveService.delegateQueue cancelAllOperations];
        [self.driveService.parseQueue cancelAllOperations];
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
        [[self driveService] setAuthorizer:nil];
        [sender setTitle:@"Sign in"];
        [tableArray removeAllObjects];
        [self.fileTableView reloadData];
        [self.fileCollectionView reloadData];
        checkTable=YES;
        self.fileCollectionView.hidden=YES;
        self.fileTableView.hidden=NO;
    }
    
}
#pragma mark - Segmented Control Action
- (IBAction)segmentedControllerAction:(UISegmentedControl *)segment {
    if(_segmentedControl.selectedSegmentIndex==0)
    {
        [self sortBasedOnTitle];
    }
    else if(_segmentedControl.selectedSegmentIndex==1)
    {
        [segment setTitle:@"Title" forSegmentAtIndex:0];
        [segment setTitle:@"Date" forSegmentAtIndex:2];
        if(![[segment titleForSegmentAtIndex:segment.selectedSegmentIndex] isEqualToString:@"Size ▲"]) {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fileSize"
                                                                           ascending:YES];
            
            // sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"size" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            [self sortArrayWithDescriptor:sortDescriptors];
            [segment setTitle:@"Size ▲" forSegmentAtIndex:segment.selectedSegmentIndex];
            
        }
        else {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fileSize"
                                                                           ascending:NO];
            
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            [self sortArrayWithDescriptor:sortDescriptors];
            [segment setTitle:@"Size ▼" forSegmentAtIndex:segment.selectedSegmentIndex];
        }
    }
    else if(_segmentedControl.selectedSegmentIndex==2)
    {
        [segment setTitle:@"Title" forSegmentAtIndex:0];
        [segment setTitle:@"Size" forSegmentAtIndex:1];

        if(![[segment titleForSegmentAtIndex:segment.selectedSegmentIndex] isEqualToString:@"Date ▲"]) {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate.date"
                                                                           ascending:YES];
            
            sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"createdDate.date" ascending:YES selector:@selector(compare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            [self sortArrayWithDescriptor:sortDescriptors];
            [segment setTitle:@"Date ▲" forSegmentAtIndex:segment.selectedSegmentIndex];
        }
        else {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate.date"
                                                                           ascending:NO];
            sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"createdDate.date" ascending:NO selector:@selector(compare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            [self sortArrayWithDescriptor:sortDescriptors];
            [segment setTitle:@"Date ▼" forSegmentAtIndex:segment.selectedSegmentIndex];
        }
    }
    
}
-(void)sortBasedOnTitle{
    [_segmentedControl setTitle:@"Size" forSegmentAtIndex:1];
    [_segmentedControl setTitle:@"Date" forSegmentAtIndex:2];
    
    if(![[_segmentedControl titleForSegmentAtIndex:0] isEqualToString:@"Title ▲"]) {
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title"
                                                                       ascending:YES];
        
        sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        // arrContentList =(NSMutableArray *)[arrContentList sortedArrayUsingDescriptors:sortDescriptors];
        [self sortArrayWithDescriptor:sortDescriptors];
        [_segmentedControl setTitle:@"Title ▲" forSegmentAtIndex:0];
    }
    else {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title"
                                                                       ascending:NO];
        
        sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO selector:@selector(caseInsensitiveCompare:)];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [self sortArrayWithDescriptor:sortDescriptors];
        [_segmentedControl setTitle:@"Title ▼" forSegmentAtIndex:0];
    }

}
#pragma mark -Sort With Description
-(void)sortArrayWithDescriptor:(NSArray *)arrayDescription
{
    if (tableArray.count==1) {
        tableArray[0]=(NSMutableArray *)[tableArray[0] sortedArrayUsingDescriptors:arrayDescription];
        
        
    }else{
        tableArray[0]=(NSMutableArray *)[tableArray[0] sortedArrayUsingDescriptors:arrayDescription];
        tableArray[1]=(NSMutableArray *)[tableArray[1] sortedArrayUsingDescriptors:arrayDescription];
        
    }
    [self.fileCollectionView reloadData];
    [self.fileTableView reloadData];
    
}


#pragma mark-Bottom Tool Bar Action

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)settingButtonAction:(id)sender {
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
- (IBAction)homeButtonAction:(id)sender {
    [self.navigationController popToViewController:self.navigationController.viewControllers[2] animated:YES];
}
- (IBAction)showViewButtonAction:(id)sender {
    UIActionSheet *viewSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Calendar View",@"Grid View",@"List View", nil];
    
    viewSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [viewSheet showInView:self.view];
}
#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Button index,,%d",buttonIndex);
    switch (buttonIndex) {
        case 0:
            [self showCalendarView];
            break;
        case 1:
            [self viewChangeToCollectionView];

            break;
        case 2:
            [self viewChangeToTableView];

            break;
        case 3:
            break;
        default:
            break;
    }
}
#pragma mark - Switch tableView and CollectionView

-(void)viewChangeToTableView
{
    self.fileCollectionView.hidden=YES;
    self.fileTableView.hidden=NO;
    [self.fileTableView reloadData];
    checkTable=YES;
    [self replaceView:self.fileCollectionView withView:self.fileTableView];
}
-(void)viewChangeToCollectionView
{
    self.fileTableView.hidden=YES;
    self.fileCollectionView.hidden=NO;
    [self.fileCollectionView reloadData];
    checkTable=NO;
    [self replaceView:self.fileTableView withView:self.fileCollectionView];
}
#pragma mark -ViewChange Animation
- (void) replaceView: (UIView *) currentView withView: (UIView *) newView
{
    newView.alpha = 0.0;
    
    [UIView animateWithDuration: 1.0
                     animations:^{
                         currentView.alpha = 0.0;
                         newView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
}
#pragma mark-MWPhotobrowser Delegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return photoBrowsePhotoArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < photoBrowsePhotoArray.count)
        return [photoBrowsePhotoArray objectAtIndex:index];
    return nil;
}
#pragma Mark Calendar view

- (void)showCalendarView
{
    /*
    self.calendarViewController = [[CALAgendaViewController alloc]init];
    self.calendarViewController.view.frame=self.view.bounds;

    self.calendarViewController.agendaDelegate = self;
    NSDate *now = [[NSDate gregorianCalendar] dateFromComponents:[[NSDate gregorianCalendar]  components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[NSDate date]]];
    NSDateComponents *components = [NSDateComponents new];
    components.month = -3;
    NSDate *fromDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    components.month = 6;
    NSDate* toDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    [self.calendarViewController setFromDate:fromDate];
    [self.calendarViewController setToDate:toDate];
    
    self.calendarViewController.dayStyle = CALDayCollectionViewCellDayUIStyleCustom1;
    [self.navigationController pushViewController:self.calendarViewController animated:YES];
     
     */
    tableArray.count==1?[[self checkFileOrFolder:tableArray[0][0]]isEqualToString:@"Folder"]?nil:[self checkImageFiles:tableArray[0]]:[self checkImageFiles:tableArray[1]];

    TSQTAViewController *gregorian = [[TSQTAViewController alloc] init];
    gregorian.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorian.arrayWithImages=tableArray.count==1?[[self checkFileOrFolder:tableArray[0][0]]isEqualToString:@"Folder"]?nil:[self checkImageFiles:tableArray[0]]:[self checkImageFiles:tableArray[1]];
    gregorian.calendar.locale = [NSLocale currentLocale];
    [self.navigationController pushViewController:gregorian animated:YES];

}


@end


