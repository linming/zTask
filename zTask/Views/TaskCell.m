//
//  TaskCell.m
//  zTask
//
//  Created by ming lin on 6/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "TaskCell.h"

@implementation TaskCell

@synthesize task, statusControl, titleLabel, projectLabel, flagImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        statusControl = [[ToggleImageControl alloc] initWithFrame: CGRectMake(10, 10, 24, 24) status:NO];
        //toggleControl.tag = indexPath.row;  // for reference in notifications.
        [self.contentView addSubview: statusControl];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 6, 250, 24)];
        [self.contentView addSubview:titleLabel];
        
        projectLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 30, 250, 14)];
        projectLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        projectLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:projectLabel];
        
        flagImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flag.png"]];
        flagImageView.frame = CGRectMake(300, 6, 16, 16);
        [self.contentView addSubview:flagImageView];
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
        projectLabel.text = [NSString stringWithFormat:@"[ %@ ]", project.name];
    }
    
    if (task.flag) {
        flagImageView.frame = CGRectMake(300, 6, 16, 16);
    } else {
        flagImageView.frame = CGRectMake(0, 0, 0, 0);
    }
    
    [statusControl setIsSelected:task.status];
}

@end
