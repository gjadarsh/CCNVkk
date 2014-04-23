//
//  BannerImageView.m
//  CCNV
//
//  Created by Komal Daudia on 17/06/13.
//
//

#import "BannerImageView.h"

@implementation BannerImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        btnBanner=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnBanner setFrame:CGRectMake(0, 0, frame.size.width, 44)];
        [btnBanner setBackgroundColor:[UIColor clearColor]];
        [btnBanner addTarget:self action:@selector(OpenBannerInSafari:) forControlEvents:UIControlEventTouchUpInside];
        
        self.backgroundColor = [UIColor whiteColor];
        
        bannerImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        [bannerImage setBackgroundColor:[UIColor redColor]];
        
        [self addSubview:btnBanner];
//        [self addSubview:bannerImage];
//        [self bringSubviewToFront:bannerImage];
      
        Currentdict=[[NSMutableDictionary alloc] init];
        
        
        [self LoadNewBanner];
            }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(IBAction)OpenBannerInSafari:(id)sender{
    if([Currentdict valueForKey:@"link"]){
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[Currentdict valueForKey:@"link"]]];
    }
}
-(void)LoadNewBanner{
    
    NSString *strDevice;
    if (isIpad) {
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
    
    Connection1 = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if(Connection1) {
        ResponseData1 = [[NSMutableData alloc] init];
    }
    
    if(!timer){
    timer=[NSTimer timerWithTimeInterval:1 target:self selector:@selector(LoadNewBanner) userInfo:nil repeats:YES];
    }
}




#pragma mark - HTTP connection methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    if (connection == Connection1){
        ResponseData1 = nil;  }

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == Connection1){/// for loading file info
        [ResponseData1 setLength:0];
           }
   
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == Connection1){
        [ResponseData1 appendData:data];}

    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    if (connection == Connection1) {
        /// for loading file info
        NSString *responsestring= [[NSString alloc] initWithData:ResponseData1 encoding:NSUTF8StringEncoding];
        NSLog(@"responsestring = %@",responsestring);
        
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
            image=[UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            [btnBanner setImage:image forState:UIControlStateNormal];
            [bannerImage setImage:image];
            [self setNeedsDisplay];
        }
        
    }
}
@end
