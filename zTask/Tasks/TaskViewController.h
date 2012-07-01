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
#import "AVMeterView.h"

@interface TaskViewController : UITableViewController <HPGrowingTextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    AVMeterView *meterView;
    
    Task *task;
    NSMutableArray *attaches;
    
    UIView *taskViewHeaderContainer;
    HPGrowingTextView *titleTextView;
}

@property BOOL isEdit;
@property NSInteger taskId;
@property(nonatomic, retain) IBOutlet UIButton *editButton;
@property(nonatomic, retain) IBOutlet UIButton *recordAudioButton;

- (void)save;
- (void)cancel;

- (void)showDetail;

- (void)removeAttach:(Attach *)attach;

- (void)takePhoto;
- (void)pickPhoto;

- (void)prepareAudio:(NSString *)path;
- (void)playAudio:(Attach *)attach;
- (void)recordAudio;
- (void)stopAudio;
- (void)stopAll;

@end
