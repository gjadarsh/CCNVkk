//
//  EditImageViewController.m
//  CCNV
//
//  Created by  Linksware Inc. on 12/21/2012.
//
//

#import "EditImageViewController.h"

@interface EditImageViewController ()

@end
CGSize ImageSize;
@implementation EditImageViewController
@synthesize img,fileobj,updatedImage,selectedURl,selectedImageName;
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
    //add img of file 
    img=[fileobj FullImage];
    
   // add UIBarButtonItem in navigation bar 
    UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done_clicked)];
    self.navigationItem.rightBarButtonItem = done;
    
    self.navigationItem.leftBarButtonItem=nil;
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(Cancel_clicked)];
    self.navigationItem.leftBarButtonItem = cancel;

    //get image size 
    ImageSize=img.size;
    
    ///set UItextField in Title View /////////////////////////

    txtTitle =[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [txtTitle setBackgroundColor:[UIColor whiteColor]];
    txtTitle.text=fileobj.strDisplayName;
    txtTitle.delegate=self;
    
    ///set UIlabel in Title View /////////////////////////

    lblTitle =[[UILabel alloc] initWithFrame:txtTitle.frame];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    lblTitle.text=fileobj.strDisplayName;
    lblTitle.textColor=[UIColor whiteColor];
    lblTitle.textAlignment=NSTextAlignmentCenter;
    
    self.navigationItem.titleView=lblTitle;

    //resixe image to fit to screen
    [self resize];
    
    //set image into imageview and set canvas frame
    [imageView setFrame:CGRectMake(0,0, img.size.width, img.size.height)];
    
    canvas=[[SmoothLineView alloc] initWithFrame:CGRectMake(0,0, img.size.width, img.size.height)];
    
  //  NSLog(@"%@",NSStringFromCGSize(img.size));
  //  NSLog(@"after %@",NSStringFromCGRect(imageView.frame));
  //  NSLog(@"after %@",NSStringFromCGRect(canvas.frame));
    
    [captureview setFrame:imageView.frame];
    [imageView setImage:img];
    
    canvas.center=imageView.center;
    [captureview addSubview:canvas];
    canvas.lineWidth = 3;
    
    [imageView setImage:img];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    [[UIApplication sharedApplication ] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * this method will go to previous controller and do not save any changes in image File .
 */
-(void)Cancel_clicked{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * this method will save changes in image File and then upload the new version of file to SugerSync server.
 */
-(void)done_clicked{
    //Screen capture for get update image
    CGSize rect = canvas.frame.size;
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(rect, YES, 1.0);
    } else {
        UIGraphicsBeginImageContext(rect);
    }
    
    //    UIGraphicsBeginImageContext(drawBox.size);
    [captureview.layer renderInContext:UIGraphicsGetCurrentContext()];
    updatedImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //update file version to sugersync 
    
    [self UploadFile];
}

/**
 * this method will change the navigation bar and maje name editable.
 */
-(IBAction)RenameClicked:(id)sender
{
    self.navigationItem.titleView=txtTitle;
    [txtTitle becomeFirstResponder];
    
}

#pragma mark - image resize
-(void)resize{
    
    //resize image
    
    if(isIpad){
        if ((img.size.height > img.size.width) & (img.size.height >captureview.frame.size.height)) {
            float height = captureview.frame.size.height;
            float width = (captureview.frame.size.width * img.size.width) / img.size.height;
            CGSize newSize = CGSizeMake(width, height);
            UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
            [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else if ((img.size.width > img.size.height) & (img.size.width > captureview.frame.size.width)) {
            float width = captureview.frame.size.width;
            float height = (captureview.frame.size.height * img.size.height) / img.size.width;
            CGSize newSize = CGSizeMake(width, height);
            UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
            [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else {
            float width = 700;
            float height = 700;
            CGSize newSize = CGSizeMake(width, height);
            UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
            [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    else{
        if ((img.size.height > img.size.width) & (img.size.height > captureview.frame.size.height)) {
            float height = captureview.frame.size.height;
            float width = (captureview.frame.size.width * img.size.width) / img.size.height;
            CGSize newSize = CGSizeMake(width, height);
            UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
            [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else if ((img.size.width > img.size.height) & (img.size.width > captureview.frame.size.width)) {
            float width = captureview.frame.size.width;
            float height = (captureview.frame.size.height * img.size.height) / img.size.width;
            CGSize newSize = CGSizeMake(width, height);
            UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
            [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else {
            float width = captureview.frame.size.width;
            float height =captureview.frame.size.height;
            CGSize newSize = CGSizeMake(width, height);
            UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
            [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
}

/**
 * this method will upload File data .
 
 */
-(UIImage *)resizeImage:(UIImage *)image Width:(float)Dwidht Height:(float)Dheight{
    if ((image.size.height > image.size.width) & (image.size.height > Dheight)) {
        float height = Dheight;
        float width = (Dheight * image.size.width) / image.size.height;
        CGSize newSize = CGSizeMake(width, height);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else if ((image.size.width > image.size.height) & (image.size.width > Dwidht)) {
        float width = Dwidht;
        float height = (Dwidht * image.size.height) / image.size.width;
        CGSize newSize = CGSizeMake(width, height);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else {
        float width = Dwidht;
        float height = Dheight;
        CGSize newSize = CGSizeMake(width, height);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

#pragma mark - UpdateFile
/**
 * this method will upload File data .
 * it starts new connection to upload file data or upload new version of file
 */
-(void)UploadFile
{
    [ApplicationDelegate.HUD setHidden:FALSE];
    
    //image size revert back to original size 
    UIImage *img11 = [self resizeImage:updatedImage Width:ImageSize.width  Height:ImageSize.height];
    NSData *data=UIImageJPEGRepresentation(img11, 1);
    
    //upload file version 
    NSString *urlString =[NSString stringWithFormat:@"%@",fileobj.filedata];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
   // NSLog(@"URL = %@",theURL);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    //NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"PUT"];
    
    [theRequest setHTTPBody:data];
    
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
         [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        NSURLConnection *Connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if(Connection) {
            
            ResponseData = [[NSMutableData alloc] init];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    lblTitle.text=txtTitle.text;
    self.navigationItem.titleView=lblTitle;
    
    [textField resignFirstResponder];
    return YES;
}

/**
 * this method will update File info .
 * it starts new connection to update file info like display name .
 */
-(void)UpdateFileInfo{
    
    //update file info
    
    NSString *strDisplayname=(__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                                   NULL,
                                                                                                   (__bridge_retained CFStringRef)txtTitle.text,
                                                                                                   NULL,
                                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                   kCFStringEncodingUTF8 );
    NSString *xmlString = [NSString stringWithFormat:
                           @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>                           <file><displayName>%@</displayName></file>",strDisplayname];
    
    NSData *thumbsupData = [xmlString dataUsingEncoding: NSASCIIStringEncoding];
    
    NSString *urlString =[NSString stringWithFormat:@"%@",fileobj.ref];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
  //  NSLog(@"URL = %@",xmlString);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"PUT"];
    [theRequest addValue:@"application/xml; charset=UTF-8" forHTTPHeaderField:@"Content-type"];
    [theRequest setHTTPBody:thumbsupData];
    
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
         [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        Connection3 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if(Connection3) {
            ResponseData3 = [[NSMutableData alloc] init];
        }
    
    }
}

/**
 * this method will return downloaded File path.
 *
 */
-(NSString*)GetFileUrl
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0],fileobj.strDisplayName];
    //NSLog(@"%@",path);
    return path;
}

/**
 * this method enable pencil tool.
 *
 */
-(IBAction)draw_clicked:(id)sender{
    canvas.isErase = FALSE;
}
/**
 * this method enable eraser tool.
 *
 */
-(IBAction)erase_clicked:(id)sender{
    canvas.isErase = TRUE;
}
#pragma mark - HTTP connection methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    if (connection==Connection3) {
        ResponseData3=nil;
    }
    else{
        ResponseData=nil;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection==Connection3) {
        [ResponseData3 setLength:0];
     //   NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
      //  NSDictionary* headers = [httpResponse allHeaderFields];
     //   NSLog(@"Headers = %@",headers);
        
    }
    else{
        [ResponseData setLength:0];
       // NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
      //  NSDictionary* headers = [httpResponse allHeaderFields];
      //  NSLog(@"Headers = %@",headers);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection==Connection3) {
        [ResponseData3 appendData:data];
    }
    else{
        [ResponseData appendData:data];
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (connection==Connection3) {
    }
    else{
        NSString *responsestring;
        
        responsestring= [[NSString alloc] initWithData:ResponseData encoding:NSUTF8StringEncoding];
        
        
        NSString *path=[self GetFileUrl]; //get file path and create temp file 
        [[NSFileManager defaultManager] createFileAtPath:path
                                                contents:ResponseData
                                              attributes:nil ];
        [ApplicationDelegate.HUD setHidden:TRUE];
      //  NSLog(@"responsestring = %@",responsestring);
        
        //update history table 
        NSString *strHistory=@"Image Edited";
        [ApplicationDelegate UpdateDatabase:strHistory];
        
        if(![txtTitle.text isEqualToString:fileobj.strDisplayName]){
            [self UpdateFileInfo]; // update file info if info is changed 
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UIInterfaceOrientation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft||toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        
        
    }
    else{
        txtTitle.frame=CGRectMake(0, 0, 80, 30);
        lblTitle.frame=CGRectMake(0, 0, 80, 30);
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        
        
    }
    else{
        txtTitle.frame=CGRectMake(0, 0, 80, 30);
        lblTitle.frame=CGRectMake(0, 0, 80, 30);
    }
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end