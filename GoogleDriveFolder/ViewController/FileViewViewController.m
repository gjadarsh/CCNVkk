//
//  FileViewViewController.m
//  CCNV
//
//  Created by Project Development Department on 2014/04/09.
//
//

#import "FileViewViewController.h"
#import "GoogleDriveManager.h"
#import "ReaderDocument.h"
#import "ReaderViewController.h"
#import "SampleViewController.h"
#import <QuickLook/QuickLook.h>
@interface FileViewViewController ()<ReaderViewControllerDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *fileViewWebView;
@property (nonatomic,strong)MPMoviePlayerController *moviePlayer;

@end

@implementation FileViewViewController
{
    NSString *filePathDownloaded;
    GTMHTTPFetcher *fileFetcher;
}

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
    [super viewDidLoad];
    [self downloadFileContent];
    // Do any additional setup after loading the view from its nib.
   
}
-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerDidExitFullscreenNotification
                                                  object:nil];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -View Content Download

-(void)downloadFileContent
{
    NSLog(@"SERVice%@,,,,,%@",_driveService,_driveService.fetcherService);

    UIAlertView *alert =
    [self showWaitIndicator:@"Downloading.."];
    alert.delegate=self;
        [GoogleDriveManager downloadFileContentWithFile:self.driveFile completionBlock:^(NSData *downloaded, NSError *error) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        
        if (!error) {
            NSLog(@"Success");
           // [_driveFile.mimeType  isEqualToString:@"application/pdf"] || [_driveFile.mimeType rangeOfString:@"video/"].location != NSNotFound?[self writeFileToDocumentDirectory:downloaded]:[self writeFileToDocumentDirectory:downloaded];
            [self writeFileToDocumentDirectory:downloaded];
            
        }else{
            [self showAlert:@"Error" message:[error localizedDescription]];
            
        }

    } progressBlock:^(NSData *reciveData, GTMHTTPFetcher *fetcher) {
        NSString *messageString=[NSString stringWithFormat:@"%.f%%Downloaded",(100.0 / [self.driveFile.fileSize longLongValue] * [reciveData length])];
        alert.message=messageString;
    }];

}
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%d",buttonIndex) ;
    if (buttonIndex == 0){
        //cancel clicked ...do your action
        [fileFetcher stopFetching];
        fileFetcher=nil;
        [self removeFileFromDocumentDirectory];
        [self.navigationController popViewControllerAnimated:NO];
    }
}


#pragma mark -Custom Alert
- (UIAlertView*)showWaitIndicator:(NSString *)title
{
    UIAlertView *progressAlert;
    progressAlert = [[UIAlertView alloc] initWithTitle:title
                                               message:@"Please wait..."
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"Cancel",nil];
    UIActivityIndicatorView *activityView;
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.center = CGPointMake(progressAlert.bounds.size.width / 2,
                                      progressAlert.bounds.size.height - 45);
    [progressAlert addSubview:activityView];
    [activityView startAnimating];
    [progressAlert show];
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
#pragma mark - Webview Content Show
-(void)contentShowInWebView
{
    NSString *stringUrl=[NSString stringWithFormat:@"%@&access_token=%@",_driveFile.downloadUrl,[[NSUserDefaults standardUserDefaults]objectForKey:@"TOKEN"]];
    NSURL *viewUrl =[NSURL URLWithString:stringUrl] ;
    NSURLRequest *requestURL =[NSURLRequest requestWithURL:viewUrl];
    _fileViewWebView.scalesPageToFit = YES;
    _fileViewWebView.autoresizesSubviews = YES;
    [_fileViewWebView loadRequest:requestURL];
}
#pragma mark Pdf ReaderViewController Set
-(void)presentPdfViewWithFilePath:(NSString *)pdfFilePath{
    ReaderDocument *document =[[ReaderDocument alloc]initWithFilePath:pdfFilePath password:nil];;

if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
{
    ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
    readerViewController.delegate = self; // Set the ReaderViewController delegate to self
    //  [self.navigationController pushViewController:readerViewController animated:YES];
    //#else // present in a modal view controller
    readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:readerViewController animated:YES completion:NULL];
    
}
}

#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
	[self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popViewControllerAnimated:NO];
    
}

#pragma mark -Write Data Into document directory
-(void)writeFileToDocumentDirectory:(NSData *)content{
    filePathDownloaded=[self getDocumentDirectoryPath];

    if(content)
    [content writeToFile:filePathDownloaded atomically:YES];
    [_driveFile.mimeType  isEqualToString:@"application/pdf"]?[self presentPdfViewWithFilePath:filePathDownloaded]:[_driveFile.mimeType rangeOfString:@"video/"].location != NSNotFound?[self showVideoPlayerFilepath:filePathDownloaded]:[self quickView];

}

#pragma mark-Remove Data In document directory
-(void)removeFileFromDocumentDirectory{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isMyFileThere = [[NSFileManager defaultManager] fileExistsAtPath:filePathDownloaded];
    if(isMyFileThere){
        
        [fileManager removeItemAtPath:filePathDownloaded error:NULL];
    }
}
-(NSString *)getDocumentDirectoryPath
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[paths objectAtIndex:0];
    // NSString *fileExtention=[_driveFile.mimeType  isEqualToString:@"application/pdf"]?@"pdf":[_driveFile.mimeType rangeOfString:@"video/"].location != NSNotFound?@"mov":@"docx";
    NSString *finalPath=[documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.%@",_driveFile.identifier,_driveFile.fileExtension]];
    //check your path correctly and provide your name dynamically
    NSLog(@"finalpath--%@",finalPath);
    return finalPath;
}

#pragma mark VideoPlayer
-(void)showVideoPlayerFilepath:(NSString *)videoFilePath
{
    NSURL *url = [NSURL fileURLWithPath:videoFilePath];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerDidExitFullscreen:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(moviePlayBackDidFinish:)
                                                name:MPMoviePlayerPlaybackDidFinishNotification
                                              object:nil];
   _moviePlayer=[[MPMoviePlayerController alloc]initWithContentURL:url];
    [_moviePlayer.view setFrame:CGRectMake(20, 100, 380, 150)];
    [self.view addSubview:_moviePlayer.view];

    _moviePlayer.fullscreen=YES;
    _moviePlayer.allowsAirPlay=YES;
    _moviePlayer.shouldAutoplay=YES;
    _moviePlayer.controlStyle=MPMovieControlStyleEmbedded;
}
- (void)MPMoviePlayerDidExitFullscreen:(NSNotification *)notification
{
       [_moviePlayer stop];
    [_moviePlayer.view removeFromSuperview];
    [self.navigationController popViewControllerAnimated:NO];

}
- (void) moviePlayBackDidFinish:(NSNotification*)notification {
   // MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:nil];
    [_moviePlayer play];
    [_moviePlayer pause];

   // [_moviePlayer prepareToPlay];
  }
#pragma mark -Show QLPreviewController

// we can view  .doc,.docx,.xsl,.text,..etc
-(void)quickView
{
//    QLPreviewController *previewController = [[QLPreviewController alloc] init];
//    previewController.dataSource = self;
//    previewController.delegate = self;
//    previewController.currentPreviewItemIndex=0;
//    previewController.title=@"xx";
//    // start previewing the document at the current section index
//    [self.navigationController presentViewController:previewController animated:NO completion:nil];
    SampleViewController *previewController = [[SampleViewController alloc] init];
    previewController.dataSource = self;
    previewController.delegate = self;
    previewController.currentPreviewItemIndex=0;
    previewController.title=@"xx";
    // start previewing the document at the current section index
    [self.navigationController presentViewController:previewController animated:NO completion:nil];


}
#pragma mark -QLPreviewController data source
//Data source methods
//– numberOfPreviewItemsInPreviewController:
//– previewController:previewItemAtIndex:
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    
    
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    
    return [NSURL fileURLWithPath:filePathDownloaded];
}

#pragma mark -QLPreviewController delegate methods


- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item
{
    
    return YES;
}
- (void)previewControllerDidDismiss:(QLPreviewController *)controller{
    [self.navigationController popViewControllerAnimated:NO];}

@end
