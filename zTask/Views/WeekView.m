//
//  WeekView.m
//  zTask
//
//  Created by ming lin on 7/22/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "WeekView.h"

static const CGFloat kHeaderHeight = 44.f;
static const CGFloat kMonthLabelHeight = 17.f;

@implementation WeekView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor redColor];
        [self addSubviewsToHeaderView];
        NSLog(@"week view init");
    }
    return self;
}

- (void)addSubviewsToHeaderView
{
    const CGFloat kChangeMonthButtonWidth = 46.0f;
    const CGFloat kChangeMonthButtonHeight = 30.0f;
    const CGFloat kMonthLabelWidth = 200.0f;
    const CGFloat kHeaderVerticalAdjust = 3.f;
    
    // Header background gradient
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Kal.bundle/kal_grid_background.png"]];
    CGRect imageFrame = self.frame;
    imageFrame.origin = CGPointZero;
    backgroundView.frame = imageFrame;
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
    [previousMonthButton addTarget:self action:@selector(showPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:previousMonthButton];
    
    // Draw the selected month name centered and at the top of the view
    CGRect monthLabelFrame = CGRectMake((self.frame.size.width/2.0f) - (kMonthLabelWidth/2.0f),
                                        kHeaderVerticalAdjust,
                                        kMonthLabelWidth,
                                        kMonthLabelHeight);
    UILabel *headerTitleLabel = [[UILabel alloc] initWithFrame:monthLabelFrame];
    headerTitleLabel.backgroundColor = [UIColor clearColor];
    headerTitleLabel.font = [UIFont boldSystemFontOfSize:22.f];
    headerTitleLabel.textAlignment = UITextAlignmentCenter;
    headerTitleLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Kal.bundle/kal_header_text_fill.png"]];
    headerTitleLabel.shadowColor = [UIColor whiteColor];
    headerTitleLabel.shadowOffset = CGSizeMake(0.f, 1.f);
    headerTitleLabel.text = @"Jul 22, 2012";
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
    [nextMonthButton addTarget:self action:@selector(showFollowingMonth) forControlEvents:UIControlEventTouchUpInside];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
