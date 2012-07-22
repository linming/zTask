//
//  TaskViewController.h
//  zTask
//
//  Created by ming lin on 6/28/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "HPGrowingTextView.h"
#import "Task.h"
#import "Attach.h"
#import "AVPlayerMeterView.h"
#import "AVRecorderMeterView.h"
#import "ToggleImageControl.h"
#import "ZoomImageView.h"

@interface TaskViewController : UITableViewController <HPGrowingTextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextFieldDelegate>
{
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    AVPlayerMeterView *playerMeterView;
    AVRecorderMeterView *recorderMeterView;
    
    Task *task;
    NSMutableArray *attaches;
    
    ToggleImageControl *statusControl;
    UIView *taskViewHeaderContainer;
    HPGrowingTextView *titleTextView;
    
    UILabel *projectLabel;
    UITextField *dueDateTextField;
    UITextField *finishDateTextField;
    
    UIDatePicker *dueDatePicker;
    UIDatePicker *finishDatePicker;
    
    UIButton *editButton;
    UIButton *recordAudioButton;
    UISwitch *flagSwitch;
    
    ZoomImageView *zoomImageView;
}

@property NSInteger taskId;

- (void)updateProject:(NSInteger)projectId projectName:(NSString *)projectName;
- (void)updateNote:(NSString *)note;

@end
