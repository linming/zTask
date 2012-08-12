//
//  TaskCell.m
//  zTask
//
//  Created by ming lin on 6/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "TaskCell.h"

@implementation TaskCell

@synthesize task, statusControl, titleLabel, projectLabel, flagImageView, completedLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        statusControl = [[ToggleImageControl alloc] initWithFrame: CGRectMake(10, 10, 24, 24) status:NO];
        statusControl.delegate = self;
        [self.contentView addSubview: statusControl];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 5, 250, 24)];
        [self.contentView addSubview:titleLabel];
        
        projectLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 29, 100, 13)];
        projectLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        projectLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:projectLabel];
        
        flagImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flag.png"]];
        flagImageView.frame = CGRectMake(300, 6, 16, 16);
        [self.contentView addSubview:flagImageView];
        
        completedLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 29, 70, 13)];
        completedLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        completedLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:completedLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setTask:(Task *)newTask {
    if (newTask != task) {
        task = newTask;
	}
    titleLabel.text = newTask.title;
    if (task.projectId) {
        Project *project = [Project find:task.projectId];
        projectLabel.text = [NSString stringWithFormat:@"%@", project.name];
    } else {
         projectLabel.text = @"";
    }
    
    if (task.flag) {
        flagImageView.frame = CGRectMake(300, 6, 16, 16);
    } else {
        flagImageView.frame = CGRectMake(0, 0, 0, 0);
    }
    
    if (task.status && task.completed) {
        completedLabel.text = [NSString stringWithFormat:@"%@", [task getCompletedStr] ];
        titleLabel.textColor = [UIColor grayColor];
    } else {
        completedLabel.text = @"";
        titleLabel.textColor = [UIColor blackColor];
    }
    
    [statusControl setIsSelected:task.status];
}

- (void)imageToggled:(BOOL)status
{
    task.status = status;
    task.completed = [NSDate date];
    [Task update:task];
}

@end
