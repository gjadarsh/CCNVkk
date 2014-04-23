/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalTileView.h"
#import "KalDate.h"
#import "KalPrivate.h"
#import "AppDelegate.h"

extern const CGSize kTileSize;

@implementation KalTileView

@synthesize date,imagethumbe;

- (id)initWithFrame:(CGRect)frame 
{
  if ((self = [super initWithFrame:frame])) {
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    origin = frame.origin;
    [self setIsAccessibilityElement:YES];
    [self setAccessibilityTraits:UIAccessibilityTraitButton];
    [self resetState];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame thumbimage:(UIImage *)Img
{
    if ((self = [super initWithFrame:frame])) {
//        self.opaque = NO;
//        self.backgroundColor = [UIColor clearColor];
//        self.clipsToBounds = NO;
//        origin = frame.origin;
//        imagethumbe = imagethumbe;
//        [self setIsAccessibilityElement:YES];
//        [self setAccessibilityTraits:UIAccessibilityTraitButton];
//        [self resetState];
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGFloat fontSize = 18.f;
  UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
  UIColor *shadowColor = nil;
  UIColor *textColor = nil;
  UIImage *markerImage = nil;
  CGContextSelectFont(ctx, [font.fontName cStringUsingEncoding:NSUTF8StringEncoding], fontSize, kCGEncodingMacRoman);
      
  CGContextTranslateCTM(ctx, 0, kTileSize.height);
  CGContextScaleCTM(ctx, 1, -1);
  
   
  if ([self isToday] && self.selected)
  {      
    [[[UIImage imageNamed:@"Kal.bundle/kal_tile_today_selected.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] drawInRect:CGRectMake(0, -1, kTileSize.width+1, kTileSize.height+1)];
    if ([[AppDelegate weekdayForDate:[NSString stringWithFormat:@"%@",self.date]] isEqualToString:@"Sunday"])
    {
        textColor = [UIColor redColor];
    }
    else if ([[AppDelegate weekdayForDate:[NSString stringWithFormat:@"%@",self.date]] isEqualToString:@"Saturday"])
    {
        textColor = [UIColor blueColor];
    }
    else
    {
//        textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Kal.bundle/kal_tile_text_fill.png"]];
        textColor = [UIColor whiteColor];
    }
    shadowColor = [UIColor blackColor];
    markerImage = [UIImage imageNamed:@"Kal.bundle/kal_tile_selected.png"];
  }
  else if ([self isToday] && !self.selected)
  {
//      NSString *imageStr;
//      if (APP.firstTemp == 0)
//      {
//          imageStr = [NSString stringWithFormat:@"Kal.bundle/kal_tile_today_selected.png"];
//          APP.` ++;
//      }
//      else
//      {
//          imageStr = [NSString stringWithFormat:@"23.jpg"];
//      }
      
    [[[UIImage imageNamed:@"23.jpg"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] drawInRect:CGRectMake(0, -1, kTileSize.width+1, kTileSize.height+1)];
//    [[[UIImage imageNamed:imageStr] stretchableImageWithLeftCapWidth:6 topCapHeight:0] drawInRect:CGRectMake(0, -1, kTileSize.width+1, kTileSize.height+1)];
      if ([[AppDelegate weekdayForDate:[NSString stringWithFormat:@"%@",self.date]] isEqualToString:@"Sunday"])
      
      {
          textColor = [UIColor redColor];
      }
      else if ([[AppDelegate weekdayForDate:[NSString stringWithFormat:@"%@",self.date]] isEqualToString:@"Saturday"])
      {
          textColor = [UIColor blueColor];
      }
      else
      {
//          textColor = [UIColor whiteColor];
          textColor = [UIColor whiteColor];
      }
      
      
//      [[[UIImage imageNamed:@"23.jpg"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] drawInRect:CGRectMake(0, -1, kTileSize.width+1, kTileSize.height+1)];
//      if ([[AppDelegate weekdayForDate:[NSString stringWithFormat:@"%@",self.date]] isEqualToString:@"Sunday"])
//          
//      {
//          textColor = [UIColor redColor];
//      }
//      else if ([[AppDelegate weekdayForDate:[NSString stringWithFormat:@"%@",self.date]] isEqualToString:@"Saturday"])
//      {
//          textColor = [UIColor blueColor];
//      }
//      else
//      {
//          textColor = [UIColor whiteColor];
//      }
      
      
    shadowColor = [UIColor blackColor];
    markerImage = [UIImage imageNamed:@"Kal.bundle/kal_marker_today.png"];
      [self loadImagesForDate];
  }
  else if (self.selected)
  {
      [[[UIImage imageNamed:@"Kal.bundle/kal_tile_selected.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0] drawInRect:CGRectMake(0, -1, kTileSize.width+1, kTileSize.height+1)];
      
      textColor = [UIColor whiteColor];
      shadowColor = [UIColor blackColor];
      markerImage = [UIImage imageNamed:@"Kal.bundle/kal_marker_selected.png"];

  }
  else if (self.belongsToAdjacentMonth)
  {
    textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Kal.bundle/kal_tile_dim_text_fill.png"]];
    shadowColor = nil;
    markerImage = [UIImage imageNamed:@"Kal.bundle/kal_marker_dim.png"];
  }
  else
  {      
      markerImage = [UIImage imageNamed:@"Kal.bundle/kal_marker.png"];
      [self loadImagesForDate];
//      NSString *dtString = [NSString stringWithFormat:@"%04i-%02i-%02i",[self.date year],[self.date month], [self.date day]];
//      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateStr LIKE[cd] %@",dtString];
//        NSArray *arr=[arrImageListForCal filteredArrayUsingPredicate:predicate];
//      if([arr count]>0)
//      {
//          File *obj=[arr objectAtIndex:0];
//          UIImage *img=[[UIImage alloc] initWithCGImage:[obj.thumbnail CGImage] scale:1.0 orientation:UIImageOrientationDown]; //obj.thumbnail;
//          if(!obj.thumbnail)
//          {
//              img=[[UIImage alloc] initWithCGImage:[[UIImage imageNamed:@"pngfile.png"]CGImage] scale:1.0 orientation:UIImageOrientationDownMirrored];
//          }          
////          [[img stretchableImageWithLeftCapWidth:0 topCapHeight:0] drawInRect:CGRectMake(1.5,0, kTileSize.width-3.5, kTileSize.height-3.2)];
////          [img drawInRect:CGRectMake(1.5,0, kTileSize.width-3.5, kTileSize.height-3.2)];
//          
//          if (isIpad)
//          {
//              [[img imageByScalingProportionallyToSize:kTileSize] drawInRect:CGRectMake(1,1, kTileSize.width-4, kTileSize.height-6)];
//          }
//          else
//          {
//              if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
//              {
//                  [[img imageByScalingProportionallyToSize:kTileSize] drawInRect:CGRectMake(1,1, kTileSize.width-4, kTileSize.height-3)];
//              }
//              else
//              {
//                  [[img imageByScalingProportionallyToSize:kTileSize] drawInRect:CGRectMake(1,1, kTileSize.width-4, kTileSize.height-6)];
//              }
//          }
//         
//          textColor = [UIColor whiteColor];
//          shadowColor = [UIColor blackColor];        
//          
//        }
      if ([[AppDelegate weekdayForDate:[NSString stringWithFormat:@"%@",self.date]] isEqualToString:@"Sunday"])
      {
          textColor = [UIColor redColor];
      }
      else if ([[AppDelegate weekdayForDate:[NSString stringWithFormat:@"%@",self.date]] isEqualToString:@"Saturday"])
      {
          textColor = [UIColor blueColor];
      }
      else
      {
          textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Kal.bundle/kal_tile_text_fill.png"]];
      }
    shadowColor = [UIColor whiteColor];
  }
   
    // Marked Dot date where Image is Uploaded
//  if (flags.marked)
//    [markerImage drawInRect:CGRectMake(21.f, 5.f, 4.f, 5.f)];
  
  NSUInteger n = [self.date day];
  NSString *dayText = [NSString stringWithFormat:@"%lu", (unsigned long)n];
  const char *day = [dayText cStringUsingEncoding:NSUTF8StringEncoding];
  CGSize textSize = [dayText sizeWithFont:font];
  CGFloat textX, textY;
  textX = roundf(0.5f * (kTileSize.width - textSize.width));
  textY = 6.f + roundf(0.5f * (kTileSize.height - textSize.height));
  if (shadowColor) {
    [shadowColor setFill];
    CGContextShowTextAtPoint(ctx, textX, textY, day, n >= 10 ? 2 : 1);
    textY += 1.f;
  }
/*
    if ([[AppDelegate weekdayForDate:[NSString stringWithFormat:@"%@",self.date]] isEqualToString:@"Sunday"]) {
        textColor = [UIColor redColor];
    }
    else if ([[AppDelegate weekdayForDate:[NSString stringWithFormat:@"%@",self.date]] isEqualToString:@"Saturday"]) {
        textColor = [UIColor blueColor];
    }
    else {
        textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Kal.bundle/kal_tile_text_fill.png"]];
    }
*/
    [textColor setFill];
  CGContextShowTextAtPoint(ctx, textX, textY, day, n >= 10 ? 2 : 1);
  
  if (self.highlighted) {
    [[UIColor colorWithWhite:0.25f alpha:0.3f] setFill];
    CGContextFillRect(ctx, CGRectMake(0.f, 0.f, kTileSize.width, kTileSize.height));
  }    
}

-(void)loadImagesForDate
{
    UIColor *shadowColor = nil;
    UIColor *textColor = nil;
    NSString *dtString = [NSString stringWithFormat:@"%04i-%02i-%02i",[self.date year],[self.date month], [self.date day]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateStr LIKE[cd] %@",dtString];
    NSArray *arr=[arrImageListForCal filteredArrayUsingPredicate:predicate];
    if([arr count]>0)
    {
        File *obj=[arr objectAtIndex:0];
        UIImage *img=[[UIImage alloc] initWithCGImage:[obj.thumbnail CGImage] scale:1.0 orientation:UIImageOrientationDownMirrored]; //obj.thumbnail;
        if(!obj.thumbnail)
        {
            img=[[UIImage alloc] initWithCGImage:[[UIImage imageNamed:@"pngfile.png"]CGImage] scale:1.0 orientation:UIImageOrientationDownMirrored];
        }
//                 [[img stretchableImageWithLeftCapWidth:0 topCapHeight:0] drawInRect:CGRectMake(1.5,0, kTileSize.width-3.5, kTileSize.height-3.2)];
//                [img drawInRect:CGRectMake(1.5,0, kTileSize.width-3.5, kTileSize.height-3.2)];
        
        if (isIpad)
        {
            [[img imageByScalingProportionallyToSize:kTileSize] drawInRect:CGRectMake(1,1, kTileSize.width-4, kTileSize.height-6)];
        }
        else
        {
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
            {
                [[img imageByScalingProportionallyToSize:kTileSize] drawInRect:CGRectMake(1,1, kTileSize.width-4, kTileSize.height-3)];
            }
            else
            {
                [[img imageByScalingProportionallyToSize:kTileSize] drawInRect:CGRectMake(1,1, kTileSize.width-4, kTileSize.height-6)];
            }
        }
        
        textColor = [UIColor whiteColor];
        shadowColor = [UIColor blackColor];
    }
}

- (void)resetState
{
  // realign to the grid
  CGRect frame = self.frame;
  frame.origin = origin;
  frame.size = kTileSize;
  self.frame = frame;
  
  [date release];
  date = nil;
  flags.type = KalTileTypeRegular;
  flags.highlighted = NO;
  flags.selected = NO;
  flags.marked = NO;
}

- (void)setDate:(KalDate *)aDate
{
  if (date == aDate)
    return;

  [date release];
  date = [aDate retain];

  [self setNeedsDisplay];
}

- (BOOL)isSelected { return flags.selected; }

- (void)setSelected:(BOOL)selected
{
  if (flags.selected == selected)
    return;

  // workaround since I cannot draw outside of the frame in drawRect:
  if (![self isToday]) {
    CGRect rect = self.frame;
    if (selected) {
      rect.origin.x--;
      rect.size.width++;
      rect.size.height++;
    } else {
      rect.origin.x++;
      rect.size.width--;
      rect.size.height--;
    }
    self.frame = rect;
  }
  
  flags.selected = selected;
  [self setNeedsDisplay];
}

- (BOOL)isHighlighted { return flags.highlighted; }

- (void)setHighlighted:(BOOL)highlighted
{
  if (flags.highlighted == highlighted)
    return;
  
  flags.highlighted = highlighted;
  [self setNeedsDisplay];
}

- (BOOL)isMarked { return flags.marked; }

- (void)setMarked:(BOOL)marked
{
  if (flags.marked == marked)
    return;
  
  flags.marked = marked;
  [self setNeedsDisplay];
}

- (KalTileType)type { return flags.type; }

- (void)setType:(KalTileType)tileType
{
  if (flags.type == tileType)
    return;
  
  // workaround since I cannot draw outside of the frame in drawRect:
  CGRect rect = self.frame;
  if (tileType == KalTileTypeToday) {
    rect.origin.x--;
    rect.size.width++;
    rect.size.height++;
  } else if (flags.type == KalTileTypeToday) {
    rect.origin.x++;
    rect.size.width--;
    rect.size.height--;
  }
  self.frame = rect;
  
  flags.type = tileType;
  [self setNeedsDisplay];
}

- (BOOL)isToday { return flags.type == KalTileTypeToday; }

- (BOOL)belongsToAdjacentMonth { return flags.type == KalTileTypeAdjacent; }

- (void)dealloc
{
  [date release];
  [super dealloc];
}

@end
