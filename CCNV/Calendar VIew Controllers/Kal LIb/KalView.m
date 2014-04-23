/*
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalView.h"
#import "KalGridView.h"
#import "KalLogic.h"
#import "KalPrivate.h"

@interface KalView ()
- (void)addSubviewsToHeaderView:(UIView *)headerView;
- (void)addSubviewsToContentView:(UIView *)contentView;
- (void)setHeaderTitleText:(NSString *)text;
@end

//static const CGFloat kHeaderHeight = 44.f;
static const CGFloat kHeaderHeight = 28.f;
static const CGFloat kFooterHeight = 44.f;
//static const CGFloat kMonthLabelHeight = 22.f;

@implementation KalView

@synthesize delegate, tableView;

- (id)initWithFrame:(CGRect)frame delegate:(id<KalViewDelegate>)theDelegate logic:(KalLogic *)theLogic
{
    if ((self = [super initWithFrame:frame])) {
        delegate = theDelegate;
        logic = [theLogic retain];
        [logic addObserver:self forKeyPath:@"selectedMonthNameAndYear" options:NSKeyValueObservingOptionNew context:NULL];
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;        
        if (isIpad)
        {
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
            {
                //                UIView *contentView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 1024, frame.size.height - kHeaderHeight)] autorelease];
                //                contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                //                [self addSubviewsToContentView:contentView];
                //                [self addSubview:contentView];
                //                headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, gridView.height, 1024, kHeaderHeight)] autorelease];
                //                headerView.backgroundColor = [UIColor grayColor];
                //                [self addSubviewsToHeaderView:headerView];
                //                [self addSubview:headerView];
                headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 1024, kHeaderHeight)] autorelease];
                headerView.backgroundColor = [UIColor grayColor];
                [self addSubviewsToHeaderView:headerView];
                [self addSubview:headerView];
                UIView *contentView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, kHeaderHeight, 1024, frame.size.height)] autorelease];
                contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                [self addSubviewsToContentView:contentView];
                [self addSubview:contentView];
                
                footerToolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.f, gridView.height + 28, 1024, kFooterHeight)] autorelease];
                // H: Populate buttons for footer toolbar
                [self populateFooter];
                
//                footerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, gridView.height + 30, 1024, kFooterHeight)] autorelease];                
//                footerView.backgroundColor = [UIColor grayColor];
//                [self addSubviewsToFooterView:footerToolBar];
                
                [self addSubview:footerToolBar];
            }
            else
            {
                headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 768, kHeaderHeight)] autorelease];
                headerView.backgroundColor = [UIColor grayColor];
                [self addSubviewsToHeaderView:headerView];
                [self addSubview:headerView];
                UIView *contentView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, kHeaderHeight, 768, frame.size.height)] autorelease];
                contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                [self addSubviewsToContentView:contentView];
                [self addSubview:contentView];
                
                footerToolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.f, gridView.height + 28, 768, kFooterHeight)] autorelease];
                // H: Populate buttons for footer toolbar
                [self populateFooter];
                
//                footerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, gridView.height + 30, 768, kFooterHeight)] autorelease];
//                footerView.backgroundColor = [UIColor grayColor];
//                [self addSubviewsToFooterView:footerView];
                
                [self addSubview:footerToolBar];
            }
        }
        else
        {
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
            {
                CGSize result = [[UIScreen mainScreen] bounds].size;
                headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, result.height, kHeaderHeight)] autorelease];
                headerView.backgroundColor = [UIColor grayColor];
                [self addSubviewsToHeaderView:headerView];
                [self addSubview:headerView];
                UIView *contentView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, kHeaderHeight, result.height, frame.size.height)] autorelease];
                contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                [self addSubviewsToContentView:contentView];
                [self addSubview:contentView];
                
                footerToolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.f, gridView.height + 28, result.height, kFooterHeight - 12)] autorelease];
                // H: Populate buttons for footer toolbar
                [self populateFooter];
                
//                footerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, gridView.height + 30, result.height, kFooterHeight)] autorelease];
//                footerView.backgroundColor = [UIColor grayColor];
//                [self addSubviewsToFooterView:footerView];
                
                [self addSubview:footerToolBar];
            }
            else
            {
                headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320, kHeaderHeight)] autorelease];
                headerView.backgroundColor = [UIColor grayColor];
                [self addSubviewsToHeaderView:headerView];
                [self addSubview:headerView];
                UIView *contentView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, kHeaderHeight, 320, frame.size.height)] autorelease];
                contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                [self addSubviewsToContentView:contentView];
                [self addSubview:contentView];
                
                footerToolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.f, gridView.height + 28, 320, kFooterHeight)] autorelease];
                // H: Populate buttons for footer toolbar
                [self populateFooter];
                
//                footerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, gridView.height + 30, 320, kFooterHeight)] autorelease];
//                footerView.backgroundColor = [UIColor grayColor];
//                [self addSubviewsToFooterView:footerView];
                
                [self addSubview:footerToolBar];
            }
        }
    }
    return self;
}

- (void) populateFooter
{
    UIBarButtonItem *leftArrow = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Kal.bundle/kal_left_arrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showPreviousMonth)] autorelease];
    UIBarButtonItem *leftFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *todayButton = [[[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleBordered target:self action:@selector(setTodayDate)] autorelease];
    UIBarButtonItem *rightFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *rightArrow = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Kal.bundle/kal_right_arrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showFollowingMonth)] autorelease];
    
    footerToolBar.items = [NSArray arrayWithObjects:leftArrow,leftFlex,todayButton,rightFlex,rightArrow, nil];
}

- (id)initWithFrame:(CGRect)frame
{
    [NSException raise:@"Incomplete initializer" format:@"KalView must be initialized with a delegate and a KalLogic. Use the initWithFrame:delegate:logic: method."];
    return nil;
}

- (void)redrawEntireMonth { [self jumpToSelectedMonth]; }

- (void)slideDown { [gridView slideDown]; }
- (void)slideUp { [gridView slideUp]; }

- (void)showPreviousMonth
{
    if (!gridView.transitioning)
        [delegate showPreviousMonth];
}

- (void)showFollowingMonth
{
    if (!gridView.transitioning)
        [delegate showFollowingMonth];
}

- (void)addSubviewsToHeaderView:(UIView *)headerView1
{
//    const CGFloat kChangeMonthButtonWidth = 46.0f;
////    const CGFloat kChangeMonthButtonHeight = 30.0f;
////    const CGFloat kMonthLabelWidth = 200.0f;
//    const CGFloat kHeaderVerticalAdjust = 10.f;
    
    // Header background gradient
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Kal.bundle/kal_grid_background.png"]];
    CGRect imageFrame = headerView1.frame;
    imageFrame.origin = CGPointZero;
    backgroundView.frame = imageFrame;
    [headerView1 addSubview:backgroundView];
    [backgroundView release];
/*
    // Create the previous month button on the left side of the view
    CGRect previousMonthButtonFrame = CGRectMake(headerView1.frame.origin.x,
                                                 kHeaderVerticalAdjust,
                                                 kChangeMonthButtonWidth,
                                                 kHeaderHeight);
    UIButton *previousMonthButton = [[UIButton alloc] initWithFrame:previousMonthButtonFrame];
    [previousMonthButton setAccessibilityLabel:NSLocalizedString(@"Previous month", nil)];
    [previousMonthButton setImage:[UIImage imageNamed:@"Kal.bundle/kal_left_arrow.png"] forState:UIControlStateNormal];
    previousMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    previousMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    previousMonthButton.showsTouchWhenHighlighted = YES;
    [previousMonthButton addTarget:self action:@selector(showPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    [headerView1 addSubview:previousMonthButton];
    [previousMonthButton release];
    
    // Draw the selected month name centered and at the top of the view
    CGRect monthLabelFrame;
    if (isIpad)
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            monthLabelFrame = CGRectMake(0,
                                         kHeaderVerticalAdjust,
                                         1024,
                                         kMonthLabelHeight);
        }
        else
        {
            monthLabelFrame = CGRectMake(0,
                                         kHeaderVerticalAdjust,
                                         768,
                                         kMonthLabelHeight);
        }
    }
    else
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            monthLabelFrame = CGRectMake(0,
                                         kHeaderVerticalAdjust,
                                         result.height,
                                         kMonthLabelHeight);
        }
        else
        {
            monthLabelFrame = CGRectMake(0,
                                         kHeaderVerticalAdjust,
                                         320,
                                         kMonthLabelHeight);
        }
    }
    headerTitleLabel = [[UILabel alloc] initWithFrame:monthLabelFrame];
    
    headerTitleLabel.backgroundColor = [UIColor clearColor];
    headerTitleLabel.font = [UIFont boldSystemFontOfSize:22.f];
    headerTitleLabel.textAlignment = UITextAlignmentCenter;
    headerTitleLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Kal.bundle/kal_header_text_fill.png"]];
    headerTitleLabel.shadowColor = [UIColor whiteColor];
    headerTitleLabel.shadowOffset = CGSizeMake(0.f, 1.f);
    [self setHeaderTitleText:[logic selectedMonthNameAndYear]];
    [headerView1 addSubview:headerTitleLabel];
    
    // Create the next month button on the right side of the view
    CGRect nextMonthButtonFrame;
    if (isIpad)
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            nextMonthButtonFrame = CGRectMake(1024 - kChangeMonthButtonWidth,
                                              kHeaderVerticalAdjust,
                                              kChangeMonthButtonWidth,
                                              kHeaderHeight);
        }
        else
        {
            nextMonthButtonFrame = CGRectMake(768 - kChangeMonthButtonWidth,
                                              kHeaderVerticalAdjust,
                                              kChangeMonthButtonWidth,
                                              kHeaderHeight);
        }
    }
    else
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            nextMonthButtonFrame = CGRectMake(result.height - kChangeMonthButtonWidth,
                                              kHeaderVerticalAdjust,
                                              kChangeMonthButtonWidth,
                                              kHeaderHeight);
        }
        else
        {
            nextMonthButtonFrame = CGRectMake(320 - kChangeMonthButtonWidth,
                                              kHeaderVerticalAdjust,
                                              kChangeMonthButtonWidth,
                                              kHeaderHeight);
        }
    }
    
    UIButton *nextMonthButton = [[UIButton alloc] initWithFrame:nextMonthButtonFrame];
    [nextMonthButton setAccessibilityLabel:NSLocalizedString(@"Next month", nil)];
    [nextMonthButton setImage:[UIImage imageNamed:@"Kal.bundle/kal_right_arrow.png"] forState:UIControlStateNormal];
    nextMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    nextMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    nextMonthButton.showsTouchWhenHighlighted =YES;
    [nextMonthButton addTarget:self action:@selector(showFollowingMonth) forControlEvents:UIControlEventTouchUpInside];
    [headerView1 addSubview:nextMonthButton];
    [nextMonthButton release];
*/    
    // Add column labels for each weekday (adjusting based on the current locale's first weekday)
    NSArray *weekdayNames = [[[[NSDateFormatter alloc] init] autorelease] shortWeekdaySymbols];
    NSArray *fullWeekdayNames = [[[[NSDateFormatter alloc] init] autorelease] standaloneWeekdaySymbols];
    NSUInteger firstWeekday = [[NSCalendar currentCalendar] firstWeekday];
    NSUInteger i = firstWeekday - 1;
    if (isIpad)
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            for (CGFloat xOffset = 0.0f; xOffset < headerView1.width; xOffset += 146.50f, i = (i+1)%7)
            {
                CGRect weekdayFrame = CGRectMake(xOffset, 0.f, 146.50f, kHeaderHeight);
                UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:weekdayFrame];
                weekdayLabel.backgroundColor = [UIColor clearColor];
                weekdayLabel.font = [UIFont boldSystemFontOfSize:15.f];
                weekdayLabel.textAlignment = NSTextAlignmentCenter;
                if (i == 0)
                {
                    weekdayLabel.textColor = [UIColor colorWithRed:255.f green:0.f blue:0.f alpha:1.f];
                }
                else if ((i+1)%7 == 0)
                {
                    weekdayLabel.textColor = [UIColor colorWithRed:0.f green:0.f blue:255.f alpha:1.f];
                }
                else
                {
                    weekdayLabel.textColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.f];
                }
                weekdayLabel.shadowColor = [UIColor whiteColor];
                weekdayLabel.shadowOffset = CGSizeMake(0.f, 1.f);
                weekdayLabel.text = [weekdayNames objectAtIndex:i];
                [weekdayLabel setAccessibilityLabel:[fullWeekdayNames objectAtIndex:i]];
                [headerView1 addSubview:weekdayLabel];
                [weekdayLabel release];
            }
        }
        else
        {
            for (CGFloat xOffset = 0.0f; xOffset < headerView1.width; xOffset += 109.71f, i = (i+1)%7)
            {
                CGRect weekdayFrame = CGRectMake(xOffset, 0.f, 109.71f, kHeaderHeight);
                UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:weekdayFrame];
                weekdayLabel.backgroundColor = [UIColor clearColor];
                weekdayLabel.font = [UIFont boldSystemFontOfSize:15.f];
                weekdayLabel.textAlignment = NSTextAlignmentCenter;
                if (i == 0)
                {
                    weekdayLabel.textColor = [UIColor colorWithRed:255.f green:0.f blue:0.f alpha:1.f];
                }
                else if ((i+1)%7 == 0)
                {
                    weekdayLabel.textColor = [UIColor colorWithRed:0.f green:0.f blue:255.f alpha:1.f];
                }
                else
                {
                    weekdayLabel.textColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.f];
                }
                weekdayLabel.shadowColor = [UIColor whiteColor];
                weekdayLabel.shadowOffset = CGSizeMake(0.f, 1.f);
                weekdayLabel.text = [weekdayNames objectAtIndex:i];
                [weekdayLabel setAccessibilityLabel:[fullWeekdayNames objectAtIndex:i]];
                [headerView1 addSubview:weekdayLabel];
                [weekdayLabel release];
            }
        }
    }
    else
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            for (CGFloat xOffset = 0.0f; xOffset < headerView1.width; xOffset += result.height/7, i = (i+1)%7)
            {
                CGRect weekdayFrame = CGRectMake(xOffset, 0.f, result.height/7, kHeaderHeight);
                UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:weekdayFrame];
                weekdayLabel.backgroundColor = [UIColor clearColor];
                weekdayLabel.font = [UIFont boldSystemFontOfSize:10.f];
                weekdayLabel.textAlignment = NSTextAlignmentCenter;
                if (i == 0)
                {
                    weekdayLabel.textColor = [UIColor colorWithRed:255.f green:0.f blue:0.f alpha:1.f];
                }
                else if ((i+1)%7 == 0)
                {
                    weekdayLabel.textColor = [UIColor colorWithRed:0.f green:0.f blue:255.f alpha:1.f];
                }
                else
                {
                    weekdayLabel.textColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.f];
                }
                weekdayLabel.shadowColor = [UIColor whiteColor];
                weekdayLabel.shadowOffset = CGSizeMake(0.f, 1.f);
                weekdayLabel.text = [weekdayNames objectAtIndex:i];
                [weekdayLabel setAccessibilityLabel:[fullWeekdayNames objectAtIndex:i]];
                [headerView1 addSubview:weekdayLabel];
                [weekdayLabel release];
            }
        }
        else
        {
            for (CGFloat xOffset = 0.0f; xOffset < headerView1.width; xOffset += 46.f, i = (i+1)%7)
            {
                CGRect weekdayFrame = CGRectMake(xOffset, 0.f, 46.f, kHeaderHeight);
                UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:weekdayFrame];
                weekdayLabel.backgroundColor = [UIColor clearColor];
                weekdayLabel.font = [UIFont boldSystemFontOfSize:10.f];
                weekdayLabel.textAlignment = NSTextAlignmentCenter;
                if (i == 0)
                {
                    weekdayLabel.textColor = [UIColor colorWithRed:255.f green:0.f blue:0.f alpha:1.f];
                }
                else if ((i+1)%7 == 0)
                {
                    weekdayLabel.textColor = [UIColor colorWithRed:0.f green:0.f blue:255.f alpha:1.f];
                }
                else
                {
                    weekdayLabel.textColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.f];
                }
                weekdayLabel.shadowColor = [UIColor whiteColor];
                weekdayLabel.shadowOffset = CGSizeMake(0.f, 1.f);
                weekdayLabel.text = [weekdayNames objectAtIndex:i];
                [weekdayLabel setAccessibilityLabel:[fullWeekdayNames objectAtIndex:i]];
                [headerView1 addSubview:weekdayLabel];
                [weekdayLabel release];
            }
        }
    }
}

- (void)addSubviewsToContentView:(UIView *)contentView
{
    // Both the tile grid and the list of events will automatically lay themselves
    // out to fit the # of weeks in the currently displayed month.
    // So the only part of the frame that we need to specify is the width.+
    
    CGRect fullWidthAutomaticLayoutFrame;
    
    if (isIpad)
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            fullWidthAutomaticLayoutFrame = CGRectMake(0.f, 0.f, 1024.0f, 0.f);
        }
        else
        {
            fullWidthAutomaticLayoutFrame = CGRectMake(0.f, 0.f, 768.0f, 0.f);
        }
    }
    else
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            fullWidthAutomaticLayoutFrame = CGRectMake(0.f, 0.f, result.height, 0.f);
        }
        else
        {
            fullWidthAutomaticLayoutFrame = CGRectMake(0.f, 0.f, 320.0f, 0.f);
        }
    }    
    
    // The tile grid (the calendar body)
    gridView = [[KalGridView alloc] initWithFrame:fullWidthAutomaticLayoutFrame logic:logic delegate:delegate];
    [gridView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    [contentView addSubview:gridView];
    
    // The list of events for the selected day
    tableView = [[UITableView alloc] initWithFrame:fullWidthAutomaticLayoutFrame style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //    [contentView addSubview:tableView];
    
    // Drop shadow below tile grid and over the list of events for the selected day
    //    shadowView = [[UIImageView alloc] initWithFrame:fullWidthAutomaticLayoutFrame];
    //    shadowView.image = [UIImage imageNamed:@"Kal.bundle/kal_grid_shadow.png"];
    //    shadowView.height = shadowView.image.size.height;
    //    [contentView addSubview:shadowView];
    
    // Trigger the initial KVO update to finish the contentView layout
    [gridView sizeToFit];
}

- (void)addSubviewsToFooterView:(UIView *)headerView1
{
    const CGFloat kChangeMonthButtonWidth = 46.0f;
 
    // Header background gradient
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Kal.bundle/kal_grid_background.png"]];
    CGRect imageFrame = headerView1.frame;
    imageFrame.origin = CGPointZero;
    backgroundView.frame = imageFrame;
    [headerView1 addSubview:backgroundView];
    [backgroundView release];
    
   // Create the previous month button on the left side of the view
    CGRect previousMonthButtonFrame = CGRectMake(headerView1.frame.origin.x,
                                                 0.f,
                                                 kChangeMonthButtonWidth,
                                                 kFooterHeight);
    UIButton *previousMonthButton = [[UIButton alloc] initWithFrame:previousMonthButtonFrame];
    [previousMonthButton setAccessibilityLabel:NSLocalizedString(@"Previous month", nil)];
    [previousMonthButton setImage:[UIImage imageNamed:@"Kal.bundle/kal_left_arrow.png"] forState:UIControlStateNormal];
    previousMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    previousMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    previousMonthButton.showsTouchWhenHighlighted = YES;
    [previousMonthButton addTarget:self action:@selector(showPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    [headerView1 addSubview:previousMonthButton];
    [previousMonthButton release];

    // Create the Today button on the left side of the view
    CGRect todayButtonFrame = CGRectMake(headerView1.frame.size.width/2 - 35 ,
                                         0.f,
                                         70,
                                         kFooterHeight);
    UIButton * todayButton;
    todayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[todayButton setFrame:todayButtonFrame];
//    [todayButton setBackgroundImage:[UIImage imageNamed:@"today_btn.png"] forState:UIControlStateNormal];
	[todayButton setTitle:(@"Today") forState:UIControlStateNormal];
    todayButton.backgroundColor = [UIColor colorWithRed:72/255.f green:90/255.f blue:108/255.f alpha:1.0f];
    todayButton.layer.cornerRadius = 10;
    todayButton.showsTouchWhenHighlighted = YES;
 	[todayButton addTarget:self action:@selector(setTodayDate) forControlEvents:UIControlEventTouchUpInside];
    todayButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    todayButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [headerView1 addSubview:todayButton];
    
    // Create the next month button on the right side of the view
    CGRect nextMonthButtonFrame;
    if (isIpad)
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            nextMonthButtonFrame = CGRectMake(1024 - kChangeMonthButtonWidth,
                                              0.f,
                                              kChangeMonthButtonWidth,
                                              kFooterHeight);
        }
        else
        {
            nextMonthButtonFrame = CGRectMake(768 - kChangeMonthButtonWidth,
                                              0.f,
                                              kChangeMonthButtonWidth,
                                              kFooterHeight);
        }
    }
    else
    {
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            nextMonthButtonFrame = CGRectMake(result.height - kChangeMonthButtonWidth,
                                              0.f,
                                              kChangeMonthButtonWidth,
                                              kFooterHeight);
        }
        else
        {
            nextMonthButtonFrame = CGRectMake(320 - kChangeMonthButtonWidth,
                                              0.f,
                                              kChangeMonthButtonWidth,
                                              kFooterHeight);
        }
    }
    
    UIButton *nextMonthButton = [[UIButton alloc] initWithFrame:nextMonthButtonFrame];
    [nextMonthButton setAccessibilityLabel:NSLocalizedString(@"Next month", nil)];
    [nextMonthButton setImage:[UIImage imageNamed:@"Kal.bundle/kal_right_arrow.png"] forState:UIControlStateNormal];
    nextMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    nextMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    nextMonthButton.showsTouchWhenHighlighted =YES;
    [nextMonthButton addTarget:self action:@selector(showFollowingMonth) forControlEvents:UIControlEventTouchUpInside];
    [headerView1 addSubview:nextMonthButton];
    [nextMonthButton release];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == gridView && [keyPath isEqualToString:@"frame"]) {
        
        /* Animate tableView filling the remaining space after the
         * gridView expanded or contracted to fit the # of weeks
         * for the month that is being displayed.
         *
         * This observer method will be called when gridView's height
         * changes, which we know to occur inside a Core Animation
         * transaction. Hence, when I set the "frame" property on
         * tableView here, I do not need to wrap it in a
         * [UIView beginAnimations:context:].
         */
        CGFloat gridBottom = gridView.top + gridView.height;
        CGRect frame = tableView.frame;
        frame.origin.y = gridBottom;
        frame.size.height = tableView.superview.height - gridBottom;
        tableView.frame = frame;
        shadowView.top = gridBottom;
        CGSize result = [[UIScreen mainScreen] bounds].size;
        footerView.frame = CGRectMake(0.f, gridView.height + 30, result.height, kFooterHeight);
    }
    else if ([keyPath isEqualToString:@"selectedMonthNameAndYear"])
    {
        [self setHeaderTitleText:[change objectForKey:NSKeyValueChangeNewKey]];        
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// Get Today
-(void)setTodayDate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setTodayDate" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setTodayDate" object:nil];
}

- (void)setHeaderTitleText:(NSString *)text
{
    [headerTitleLabel setText:text];
    //    [headerTitleLabel sizeToFit];
    //headerTitleLabel.left = floorf(self.width/2.f - headerTitleLabel.width/2.f);
}

- (void)jumpToSelectedMonth { [gridView jumpToSelectedMonth]; }

- (void)selectDate:(KalDate *)date { [gridView selectDate:date]; }

- (BOOL)isSliding { return gridView.transitioning; }

- (void)markTilesForDates:(NSArray *)dates { [gridView markTilesForDates:dates]; }

- (KalDate *)selectedDate { return gridView.selectedDate; }

- (void)dealloc
{
    [logic removeObserver:self forKeyPath:@"selectedMonthNameAndYear"];
    [logic release];
    
    [headerTitleLabel release];
    [gridView removeObserver:self forKeyPath:@"frame"];
    [gridView release];
    [tableView release];
    [shadowView release];
    [super dealloc];
}

@end
