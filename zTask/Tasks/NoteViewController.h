//
//  NoteViewController.h
//  zTask
//
//  Created by ming lin on 6/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskViewController.h"

@interface NoteViewController : UIViewController

@property (nonatomic, retain) TaskViewController *taskViewController;

@property (nonatomic, retain) NSString *taskTitle;
@property (nonatomic, retain) NSString *taskNote;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIView *titleView;
@property (nonatomic, retain) IBOutlet UITextView *noteTextView;

@end
