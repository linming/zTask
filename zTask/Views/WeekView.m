//
//  WeekView.m
//  zTask
//
//  Created by ming lin on 7/22/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "WeekView.h"
#import "DateUtil.h"
#import "KalGridView.h"
#import "KalLogic.h"
#import "KalTileView.h"
#import "KalDate.h"

@implementation WeekView

@synthesize selectedDate, weekdays, delegate;

- (id)initWithFrame:(CGRect)frame date:(NSDate *)_selectedDate delegate:_delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        selectedDate = _selectedDate;
        delegate = _delegate;
        weekdays = [DateUtil getWeekdays:selectedDate];
        [self initHeaderView];
        [self initTileView];
    }
    return self;
}

- (void)setSelectedDate:(NSDate *)_selectedDate
{
    selectedDate = _selectedDate;
    [self updateView];
}

- (void)setIsWeekReport:(BOOL)_isWeekReport
{
    isWeekReport = _isWeekReport;
    [self updateView];
}

- (BOOL)isWeekReport
{
    return isWeekReport;
}

- (void)updateView
{
    weekdays = [DateUtil getWeekdays:selectedDate];
    if (isWeekReport) {
        headerTitleLabel.font = [UIFont boldSystemFontOfSize:17.f];
        headerTitleLabel.text = [NSString stringWithFormat:@"%@ ~ %@",
                                 [DateUtil formatDate:[weekdays objectAtIndex:0] to:@"MMM d"],
                                 [DateUtil formatDate:[weekdays objectAtIndex:6] to:@"MMM d, yyyy"]];
    } else {
        headerTitleLabel.font = [UIFont boldSystemFontOfSize:22.f];
        headerTitleLabel.text = [DateUtil formatDate:selectedDate to:@"MMM d, yyyy"];
    }
    
    
    NSArray *tileViews = [weekGridView subviews];
    KalDate *kalSelectedDate = [KalDate dateFromNSDate:selectedDate];
    
    for (int j = 0; j < 7; j++) {
        NSDate *weekday = [weekdays objectAtIndex:j];
        KalDate *kalDate = [KalDate dateFromNSDate:weekday];
        
        KalTileView *tileView = [tileViews objectAtIndex:j];
        tileView.date = kalDate;
        tileView.type = KalTileTypeRegular;
        
        if (!isWeekReport && [kalDate compare:kalSelectedDate] == NSOrderedSame) {
            tileView.selected = YES;
        } else {
            tileView.selected = NO;
        }
        
        if ([kalDate isToday]) {
            tileView.type = KalTileTypeToday;
        }
    }
    
    [delegate selectedDateChanged:selectedDate];
}


- (void)initHeaderView
{
    const CGFloat kHeaderHeight = 44.f;
    const CGFloat kMonthLabelHeight = 27.f;
    const CGFloat kChangeMonthButtonWidth = 46.0f;
    const CGFloat kChangeMonthButtonHeight = 30.0f;
    const CGFloat kMonthLabelWidth = 200.0f;
    const CGFloat kHeaderVerticalAdjust = 3.f;
    
    // Header background gradient
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Kal.bundle/kal_grid_background.png"]];
    backgroundView.frame = CGRectMake(0, 0, 320, 44);
    [self addSubview:backgroundView];
    
    // Create the previous month button on the left side of the view
    CGRect previousMonthButtonFrame = CGRectMake(self.frame.origin.x,
                                                 kHeaderVerticalAdjust,
                                                 kChangeMonthButtonWidth,
                                                 kChangeMonthButtonHeight);
    UIButton *previousMonthButton = [[UIButton alloc] initWithFrame:previousMonthButtonFrame];
    [previousMonthButton setAccessibilityLabel:NSLocalizedString(@"Previous month", nil)];
    [previousMonthButton setImage:[UIImage imageNamed:@"Kal.bundle/kal_left_arrow.png"] forState:UIControlStateNormal];
    previousMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    previousMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [previousMonthButton addTarget:self action:@selector(showPreviousWeek) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:previousMonthButton];
    
    // Draw the selected month name centered and at the top of the view
    CGRect monthLabelFrame = CGRectMake((self.frame.size.width/2.0f) - (kMonthLabelWidth/2.0f),
                                        kHeaderVerticalAdjust,
                                        kMonthLabelWidth,
                                        kMonthLabelHeight);
    headerTitleLabel = [[UILabel alloc] initWithFrame:monthLabelFrame];
    headerTitleLabel.backgroundColor = [UIColor clearColor];
    headerTitleLabel.font = [UIFont boldSystemFontOfSize:22.f];
    headerTitleLabel.textAlignment = UITextAlignmentCenter;
    headerTitleLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Kal.bundle/kal_header_text_fill.png"]];
    headerTitleLabel.shadowColor = [UIColor whiteColor];
    headerTitleLabel.shadowOffset = CGSizeMake(0.f, 1.f);
    headerTitleLabel.text = [DateUtil formatDate:selectedDate to:@"MMM d, yyyy"];
    [self addSubview:headerTitleLabel];
    
    // Create the next month button on the right side of the view
    CGRect nextMonthButtonFrame = CGRectMake(self.frame.size.width - kChangeMonthButtonWidth,
                                             kHeaderVerticalAdjust,
                                             kChangeMonthButtonWidth,
                                             kChangeMonthButtonHeight);
    UIButton *nextMonthButton = [[UIButton alloc] initWithFrame:nextMonthButtonFrame];
    [nextMonthButton setAccessibilityLabel:NSLocalizedString(@"Next month", nil)];
    [nextMonthButton setImage:[UIImage imageNamed:@"Kal.bundle/kal_right_arrow.png"] forState:UIControlStateNormal];
    nextMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    nextMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [nextMonthButton addTarget:self action:@selector(showFollowingWeek) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextMonthButton];
    
    // Add column labels for each weekday (adjusting based on the current locale's first weekday)
    NSArray *weekdayNames = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
    NSArray *fullWeekdayNames = [[[NSDateFormatter alloc] init] standaloneWeekdaySymbols];
    NSUInteger firstWeekday = [[NSCalendar currentCalendar] firstWeekday];
    NSUInteger i = firstWeekday - 1;
    for (CGFloat xOffset = 0.f; xOffset < self.frame.size.width; xOffset += 46.f, i = (i+1)%7) {
        CGRect weekdayFrame = CGRectMake(xOffset, 30.f, 46.f, kHeaderHeight - 29.f);
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:weekdayFrame];
        weekdayLabel.backgroundColor = [UIColor clearColor];
        weekdayLabel.font = [UIFont boldSystemFontOfSize:10.f];
        weekdayLabel.textAlignment = UITextAlignmentCenter;
        weekdayLabel.textColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.f];
        weekdayLabel.shadowColor = [UIColor whiteColor];
        weekdayLabel.shadowOffset = CGSizeMake(0.f, 1.f);
        weekdayLabel.text = [weekdayNames objectAtIndex:i];
        [weekdayLabel setAccessibilityLabel:[fullWeekdayNames objectAtIndex:i]];
        [self addSubview:weekdayLabel];
    }
}

- (void)initTileView
{
    weekGridView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, 44)];
    KalDate *kalSelectedDate = [KalDate dateFromNSDate:selectedDate];
    for (int j = 0; j < 7; j++) {
        NSDate *weekday = [weekdays objectAtIndex:j];
        KalDate *kalDate = [KalDate dateFromNSDate:weekday];
        
        KalTileView *tileView = [[KalTileView alloc] initWithFrame:CGRectMake(j * 46, 0, 46, 44)];
        tileView.date = kalDate;
        tileView.type = KalTileTypeRegular;
    
        if ([kalDate compare:kalSelectedDate] == NSOrderedSame) {
            tileView.selected = YES;
            selectedTile = tileView;
        }
        
        if ([kalDate isToday]) {
            tileView.type = KalTileTypeToday;
        }
        [weekGridView addSubview: tileView];
    }
    [self addSubview:weekGridView];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[UIImage imageNamed:@"Kal.bundle/kal_grid_background.png"] drawInRect:CGRectMake(0, 44, 320, 44)];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClipToRect(ctx, CGRectMake(0.0, 44, 320, 44));
    CGContextDrawTiledImage(ctx, CGRectMake(0, 0, 46, 44), [[UIImage imageNamed:@"Kal.bundle/kal_tile.png"] CGImage]);
}


#pragma mark
- (void)showPreviousWeek
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setWeek: -1];
    selectedDate = [gregorian dateByAddingComponents:comps toDate:selectedDate options:0];
    [self updateView];
}

- (void)showFollowingWeek
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setWeek: 1];
    selectedDate = [gregorian dateByAddingComponents:comps toDate:selectedDate options:0];
    [self updateView];
}


#pragma mark -
#pragma mark Touches

- (void)setHighlightedTile:(KalTileView *)tile
{
    if (highlightedTile != tile) {
        highlightedTile.highlighted = NO;
        highlightedTile = tile;
        tile.highlighted = YES;
        [tile setNeedsDisplay];
    }
}

- (void)setSelectedTile:(KalTileView *)tile
{
    if (selectedTile != tile) {
        selectedTile.selected = NO;
        selectedTile = tile;
        tile.selected = YES;
        self.selectedDate = [tile.date NSDate];
    }
}

- (void)receivedTouches:(NSSet *)touches withEvent:event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *hitView = [self hitTest:location withEvent:event];
    
    if (!hitView)
        return;
    
    if ([hitView isKindOfClass:[KalTileView class]]) {
        KalTileView *tile = (KalTileView*)hitView;
        if (tile.belongsToAdjacentMonth) {
            self.highlightedTile = tile;
        } else {
            self.highlightedTile = nil;
            self.selectedTile = tile;
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self receivedTouches:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self receivedTouches:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *hitView = [self hitTest:location withEvent:event];
    
    if ([hitView isKindOfClass:[KalTileView class]]) {
        KalTileView *tile = (KalTileView*)hitView;
        self.selectedTile = tile;
    }
    self.highlightedTile = nil;
}



@end
