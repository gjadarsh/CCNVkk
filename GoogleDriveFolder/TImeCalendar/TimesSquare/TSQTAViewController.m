//
//  TSQTAViewController.m
//  TimesSquare
//
//  Created by Jim Puls on 12/5/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQTAViewController.h"
#import "MWPhotoBrowser.h"
#import "MWPhoto.h"
#import "TSQTACalendarRowCell.h"
#import "TimesSquare.h"
#import "MWPhotoProtocol.h"

@interface TSQTAViewController ()<MWPhotoBrowserDelegate,TSQCalendarViewDelegate>

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, strong) NSDateFormatter *dayFormatterImage;
@end


@interface TSQCalendarView (AccessingPrivateStuff)

@property (nonatomic, readonly) UITableView *tableView;
@end


@implementation TSQTAViewController
{
    NSMutableArray *photoBrowsePhotoArray;
}

- (void)loadView;
{
    NSLog(@"ArrayIMage1,,,%d",self.arrayWithImages.count);
    photoBrowsePhotoArray=[NSMutableArray new];
   // [self createPhotoArrayForPhotoBrowser:_arrayWithImages];
    TSQCalendarView *calendarView = [[TSQCalendarView alloc] init];
    calendarView.delegate=self;
    calendarView.calendar = self.calendar;
    calendarView.arrayWithImages=self.arrayWithImages;
    calendarView.rowCellClass = [TSQTACalendarRowCell class];
    calendarView.firstDate = [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 365 * 10];
    calendarView.lastDate = [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 365 * 10];
    calendarView.backgroundColor = [UIColor colorWithRed:0.84f green:0.85f blue:0.86f alpha:1.0f];
    calendarView.pagingEnabled = YES;
    CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
    calendarView.contentInset = UIEdgeInsetsMake(0.0f, onePixel, 0.0f, onePixel);

    self.view = calendarView;
}

- (void)setCalendar:(NSCalendar *)calendar;
{
    _calendar = calendar;
    
    //self.navigationItem.title = calendar.calendarIdentifier;
   // self.tabBarItem.title = calendar.calendarIdentifier;
}

- (void)viewDidLayoutSubviews;
{
  // Set the calendar view to show today date on start
    [self todayDateGet];
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain target:self action:@selector(todayDateGet)] ;

    // Uncomment this to test scrolling performance of your custom drawing
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(scroll) userInfo:nil repeats:YES];
}
-(void)todayDateGet{
    [(TSQCalendarView *)self.view scrollToDate:[NSDate date] animated:NO];

}
- (void)viewWillDisappear:(BOOL)animated;
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)scroll;
{
    static BOOL atTop = YES;
    TSQCalendarView *calendarView = (TSQCalendarView *)self.view;
    UITableView *tableView = calendarView.tableView;
    
    [tableView setContentOffset:CGPointMake(0.f, atTop ? 10000.f : 0.f) animated:YES];
    atTop = !atTop;
}
- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    NSMutableArray *array1=[NSMutableArray new];
    [_arrayWithImages enumerateObjectsUsingBlock:^(GTLDriveFile *obj, NSUInteger idx, BOOL *stop) {
        if ([[self.dayFormatterImage stringFromDate:obj.modifiedDate.date] isEqualToString:[self.dayFormatterImage stringFromDate:date]])
        {
            [array1 addObject:obj];
        }
    }];
    
    if (array1.count>0) {
        [self createPhotoArrayForPhotoBrowser:array1];
        [self createPhotoViewer:array1];


    }
  

}
-(void)createPhotoViewer:(NSMutableArray *)arrayImages
{
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    // browser.wantsFullScreenLayout = YES; // iOS 5 & 6 only: Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
    [browser setCurrentPhotoIndex:arrayImages.count-1];
    // Optionally set the current visible photo before displaying
    
    // Present
    [self.navigationController pushViewController:browser animated:YES];
}
-(NSDateFormatter *)dayFormatterImage{
    if (!_dayFormatterImage) {
        _dayFormatterImage = [NSDateFormatter new];
        _dayFormatterImage.calendar = self.calendar;
        _dayFormatterImage.dateFormat = @"yyyy-MM-dd";
    }
    return _dayFormatterImage;
    
}
-(void)createPhotoArrayForPhotoBrowser:(NSMutableArray *)imageArray{
    //imageSelectedIndex=[imageArray indexOfObject:didSelectedDriveFile];
    [photoBrowsePhotoArray removeAllObjects];
    [imageArray enumerateObjectsUsingBlock:^(GTLDriveFile *obj, NSUInteger idx, BOOL *stop) {
        [photoBrowsePhotoArray addObject:[MWPhoto photoWithImageDriverFile:obj thumbNail:NO]]; //photoWithURL:[NSURL URLWithString:stringUrl] checkalue:NO]];
    }];
    
}

#pragma mark-MWPhotobrowser Delegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return photoBrowsePhotoArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < photoBrowsePhotoArray.count)
        return [photoBrowsePhotoArray objectAtIndex:index];
    return nil;
}
@end
