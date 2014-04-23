/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

/*
 *    Holiday
 *    -------
 *
 *  An immutable value object that represents a single element
 *  in the dataset.
 */
@interface Holiday : NSObject
{
    NSDate *date;
    NSString *name;
    NSString *country;
    UIImage *thumbimage;
    NSString *dateStr;
    File *objFile;
}
@property (nonatomic,retain)  File *objFile;
@property (nonatomic, retain, readonly) NSDate *date;
@property (nonatomic, retain, readonly) NSString *name;
@property (nonatomic, retain, readonly) NSString *country;
@property (nonatomic,retain)UIImage *thumbimage;
@property (nonatomic,retain) NSString *dateStr;
+ (Holiday*)holidayNamed:(NSString *)name country:(NSString *)country date:(NSDate *)date img:(UIImage *)Img file:(File *)objfile;
- (id)initWithName:(NSString *)name country:(NSString *)country date:(NSDate *)date img:(UIImage *)Img file:(File *)objfile;
- (NSComparisonResult)compare:(Holiday *)otherHoliday;

@end
