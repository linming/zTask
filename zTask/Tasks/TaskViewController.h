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

@interface TaskViewController : UITableViewController <HPGrowingTextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    
    NSMutableArray *attaches;
}

@property BOOL isEdit;
@property(nonatomic, retain) IBOutlet UIButton *editButton;
@property(nonatomic, retain) IBOutlet UIButton *recordAudioButton;

- (void)save;
- (void)cancel;

- (IBAction)showDetail:(id)sender;

- (void)removeAttach:(Attach *)attach;

- (IBAction)takePhoto:(id)sender;
- (IBAction)pickPhoto:(id)sender;

- (void)prepareAudio:(NSString *)path;
- (void)playAudio:(Attach *)attach;
- (IBAction)recordAudio:(id)sender;
- (IBAction)stopAudio:(id)sender;
- (void)stopAll;

@end
