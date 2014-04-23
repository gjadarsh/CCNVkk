//
//  SamplePreview.m
//  CCNV
//
//  Created by Project Development Department on 2014/04/22.
//
//

#import "SamplePreview.h"

@implementation SamplePreview
- (NSURL*)previewItemURL {
    return self.url;
}

- (NSString*)previewItemTitle {
    return self.title;
}

@end
