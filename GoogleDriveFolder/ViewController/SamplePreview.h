//
//  SamplePreview.h
//  CCNV
//
//  Created by Project Development Department on 2014/04/22.
//
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface SamplePreview : NSObject<QLPreviewItem>
@property (readwrite) NSURL *url;
@property (readwrite) NSString *title;
@end
