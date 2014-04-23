//
//  ImageDataSourceForCal.m
//  CCNV
//
//  Created by  Linksware Inc. on 12/27/2012.
//
//

#import "ImageDataSourceForCal.h"
#import <sqlite3.h>
#import "Holiday.h"
#import "AppDelegate.h"
static BOOL IsDateBetweenInclusive(NSDate *date, NSDate *begin, NSDate *end)
{
    return [date compare:begin] != NSOrderedAscending && [date compare:end] != NSOrderedDescending;
}
@interface ImageDataSourceForCal ()
- (NSArray *)holidaysFrom:(NSDate *)fromDate to:(NSDate *)toDate;
@end
@implementation ImageDataSourceForCal
@synthesize items,holidays;
+ (ImageDataSourceForCal *)dataSource
{
    return [[[self class] alloc] init] ;
}

- (id)init
{
    if ((self = [super init])) {
        items = [[NSMutableArray alloc] init];
        holidays = [[NSMutableArray alloc] init];
    }
    return self;
}

- (Holiday *)holidayAtIndexPath:(NSIndexPath *)indexPath
{
    return [items objectAtIndex:indexPath.row];
}

#pragma mark UITableViewDataSource protocol conformance

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    Holiday *holiday = [self holidayAtIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"flags/%@.gif", holiday.country]];
    cell.textLabel.text = holiday.name;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    Holiday *file = [items objectAtIndex:indexPath.row];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:file.objFile forKey:@"file"];
    isImageFromCalView=TRUE;
    
    //// loading detail view for date
    ///not in use from this step now.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CalDetailView" object:dic];
    NSLog(@"name : %@",file.name);
}
#pragma mark Sqlite access

/**
 * This method will return Database path.
 */

- (NSString *)databasePath
{
    return [[NSBundle mainBundle] pathForResource:@"holidays" ofType:@"db"];
}

- (void)loadHolidaysFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
    
    ////loading data for start date to end date /////////////////////////
    NSLog(@"Fetching images from  %@ and %@...", fromDate, toDate);
	
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init] ;
    for (File *obj in arrImageListForCal) {
        
        
        NSString *name =obj.strDisplayName;
        NSString *country =@"";
        NSString *dateAsText =obj.strDateTime;
        [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [holidays addObject:[Holiday holidayNamed:name country:country date:[fmt dateFromString:dateAsText] img:obj.thumbnail file:obj]];
    }

 
    [delegate loadedDataSource:self];
}

#pragma mark KalDataSource protocol conformance

- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
    [holidays removeAllObjects];
    [self loadHolidaysFrom:fromDate to:toDate delegate:delegate];
}

- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    return [[self holidaysFrom:fromDate to:toDate] valueForKeyPath:@"date"];
}

- (void)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    [items addObjectsFromArray:[self holidaysFrom:fromDate to:toDate]];
}

- (void)removeAllItems
{
    [items removeAllObjects];
}

#pragma mark -

- (NSArray *)holidaysFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    NSMutableArray *matches = [NSMutableArray array];
    for (Holiday *holiday in holidays)
        if (IsDateBetweenInclusive(holiday.date, fromDate, toDate))
            [matches addObject:holiday];
    
    return matches;
}

@end