
//  AsyncImageView.m //


#import "BannerAsyncimageview.h"
#import "Global.h"
@implementation BannerAsyncimageview

- (void)dealloc {
    [connection cancel]; //in case the URL is still downloading
    [super dealloc];
}


- (void)loadImageFromURL {
    
    UITapGestureRecognizer *taprecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OpenBannerInSafari:)];
    [self addGestureRecognizer:taprecognizer];
    
    Currentdict=[[NSMutableDictionary alloc] init];

    //in case we are downloading a 2nd image
    NSString *strDevice;
    if (!isIpad) {
        strDevice=@"iPhone";
    }else{
        strDevice=@"iPad";
    }
    NSString *xmlString = [NSString stringWithFormat:
                           @"<ved version=\"1.0.0.0\"><request>banner-data</request><fileids><fileids id=\"user\"><property name=\"device_type\">%@</property></fileids></fileids></ved>",strDevice];
    
    NSData *thumbsupData = [xmlString dataUsingEncoding: NSASCIIStringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:@"%@app-authorization",KBannerUrl];
    NSURL* theURL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest addValue:@"application/xml; charset=UTF-8" forHTTPHeaderField:@"Content-type"];
    [theRequest setHTTPBody:thumbsupData];
    
    
    NSError *error;
    NSHTTPURLResponse *response = nil;
    NSData *data1=[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    
    if(data1!=nil){
        
        NSString *responsestring= [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
        
        if ([[self subviews] count]>0) {
            //then this must be another image, the old one is still in subviews
            [[[self subviews] objectAtIndex:0] removeFromSuperview]; //so remove it (releases it also)
        }
      //  NSString *responsestring= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //    NSLog(@"responsestring = %@",responsestring);
        
        NSString *start = @"<image>";
        NSRange starting = [responsestring rangeOfString:start];
        if(starting.location != NSNotFound){
            
            NSString *end = @"</image>";
            NSRange ending = [responsestring rangeOfString:end];
            NSString *str = [responsestring substringWithRange:NSMakeRange(starting.location + starting.length, ending.location - (starting.location + starting.length))];
            
            [Currentdict setValue:str forKey:@"imgurl"];
            
        }
        //link
        
        NSString *start1 = @"<link>";
        NSRange starting1 = [responsestring rangeOfString:start1];
        if(starting1.location != NSNotFound){
            
            NSString *end = @"</link>";
            NSRange ending = [responsestring rangeOfString:end];
            NSString *str = [responsestring substringWithRange:NSMakeRange(starting1.location + starting1.length, ending.location - (starting1.location + starting1.length))];
            
            [Currentdict setValue:str forKey:@"link"];
        }
        
        if([Currentdict  valueForKey:@"imgurl"]){
            NSURL *url=[NSURL URLWithString:[Currentdict valueForKey:@"imgurl"]];
            
            [self setNeedsDisplay];
            
            UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]]];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            [self addSubview:imageView];
            imageView.frame = self.bounds;
            [imageView setNeedsLayout];
            
            [self setNeedsLayout];
        }
        //don't need this any more, its in the UIImageView now
        data=nil;
        //        NSLog(@"responsestring = %@",responsestring);
    }
    
//    if(!timer){
//        timer=[NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(loadImageFromURL) userInfo:nil repeats:YES];
//     
//    }
    
    
}
-(void)OpenBannerInSafari:(UITapGestureRecognizer *)recognizer{
    if([Currentdict valueForKey:@"link"]){
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[Currentdict valueForKey:@"link"]]];
    }
}

//the URL connection calls this repeatedly as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    
    if (data==nil) { data = [[NSMutableData alloc] initWithCapacity:2048]; } 
    
    [data appendData:incrementalData];
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    
    //so self data now has the complete image 
    connection=nil;
    
    if ([[self subviews] count]>0) {
        //then this must be another image, the old one is still in subviews
        [[[self subviews] objectAtIndex:0] removeFromSuperview]; //so remove it (releases it also)
    }
    NSString *responsestring= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"responsestring = %@",responsestring);
    
    NSString *start = @"<image>";
    NSRange starting = [responsestring rangeOfString:start];
    if(starting.location != NSNotFound){
        
        NSString *end = @"</image>";
        NSRange ending = [responsestring rangeOfString:end];
        NSString *str = [responsestring substringWithRange:NSMakeRange(starting.location + starting.length, ending.location - (starting.location + starting.length))];
        
        [Currentdict setValue:str forKey:@"imgurl"];
        
    }
    //link
    
    NSString *start1 = @"<link>";
    NSRange starting1 = [responsestring rangeOfString:start1];
    if(starting1.location != NSNotFound){
        
        NSString *end = @"</link>";
        NSRange ending = [responsestring rangeOfString:end];
        NSString *str = [responsestring substringWithRange:NSMakeRange(starting1.location + starting1.length, ending.location - (starting1.location + starting1.length))];
        
        [Currentdict setValue:str forKey:@"link"];
    }
    
    if([Currentdict  valueForKey:@"imgurl"]){
        NSURL *url=[NSURL URLWithString:[Currentdict valueForKey:@"imgurl"]];
        
        [self setNeedsDisplay];
        
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:imageView];
        imageView.frame = self.bounds;
        [imageView setNeedsLayout];
        
        [self setNeedsLayout];
    }
    //don't need this any more, its in the UIImageView now
    data=nil;
}

- (UIImage*) image {
    UIImageView* iv = [[self subviews] objectAtIndex:0];
    return [iv image];
}

@end