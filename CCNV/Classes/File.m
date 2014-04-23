//
//  File.m
//  CCNV
//
//  Created by  Linksware Inc. on 9/26/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import "File.h"
#import "AppDelegate.h"
@implementation File
@synthesize strMediaType,strDisplayName,ref,strSize,strDateTime,filedata,isInfoLoaded,size,thumbnail,FullImage,isPublick, dateStr,strMovieThumnailUrl,strFileAuthor,strFileownerName,strLastModified;
-(id)init
{
    strFileAuthor=@"";
    strMediaType=@"";
    strDisplayName=@"";
    ref=@"";
    strDateTime=@"";
    strSize=@"";
    filedata=@"";
    dateStr=@"";
    strMovieThumnailUrl=@"";
    isInfoLoaded=FALSE;
    isPublick=FALSE;
    thumbnail=nil;
    FullImage=nil;
    return self;
}

/**
 * this method load file object detail info in background thread 
 * it starts new connection to load info of file , and update object in (connectionDidFinishLoading) method
 */
- (void) getFileInfo {
    NSArray *arr=[self.strMediaType componentsSeparatedByString:@"/"];
    NSString *strExtention=[arr objectAtIndex:0];
    NSLog(@"%@", strExtention);
    if([strExtention isEqualToString:@"folder"]||[strExtention isEqualToString:@"syncFolder"]){
   
        return;
    }
    
    NSString *urlString =[NSString stringWithFormat:@"%@",self.ref];
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
-(void)loadThumbnailImage {
    
    NSArray *arr=[self.strMediaType componentsSeparatedByString:@"/"];
    NSString *strExtention=[arr objectAtIndex:0];
    NSString *urlString ;
    if([strExtention isEqualToString:@"video"]){
        urlString=[NSString stringWithFormat:@"%@",self.filedata];
    }
    else{
        urlString=[NSString stringWithFormat:@"%@",self.filedata];
    }
    NSURL *theURL = [NSURL URLWithString:urlString];
    
    //NSLog(@"URL = %@",urlString);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    NSLog(@"Access token = %@",ApplicationDelegate.accessToken);
    [theRequest setValue:ApplicationDelegate.accessToken forHTTPHeaderField:@"Authorization"];
    //[theRequest setValue:@"image/jpeg; pxmax=140; pymax=140; sq=(1);r=(0)" forHTTPHeaderField:@"Accept"];
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
    
    if (connection == Connection1){
        [ResponseData1 setLength:0];
      //  NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
      //  NSDictionary* headers = [httpResponse allHeaderFields];
        //NSLog(@"Header Response = %@",headers);
    }
    else if (connection == Connection2){
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
    
    if (connection == Connection1) {
        NSString *responsestring= [[NSString alloc] initWithData:ResponseData1 encoding:NSUTF8StringEncoding];
        NSLog(@"responsestring = %@",responsestring);
        
        NSString *start = @"<size>";
        NSRange starting = [responsestring rangeOfString:start];
        if(starting.location != NSNotFound){
            /////////////size formatting///////////////////////////////////////
            NSString *end = @"</size>";
            NSRange ending = [responsestring rangeOfString:end];
            NSString *str = [responsestring substringWithRange:NSMakeRange(starting.location + starting.length, ending.location - (starting.location + starting.length))];
            self.size=[str intValue];
          self.strSize=[self ChangeStringSize:str];//[self size:str];//adarsh
           
            
            
            
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
                self.strDateTime=[NSString stringWithFormat:@"%@ %@",date1,time];
                if([self.strDateTime isEqualToString:@""]){
                    self.strDateTime=[NSString stringWithFormat:@"%@ %@",date1,time];}
                isGridViewActive = TRUE;
               ;
               
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
              //  self.strLastModified=[NSString stringWithFormat:@"%@ %@",date1,time];
            }
            
            self.isInfoLoaded = TRUE;
           // NSLog(@"i = %d",i);
        }
    }
    
    else if(connection == Connection2)
    {
        infoCount++;
        UIImage *image1=[UIImage imageWithData:ResponseData2];
       // [fileTypeImage setImage:image1];
        self.thumbnail=image1;
        CGImageSourceRef mySourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)ResponseData2, NULL);
        
        NSDictionary *metaData = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(mySourceRef,0,NULL);
        NSLog(@"exifDic properties: %@", metaData); //all data
        NSLog(@"%@ %@",self.thumbnail,NSStringFromCGSize(self.thumbnail.size));
    }
}

/**
 * this method convert size of file from bytes  to kb,mb,gb
 * and return string value to set size variable.and also update file object in (connectionDidFinishLoading) method
 */

-(NSString *)size:(NSString *)size1
{
    NSString *returnstring;
    int x=[size1 intValue];
    float kb=0.0;
    float mb=0.0;
    float gb=0.0;
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