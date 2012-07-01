//
//  AVMeterView.h
//  GoodQuestion
//
//  Created by linming on 6/18/11.
//  Copyright 2011 mingidea. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LevelMeter.h"


#define kPeakFalloffPerSec	.7
#define kLevelFalloffPerSec .8
#define kMinDBvalue -80.0

@interface AVMeterView : UIView {
    BOOL updating;
    
    LevelMeter *levelMeter;
    
    NSTimer						*_updateTimer;
    
    CFAbsoluteTime				_peakFalloffLastFire;
}

- (void)startUpdating;
- (void)stopUpdating;

@property(nonatomic,assign)	AVAudioPlayer *audioPlayer;
@property(nonatomic,assign)	AVAudioRecorder *audioRecorder;

@end
