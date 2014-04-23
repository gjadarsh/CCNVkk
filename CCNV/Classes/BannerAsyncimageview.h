//  AsyncImageView.h //

#import <UIKit/UIKit.h>

@class EmployeeClass;
@interface BannerAsyncimageview : UIView {
	//could instead be a subclass of UIImageView instead of UIView, depending on what other features you want to 
	// to build into this class?
  NSMutableDictionary *Currentdict;
    NSTimer *timer;
	NSURLConnection* connection; //keep a reference to the connection so we can cancel download in dealloc
	NSMutableData* data; //keep reference to the data so we can collect it as it downloads
	//but where is the UIImage reference? We keep it in self.subviews - no need to re-code what we have in the parent class	
}

- (void)loadImageFromURL;
- (UIImage*) image;

@end
