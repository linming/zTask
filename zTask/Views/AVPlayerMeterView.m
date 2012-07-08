//
//  AVPlayerMeterView.m
//  zTask
//
//  Created by ming lin on 7/2/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "AVPlayerMeterView.h"

@implementation AVPlayerMeterView

@synthesize audioPlayer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        levelMeter = [[LevelMeter alloc] initWithFrame:frame];
        levelMeter.numLights = 36;
		levelMeter.vertical = NO;
		levelMeter.bgColor = [[UIColor alloc] initWithRed:.39 green:.44 blue:.57 alpha:.5];
		levelMeter.borderColor = [[UIColor alloc] initWithRed:.39 green:.44 blue:.57 alpha:.5];
        [self addSubview:levelMeter];
    }
    return self;
}



- (void)_refresh
{
	BOOL success = NO;
    
	// if we have no queue, but still have levels, gradually bring them down
	if (audioPlayer == nil)
	{
        //NSLog(@"record is nil");
		CGFloat maxLvl = -1.;
		CFAbsoluteTime thisFire = CFAbsoluteTimeGetCurrent();
		// calculate how much time passed since the last draw
		CFAbsoluteTime timePassed = thisFire - _peakFalloffLastFire;
        
        CGFloat newPeak, newLevel;
        newLevel = levelMeter.level - timePassed * kLevelFalloffPerSec;
        if (newLevel < 0.) newLevel = 0.;
        levelMeter.level = newLevel;
        
        newPeak = levelMeter.peakLevel - timePassed * kPeakFalloffPerSec;
        if (newPeak < 0.) newPeak = 0.;
        levelMeter.peakLevel = newPeak;
        if (newPeak > maxLvl) maxLvl = newPeak;
        
        
        [levelMeter setNeedsDisplay];
        
		// stop the timer when the last level has hit 0
		if (maxLvl <= 0.)
		{
			[_updateTimer invalidate];
			_updateTimer = nil;
		}
		
		_peakFalloffLastFire = thisFire;
		success = YES;
        //NSLog(@"record is nil end.");
	} else {
        
        float db;
        float averagePower, peakPower;
        [ audioPlayer updateMeters ];
        db = [ audioPlayer peakPowerForChannel: 0];
        //NSLog(@"playing ori peak power: %f", db);
        peakPower = (50.0 + db) / 50.0;
        db = [ audioPlayer averagePowerForChannel: 0 ];
        //NSLog(@"ori average power: %f", db);
        averagePower = (50.0 + db) / 50.0;
        //NSLog(@"Power for channel %d: %f DB %f Peak: %f\n", 0, averagePower, db, peakPower);
        
        levelMeter.level = averagePower;
        levelMeter.peakLevel = peakPower;
        [levelMeter setNeedsDisplay];
        success = YES;
	}
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)__drawRect:(CGRect)rect
{
    float averagePower, peakPower;
    float cachedAveragePower = 0.0, cachedPeakPower;
    /* Read meter values */
	if (!audioPlayer || audioPlayer.meteringEnabled == NO) {
		averagePower = 0.0;
		peakPower = cachedPeakPower = 0.0;
	} else {
        float db;
        [ audioPlayer updateMeters ];
        db = [ audioPlayer peakPowerForChannel: 0];
        
        peakPower = (50.0 + db) / 50.0;
        db = [ audioPlayer averagePowerForChannel: 0 ];
        
        averagePower = (50.0 + db) / 50.0;
        //NSLog(@"Power for channel %d: %f DB %f Peak: %f\n", 0, averagePower, db, peakPower);
	}
    
    if (averagePower > cachedAveragePower) {
        cachedAveragePower = averagePower;
    } 
    cachedAveragePower -= .05;
    if (cachedAveragePower < 0) {
        cachedAveragePower = 0;
    }
    
    if (peakPower > cachedPeakPower) {
        cachedPeakPower = peakPower;
    } 
    cachedPeakPower -= .01;
    if (cachedPeakPower < 0.0) {
        cachedPeakPower = 0.0;
    }
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextAddRect(context, CGRectMake(3, 3, 200 *  averagePower, 19));
    CGContextDrawPath(context, kCGPathFillStroke);
    
    if (updating == YES) {
		[ NSTimer scheduledTimerWithTimeInterval: 1
                                          target: self
                                        selector: @selector(handleTimer:)
                                        userInfo: nil
                                         repeats: NO ];
	}
}

- (void)handleTimer:(NSTimer *)timer {
	[ self setNeedsDisplay ];
}

- (void)startUpdating {
	updating = YES;
    audioPlayer.meteringEnabled = YES;
	[ self setNeedsDisplay ];
    
    if (updating == YES) {
		_updateTimer = [ NSTimer scheduledTimerWithTimeInterval: 0.01
                                                         target: self
                                                       selector: @selector(_refresh)
                                                       userInfo: nil
                                                        repeats: YES ];
	}
    
}

- (void)stopUpdating {
	updating = NO;
    audioPlayer.meteringEnabled = NO;
	[self setNeedsDisplay];
}



@end
