//
//  BannerImageView.h
//  CCNV
//
//  Created by Komal Daudia on 17/06/13.
//
//

#import <UIKit/UIKit.h>

@interface BannerImageView : UIView
{
    UIButton *btnBanner;
    NSURLConnection *Connection1;
    NSMutableData *ResponseData1;
    UIImage *image;
    UIImageView *bannerImage;
    
    NSTimer *timer;
    NSMutableDictionary *Currentdict;
}

-(void)LoadNewBanner;
-(IBAction)OpenBannerInSafari:(id)sender;
@end
