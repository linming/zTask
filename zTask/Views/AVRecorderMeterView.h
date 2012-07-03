//
//  AVRecorderMeterView.h
//  zTask
//
//  Created by ming lin on 7/2/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LevelMeter.h"


#define kPeakFalloffPerSec	.7
#define kLevelFalloffPerSec .8
#define kMinDBvalue -80.0

@interface AVRecorderMeterView : UIView {
    BOOL updating;
    
    LevelMeter *levelMeter;
    
    NSTimer						*_updateTimer;
    
    CFAbsoluteTime				_peakFalloffLastFire;
}

- (void)startUpdating;
- (void)stopUpdating;

@property(nonatomic,assign)	AVAudioRecorder *audioRecorder;

@end
