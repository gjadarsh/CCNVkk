//
//  WorkSpaceCell.m
//  CCNV
//
//  Created by  Linksware Inc. on 9/28/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import "WorkSpaceCell.h"
#import "File.h"
#import "AppDelegate.h"
#import <ImageIO/ImageIO.h>
@implementation WorkSpaceCell
@synthesize arrContentListCount;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
/*
-(void)loadExifInfo :(NSString *)path{
 
 //   NSString *myPath = [[NSBundle mainBundle] pathForResource:@"IMG_2733" ofType:@"JPG"];
    NSURL *myURL = [NSURL URLWithString:path];
    CGImageSourceRef mySourceRef = CGImageSourceCreateWithURL((CFURLRef)CFBridgingRetain(myURL), NULL);
   //  CGImageSourceRef mySourceRef=cg
    NSDictionary *myMetadata = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(mySourceRef,0,NULL));
    NSDictionary *exifDic = [myMetadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
    NSDictionary *tiffDic = [myMetadata objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
    NSLog(@"exifDic properties: %@", myMetadata); //all data
    float rawShutterSpeed = [[exifDic objectForKey:(NSString *)kCGImagePropertyExifExposureTime] floatValue];
    int decShutterSpeed = (1 / rawShutterSpeed);
    NSLog(@"Camera %@",[tiffDic objectForKey:(NSString *)kCGImagePropertyTIFFModel]);
    NSLog(@"Focal Length %@mm",[exifDic objectForKey:(NSString *)kCGImagePropertyExifFocalLength]);
    NSLog(@"Shutter Speed %@", [NSString stringWithFormat:@"1/%d", decShutterSpeed]);
    NSLog(@"Aperture f/%@",[exifDic objectForKey:(NSString *)kCGImagePropertyExifFNumber]);
    NSNumber *ExifISOSpeed  = [[exifDic objectForKey:(NSString*)kCGImagePropertyExifISOSpeedRatings] objectAtIndex:0];
    NSLog(@"ISO %i",[ExifISOSpeed integerValue]);
    NSLog(@"Taken %@",[exifDic objectForKey:(NSString*)kCGImagePropertyExifDateTimeDigitized]);
}
*/
 
/**
 * this method set all value and icon in cell variables .
 * and call method to load info , if info is not loaded yet.
 */
- (void) fillCellWithObject:(File*)fileObj {
    file = fileObj;
    lblTitle.text = file.strDisplayName;
    NSArray *arr=[file.strMediaType componentsSeparatedByString:@"/"];
    NSString *strExtention=[arr objectAtIndex:0];
 
    //set icon as per file type 
    if([strExtention isEqualToString:@"folder"]||[strExtention isEqualToString:@"syncFolder"])
    {
        infoCount++;
        fileTypeImage.image=[UIImage imageNamed:@"folder.png"];
        isFolder = TRUE;
    }
    else if([file.strMediaType isEqualToString:@"application/pdf"])
    {
        fileTypeImage.image=[UIImage imageNamed:@"pdf.png"];
    }
    else if([strExtention isEqualToString:@"text"])
    {
        fileTypeImage.image=[UIImage imageNamed:@"txt.png"];
    }
    else if([strExtention isEqualToString:@"image"])
    {
        fileTypeImage.image=[UIImage imageNamed:@"imgIcon.png"];
    }
    else if([strExtention isEqualToString:@"audio"])
    {
        fileTypeImage.image=[UIImage imageNamed:@"audio.png"];
    } 
    else if([strExtention isEqualToString:@"video"]) 
    {
        fileTypeImage.image=[UIImage imageNamed:@"video.png"];
    }
    else if([file.strMediaType isEqualToString:@"application/msword"]||[file.strMediaType  isEqualToString:@"application/vnd.openxmlformats-officedocument.wordprocessingml.document"])
    {
        fileTypeImage.image=[UIImage imageNamed:@"Word.png"];
    }
    else if([file.strMediaType isEqualToString:@"application/vnd.ms-excel"])
    {
        fileTypeImage.image=[UIImage imageNamed:@"xls.png"];
    }
    else if([file.strMediaType isEqualToString:@"application/vnd.ms-powerpoint"])
    {
        fileTypeImage.image=[UIImage imageNamed:@"ppt.png"];
    }
    else{
      fileTypeImage.image=[UIImage imageNamed:@"brokenfile.png"];  
    }
    
    if (!file.isInfoLoaded) {
      
       //[self getFileInfo];        //load file info if info is not loaded
    }
    else {
        //set info 
        lblsize.text=[NSString stringWithFormat:@"%@" ,file.strSize];
        lblsize.hidden = FALSE;
        lbldateTime.text = [NSString stringWithFormat:@"Date: %@", file.strDateTime];
        lbldateTime.hidden = FALSE;
        
        lbldateTime.text=[NSString stringWithFormat:@"Date: %@" ,file.strDateTime];
    }

    //load thumbnail for video file or image file (not if already loaded before)
    if(fileObj.thumbnail && ([file.strMediaType isEqualToString:@"image/jpeg"] ||[file.strMediaType isEqualToString:@"image/jpg"]||[file.strMediaType isEqualToString:@"image/png"]))
    {
        fileTypeImage.image=fileObj.thumbnail;
    }
    else if(!fileObj.thumbnail && ([file.strMediaType isEqualToString:@"image/jpeg"] ||[file.strMediaType isEqualToString:@"image/jpg"])){
        [self loadThumbnail];
        
        //[file.strMediaType isEqualToString:@"image/jpeg,image/pjpeg"]
    }
    else if (fileObj.thumbnail &&[strExtention isEqualToString:@"video"]){
         fileTypeImage.image=fileObj.thumbnail;
    }
    else if(!fileObj.thumbnail && ([strExtention isEqualToString:@"video"])){
        [self loadThumbnail];
    }
    
    //load file owner info if its shared folder 
    if(![fileObj.strFileAuthor isEqualToString:@""]){
        [self LoadOwnerDetail];  
    }
}

/**
 * this will load shared folder owner 
 * it starts new connection method in background to load owner info 
 * and also update file object in (connectionDidFinishLoading) method.
 */
 
-(void)LoadOwnerDetail{
    
    if (!isFolder) {
        return;
    }
    
    //load file owner info if its shared folder
    NSString *urlString =[NSString stringWithFormat:@"%@",file.strFileAuthor];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    //NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"GET"];
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
         [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        Connection3 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        if(Connection3) {
        
            ResponseData3 = [[NSMutableData alloc] init];
        }
        else {
            //NSLog(@"Error, Invalid Request");
        }
    }
}

/**
 * this method load thumbnail image for image file and movie file object in background thread
 * it starts new connection to load thumbnail of file , and update object in (connectionDidFinishLoading) method
 */
-(void)loadThumbnail
{
    
    //load file thumbnail 
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
//    NSLog(@"Access token = %@",ApplicationDelegate.accessToken);
    [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setValue:@"image/jpeg; pxmax=140; pymax=140; sq=(1);r=(0)" forHTTPHeaderField:@"Accept"];
    [theRequest setHTTPMethod:@"GET"];
    
    if(ApplicationDelegate.connectionRequired){
      //  SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
         [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        Connection2 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if(Connection2) {
            
            ResponseData2 = [[NSMutableData alloc] init];
        }
    }
}

/**
 * this method load file object detail info in background thread
 * it starts new connection to load info of file , and update object in (connectionDidFinishLoading) method
 */
- (void) getFileInfo {
    
    if (isFolder) {
        return;
    }
    
    //load file file info if its shared folder
    NSString *urlString =[NSString stringWithFormat:@"%@",file.ref];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    //NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"GET"];
    
    if(ApplicationDelegate.connectionRequired){
      //  SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
         [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
        Connection1 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        if(Connection1) {
            
            ResponseData1 = [[NSMutableData alloc] init];
        }
        else {
            //NSLog(@"Error, Invalid Request");
        }
    }
}

#pragma mark - HTTP connection methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
  //  [[[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    if (connection == Connection1){
        ResponseData1 = nil;  }
    else  if (connection == Connection2){
        ResponseData2 = nil;}
    else  if (connection == Connection3){
        ResponseData3 = nil;}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == Connection1){
        [ResponseData1 setLength:0];
     //   NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
     //   NSDictionary* headers = [httpResponse allHeaderFields];
        //NSLog(@"Header Response = %@",headers);
    }
    else if (connection == Connection2){
        [ResponseData2 setLength:0];
        //NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
       // NSDictionary* headers = [httpResponse allHeaderFields];
        //NSLog(@"Header Response = %@",headers);
    }
    else if (connection == Connection3){
        [ResponseData3 setLength:0];
       // NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
       // NSDictionary* headers = [httpResponse allHeaderFields];
        //NSLog(@"Header Response = %@",headers);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == Connection1){
        [ResponseData1 appendData:data];}
    else if (connection == Connection2){
        [ResponseData2 appendData:data];}
    else if (connection == Connection3){
        [ResponseData3 appendData:data];}
   
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    if (connection == Connection1) {  ///file info responce 
       
        NSString *responsestring= [[NSString alloc] initWithData:ResponseData1 encoding:NSUTF8StringEncoding];
//        NSLog(@"responsestring = %@",responsestring);
        
        NSString *start = @"<size>";
        NSRange starting = [responsestring rangeOfString:start];
        if(starting.location != NSNotFound){
            /////////////size formatting///////////////////////////////////////
            NSString *end = @"</size>";
            NSRange ending = [responsestring rangeOfString:end];
            NSString *str = [responsestring substringWithRange:NSMakeRange(starting.location + starting.length, ending.location - (starting.location + starting.length))];
            file.size=[str intValue];
            file.strSize=[self ChangeStringSize:str];//[self size:str];//adarsh
            lblsize.text=[NSString stringWithFormat:@"%@" ,file.strSize];
            lblsize.hidden = FALSE;      
           
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
                lbldateTime.text=[NSString stringWithFormat:@"Date: %@" ,file.strDateTime];
                lbldateTime.hidden = FALSE;

//                NSLog(@"is Grid View Active=%i",isGridViewActive);
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
               // lbldateTime.text=[NSString stringWithFormat:@"Date: %@" ,file.strLastModified];
                lbldateTime.hidden = FALSE;

            }
            
            file.isInfoLoaded = TRUE;
           // NSLog(@"i = %d",i);
           // NSLog(@"arrContentListCount = %d",arrContentListCount);
        }
    }
    
    else if(connection == Connection2) //thumbnail data 
    {
        infoCount++;
        UIImage *image1=[UIImage imageWithData:ResponseData2];
        [fileTypeImage setImage:image1];
        file.thumbnail=image1;
        
      //  NSData* jpegData =  UIImageJPEGRepresentation(file.thumbnail, 0.8);
//        EXFJpeg* jpegScanner = [[EXFJpeg alloc] init];
//        [jpegScanner scanImageData: jpegData];
//        EXFMetaData* exifData = jpegScanner.exifMetaData;
//        EXFJFIF* jfif = jpegScanner.jfif;
        
       // EXFTag* tagDefinition = [exifData tagDefinition: [NSNumber numberWithInt:EXIF_DateTime]];
        //EXFTag* latitudeDef = [exifData tagDefinition: [NSNumber numberWithInt:EXIF_GPSLatitude]];
        //EXFTag* longitudeDef = [exifData tagDefinition: [NSNumber numberWithInt:EXIF_GPSLongitude]];
       // id latitudeValue = [exifData tagValue:[NSNumber numberWithInt:EXIF_GPSLatitude]];
       // id longitudeValue = [exifData tagValue:[NSNumber numberWithInt:EXIF_GPSLongitude]];
     //   id datetime = [exifData tagValue:[NSNumber numberWithInt:EXIF_DateTime]];
       // id t = [exifData tagValue:[NSNumber numberWithInt:EXIF_Model]];
        
//        NSLog(@"date %@ ",datetime);
//        NSLog(@"%@ %@",file.thumbnail,NSStringFromCGSize(file.thumbnail.size));
    }
    else if(connection == Connection3){/// owner info of shared folder 
       
        NSString *responsestring= [[NSString alloc] initWithData:ResponseData3 encoding:NSUTF8StringEncoding];
//        NSLog(@"responsestring = %@",responsestring);

        NSString *str2,*str1;
        NSString *start1 = @"<firstName>";
        NSRange starting1 = [responsestring rangeOfString:start1];
        if(starting1.location != NSNotFound){
            NSString *end1 = @"</firstName>";
            NSRange ending1 = [responsestring rangeOfString:end1];
         str1 = [responsestring substringWithRange:NSMakeRange(starting1.location + starting1.length, ending1.location - (starting1.location + starting1.length))];
        }
        
        NSString *start2 = @"<lastName>";
        NSRange starting2 = [responsestring rangeOfString:start2];
        if(starting2.location != NSNotFound){
            NSString *end2 = @"</lastName>";
            NSRange ending2 = [responsestring rangeOfString:end2];
            str2 = [responsestring substringWithRange:NSMakeRange(starting2.location + starting2.length, ending2.location - (starting2.location + starting2.length))];
            
        }
        file.strFileownerName=[NSString stringWithFormat:@"%@ %@ ",str1,str2];
        lblsize.frame=CGRectMake(lblsize.frame.origin.x, lblsize.frame.origin.y, 250, lblsize.frame.size.height);
        lblsize.text=[NSString stringWithFormat:@"owner : %@",file.strFileownerName];
        lblsize.hidden = FALSE;      
    }
}

/**
 * this method convert size of file from bytes  to kb,mb,gb
 * and return string value to set size variable.and also update file object in (connectionDidFinishLoading) method
 */

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


@end