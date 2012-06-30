//
//  TaskCell.h
//  zTask
//
//  Created by ming lin on 6/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "ToggleImageControl.h"

@interface TaskCell : UITableViewCell

@property(nonatomic, retain) Task *task;
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet ToggleImageControl *statusControl;

@end
