//
//  AsyncImageview.m
//  CCNV
//
//  Created by  Linksware Inc. on 1/16/2013.
//
//

#import "AsyncImageview.h"

@implementation AsyncImageview
@synthesize objFile;
-(id)init :(File *)file
{
//    objFile=file;
//    [self getFileInfo];
//    [self loadThumbnailImage];
    return self;
}

/**
 * this method load file object detail info in background thread
 * it starts new connection to load info of file , and update object in (connectionDidFinishLoading) method
 */
- (void) getFileInfo {
    NSArray *arr=[ self.objFile.strMediaType componentsSeparatedByString:@"/"];
    NSString *strExtention=[arr objectAtIndex:0];
    NSLog(@"%@", strExtention);
    if([strExtention isEqualToString:@"folder"]||[strExtention isEqualToString:@"syncFolder"]){
        
        return;
    }
    
    NSString *urlString =[NSString stringWithFormat:@"%@", self.objFile.ref];
    NSURL *theURL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    //NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setHTTPMethod:@"GET"];
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
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




/**
 * this method load thumbnail image for image file and movie file object in background thread
 * it starts new connection to load thumbnail of file , and update object in (connectionDidFinishLoading) method
 */
-(void)loadThumbnailImage:(File*)fileObj {
    self.objFile = fileObj;
    if (fileObj.thumbnail) {
        self.image = fileObj.thumbnail;
        [self setNeedsDisplay];
        return;
    }
    
    /////if thumbnail for file object is nil , start loading image
    
    NSString *urlString=[NSString stringWithFormat:@"%@", self.objFile.filedata];

    NSURL *theURL = [NSURL URLWithString:urlString];
    
    //NSLog(@"URL = %@",urlString);
   
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];

    //NSLog(@"Access token = %@",APP.accessToken);
    [theRequest setValue:APP.accessToken forHTTPHeaderField:@"Authorization"];
    [theRequest setValue:@"image/jpeg; pxmax=140; pymax=140; sq=(1);r=(0)" forHTTPHeaderField:@"Accept"];
    [theRequest setHTTPMethod:@"GET"];
    
    if(ApplicationDelegate.connectionRequired){
        SHOW_ALERT(@"", @"Please check your internet connection and Try Again.",nil, @"OK", nil);
         [ApplicationDelegate.HUD setHidden:TRUE];
    }else{
    Connection2 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if(Connection2) {
        
        ResponseData2 = [[NSMutableData alloc] init];
    }
    }
}

#pragma mark - HTTP connection methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    if (connection == Connection1){
        ResponseData1 = nil;  }
    else  if (connection == Connection2){
        ResponseData2 = nil;}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == Connection1){/// for loading file info 
        [ResponseData1 setLength:0];
      //  NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
      //  NSDictionary* headers = [httpResponse allHeaderFields];
        //NSLog(@"Header Response = %@",headers);
    }
    else if (connection == Connection2){ /////for image loading 
        [ResponseData2 setLength:0];
     //   NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
     //   NSDictionary* headers = [httpResponse allHeaderFields];
        //NSLog(@"Header Response = %@",headers);
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == Connection1){
        [ResponseData1 appendData:data];}
    else if (connection == Connection2){
        [ResponseData2 appendData:data];}
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    if (connection == Connection1) {/// for loading file info 
        NSString *responsestring= [[NSString alloc] initWithData:ResponseData1 encoding:NSUTF8StringEncoding];
        NSLog(@"responsestring = %@",responsestring);
        
        NSString *start = @"<size>";
        NSRange starting = [responsestring rangeOfString:start];
        if(starting.location != NSNotFound){
            /////////////size formatting///////////////////////////////////////
            NSString *end = @"</size>";
            NSRange ending = [responsestring rangeOfString:end];
            NSString *str = [responsestring substringWithRange:NSMakeRange(starting.location + starting.length, ending.location - (starting.location + starting.length))];
             self.objFile.size=[str intValue];
            self.objFile.strSize=[self ChangeStringSize:str];//[self size:str];//adarsh
            
            
            
            
            ////date formatting/////////////////////////////////////////////////
            
            
            NSString *start1 = @"<timeCreated>";
            NSRange starting1 = [responsestring rangeOfString:start1];
            if(starting1.location != NSNotFound){
                NSString *end1 = @"</timeCreated>";
                NSRange ending1 = [responsestring rangeOfString:end1];
                NSString *str1 = [responsestring substringWithRange:NSMakeRange(starting1.location + starting1.length, ending1.location - (starting1.location + starting1.length))];
                
                NSString *date1=[str1 substringToIndex:10];
                NSLog(@"%@",date1);
                NSString *time=[str1 substringWithRange:NSMakeRange(11, 8)];
                NSLog(@"%@",time);
                 self.objFile.strDateTime=[NSString stringWithFormat:@"%@ %@",date1,time];
                
                
                isGridViewActive = TRUE;
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
                NSLog(@"%@",date1);
                [dateFormatter setDateFormat:@"HH:mm:ss"];
                NSString *time=[dateFormatter stringFromDate:date];
                NSLog(@"%@",time);
                
//                NSString *date1=[str1 substringToIndex:10];
//                NSLog(@"%@",date1);
//                NSString *time=[str1 substringWithRange:NSMakeRange(11, 8)];
//                NSLog(@"%@",time);
                self.objFile.strLastModified=[NSString stringWithFormat:@"%@ %@",date1,time];
            }
            
            self.objFile.isInfoLoaded = TRUE;
            // NSLog(@"i = %d",i);
        }
    }
    
    else if(connection == Connection2)  /////for image loading 
    {
        infoCount++;
        UIImage *image1=[UIImage imageWithData:ResponseData2];
       
        //set thumbnail in file obj 
        self.objFile.thumbnail=image1;
        CFBridgingRetain(self.objFile.thumbnail);
        
        // display image 
        self.image=self.objFile.thumbnail;
        [self setNeedsDisplay];
        
//      /  NSLog(@"%@ %@",self.thumbnail,NSStringFromCGSize(self.thumbnail.size));
    }
}

/**
 * this method convert size of file from bytes  to kb,mb,gb
 * and return string value to set size variable.and also update file object in (connectionDidFinishLoading) method
 */
-(NSString *)size:(NSString *)size1
{
    /// calculating size
    
    NSString *returnstring;
    int x=[size1 intValue];
    float kb=0;
    float mb=0;
    float gb=0;

    if(x>1000)
    {
        kb=x/1000;
        returnstring=[NSString stringWithFormat:@"%0.2f KB",kb];
    }
    
    if(kb>1000)
    {
        mb=kb/1000;
        returnstring=[NSString stringWithFormat:@"%0.2f MB",mb];
    }
    
    if(mb >1000){
        gb=mb/1000;
        returnstring=[NSString stringWithFormat:@"%0.2f GB",gb];
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
