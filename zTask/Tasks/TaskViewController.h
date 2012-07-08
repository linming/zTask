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

@interface TaskViewController : UITableViewController <HPGrowingTextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextFieldDelegate>
{
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    AVPlayerMeterView *playerMeterView;
    AVRecorderMeterView *recorderMeterView;
    
    Task *task;
    NSMutableArray *attaches;
    
    UIView *taskViewHeaderContainer;
    HPGrowingTextView *titleTextView;
    
    UILabel *projectLabel;
    UITextField *dueDateTextField;
    UIDatePicker *dueDatePicker;
    
    UIButton *editButton;
    UIButton *recordAudioButton;
    UISwitch *flagSwitch;
}

@property NSInteger taskId;

- (void)updateProject:(NSInteger)projectId projectName:(NSString *)projectName;
- (void)updateNote:(NSString *)note;

@end
