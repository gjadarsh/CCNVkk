/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "Holiday.h"

@implementation Holiday

@synthesize date, name, country,thumbimage, dateStr,objFile;

+ (Holiday*)holidayNamed:(NSString *)aName country:(NSString *)aCountry date:(NSDate *)aDate img:(UIImage *)Img file:(File *)objfile
{
  return [[[Holiday alloc] initWithName:aName country:aCountry date:aDate img:Img file:objfile] autorelease];
}

- (id)initWithName:(NSString *)aName country:(NSString *)aCountry date:(NSDate *)aDate img:(UIImage *)Img file:(File *)objfile
{
  if ((self = [super init])) {
    name = [aName copy];
    country = [aCountry copy];
    date = [aDate retain];
    thumbimage=[Img retain];
      objFile=objfile;
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:@"yyyy-MM-dd"];
      dateStr = [dateFormatter stringFromDate:date];
      [dateFormatter release];
  }
  return self;
}

- (NSComparisonResult)compare:(Holiday *)otherHoliday
{
  NSComparisonResult comparison = [self.date compare:otherHoliday.date];
  if (comparison == NSOrderedSame)
    return [self.name compare:otherHoliday.name];
  else
    return comparison;
}

- (void)dealloc
{
  [date release];
  [name release];
  [country release];
  [super dealloc];
}

@end
