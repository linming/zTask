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

@interface TaskViewController : UITableViewController <HPGrowingTextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    AVPlayerMeterView *playerMeterView;
    AVRecorderMeterView *recorderMeterView;
    
    Task *task;
    NSMutableArray *attaches;
    NSString *attachPath;
    
    UIView *taskViewHeaderContainer;
    HPGrowingTextView *titleTextView;
}

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
