//
//  TaskCell.h
//  zTask
//
//  Created by ming lin on 6/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "Project.h"
#import "ToggleImageControl.h"

@interface TaskCell : UITableViewCell <ToggleImageDelegate>

@property(nonatomic, retain) Task *task;
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *projectLabel;
@property(nonatomic, retain) IBOutlet ToggleImageControl *statusControl;
@property(nonatomic, retain) IBOutlet UIImageView *flagImageView;

@end
