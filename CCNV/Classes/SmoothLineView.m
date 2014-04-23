//
//  SmoothLineView.m
//  Smooth Line View
//
//  Created by Levi Nunnink on 8/15/11.
//  Copyright 2011 culturezoo. All rights reserved.
//

#import "SmoothLineView.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_COLOR [UIColor redColor]
#define DEFAULT_WIDTH 5.0f
@interface SmoothLineView () 

#pragma mark Private Helper function

CGPoint midPoint(CGPoint p1, CGPoint p2);

@end

@implementation SmoothLineView
@synthesize isErase;
@synthesize lineColor,lineWidth;
#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
//        self.lineWidth = DEFAULT_WIDTH;
//        self.lineColor = DEFAULT_COLOR;
    }
    return self;
}

#pragma mark Private Helper function

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    start = TRUE;
    UITouch *touch = [touches anyObject];
//    self.lineWidth = ([[touch valueForKey:@"pathMajorRadius"] floatValue] - 6) * 3;
    
    previousPoint1 = [touch previousLocationInView:self];
    previousPoint2 = [touch previousLocationInView:self];
    currentPoint = [touch locationInView:self];
    [self drawPoint];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch  = [touches anyObject];

//    self.lineWidth = ([[touch valueForKey:@"pathMajorRadius"] floatValue] - 6) * 3;
    previousPoint2  = previousPoint1;
    previousPoint1  = [touch previousLocationInView:self];
    currentPoint    = [touch locationInView:self];
    
    // calculate mid point
    CGPoint mid1    = midPoint(previousPoint1, previousPoint2); 
    CGPoint mid2    = midPoint(currentPoint, previousPoint1);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(path, NULL, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y);
    
    CGRect bounds = CGPathGetBoundingBox(path);
    CGPathRelease(path);
    
    CGRect drawBox = bounds;
    
    //Pad our values so the bounding box respects our line width
    drawBox.origin.x        -= self.lineWidth * 2;
    drawBox.origin.y        -= self.lineWidth * 2;
    drawBox.size.width      += self.lineWidth * 4;
    drawBox.size.height     += self.lineWidth * 4;

//    NSValue *rectValue = [NSValue valueWithCGSize:drawBox.size];
//    
//    [NSThread detachNewThreadSelector:@selector(screenCapture:) toTarget:self withObject:rectValue];
    
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(drawBox.size, YES, 1.0);
    } else {
        UIGraphicsBeginImageContext(drawBox.size);
    }
    
//  UIGraphicsBeginImageContext(drawBox.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	curImage = UIGraphicsGetImageFromCurrentImageContext();
    CFBridgingRetain(curImage);
	UIGraphicsEndImageContext();

    [self setNeedsDisplayInRect:drawBox];
}

- (void)drawPoint {
    // calculate mid point
    CGPoint mid1    = midPoint(previousPoint1, previousPoint2);
    CGPoint mid2    = midPoint(currentPoint, previousPoint1);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(path, NULL, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y);
    
    CGRect bounds = CGPathGetBoundingBox(path);
    CGPathRelease(path);
    
    CGRect drawBox = bounds;
    
    //Pad our values so the bounding box respects our line width
    drawBox.origin.x        -= self.lineWidth * 2;
    drawBox.origin.y        -= self.lineWidth * 2;
    drawBox.size.width      += self.lineWidth * 4;
    drawBox.size.height     += self.lineWidth * 4;
    
//    NSValue *rectValue = [NSValue valueWithCGSize:drawBox.size];
//    
//    [NSThread detachNewThreadSelector:@selector(screenCapture:) toTarget:self withObject:rectValue];

    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(drawBox.size, YES, 1.0);
    } else {
        UIGraphicsBeginImageContext(drawBox.size);
    }
    
//    UIGraphicsBeginImageContext(drawBox.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	curImage = UIGraphicsGetImageFromCurrentImageContext();
    CFBridgingRetain(curImage);
	UIGraphicsEndImageContext();
    
    [self setNeedsDisplayInRect:drawBox];
}

- (void)drawRect:(CGRect)rect
{
    if(!start)
        return;
    
    if (![curImage isKindOfClass:[UIImage class]]) {
        return;
    }
    
    [curImage drawAtPoint:CGPointMake(0,0)];
    CGPoint mid1 = midPoint(previousPoint1, previousPoint2); 
    CGPoint mid2 = midPoint(currentPoint, previousPoint1);

    CGContextRef context = UIGraphicsGetCurrentContext(); 
    
    //[[self layer] drawInContext:context];

    [self.layer renderInContext:context];

    CGContextMoveToPoint(context, mid1.x, mid1.y);
    // Use QuadCurve is the key
    CGContextAddQuadCurveToPoint(context, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y); 
    
    CGContextSetLineCap(context, kCGLineCapRound);
    
    if(!isErase){
        CGContextSetLineWidth(context, self.lineWidth);
    }
    else{
         CGContextSetLineWidth(context, self.lineWidth *2);
    }
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    NSLog(@"\n\n %@",self.lineColor.CGColor);
    if(isErase)
        CGContextSetBlendMode(context, kCGBlendModeClear);

    CGContextStrokePath(context);

    [super drawRect:rect];
}

- (void) screenCapture:(NSValue*)boxSize {
    @autoreleasepool {
        CGSize rect = [boxSize CGSizeValue];
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(rect, YES, 1.0);
        } else {
            UIGraphicsBeginImageContext(rect);
        }
        
        //    UIGraphicsBeginImageContext(drawBox.size);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        curImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

@end