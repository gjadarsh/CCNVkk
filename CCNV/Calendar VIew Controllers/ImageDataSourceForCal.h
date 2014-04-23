//
//  ImageDataSourceForCal.h
//  CCNV
//
//  Created by  Linksware Inc. on 12/27/2012.
//
//

#import <Foundation/Foundation.h>
#import "Kal.h"
@class Holiday;
@interface ImageDataSourceForCal : NSObject<KalDataSource>
{
    NSMutableArray *items;
    NSMutableArray *holidays;
}
@property (nonatomic,strong)NSMutableArray *items;
@property (nonatomic,strong)NSMutableArray *holidays;

+ (ImageDataSourceForCal *)dataSource;
- (Holiday *)holidayAtIndexPath:(NSIndexPath *)indexPath;  // exposed for HolidayAppDelegate so that it can implement the UITableViewDelegate protocol.
@end
