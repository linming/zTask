//
//  WeekView.h
//  zTask
//
//  Created by ming lin on 7/22/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KalTileView.h"

@protocol WeekViewDelegate;

@interface WeekView : UIView
{
    UILabel *headerTitleLabel;
    UIView *weekGridView;
    
    KalTileView *selectedTile;
    KalTileView *highlightedTile;
    
    BOOL isWeekReport;
}

@property(nonatomic, retain) NSDate *selectedDate;
@property(nonatomic, retain) NSArray *weekdays;
@property (nonatomic, assign) id<WeekViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame date:(NSDate *)_selectedDate delegate:_delegate;
- (void)setIsWeekReport:(BOOL)_isWeekReport;
- (BOOL)isWeekReport;

@end

@protocol WeekViewDelegate

- (void)selectedDateChanged:(NSDate *)_selectedDate;

@end
