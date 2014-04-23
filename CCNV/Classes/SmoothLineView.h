//
//  SmoothLineView.h
//  Smooth Line View
//
//  Created by Levi Nunnink on 8/15/11.
//  Copyright 2011 culturezoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmoothLineView : UIView {

    @private
    CGPoint currentPoint;
    CGPoint previousPoint1;
    CGPoint previousPoint2;
    CGFloat lineWidth;
    UIColor *lineColor;
    UIImage *curImage;
    BOOL start;
}

@property (nonatomic, strong) UIColor *lineColor;
@property (readwrite) CGFloat lineWidth;
@property (nonatomic, readwrite) BOOL isErase;


- (void) drawPoint;
- (void) screenCapture:(NSValue*)boxSize;
@end
