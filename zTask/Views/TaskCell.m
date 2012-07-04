//
//  TaskCell.m
//  zTask
//
//  Created by ming lin on 6/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "TaskCell.h"

@implementation TaskCell

@synthesize task, statusControl, titleLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        statusControl = [[ToggleImageControl alloc] initWithFrame: CGRectMake(10, 10, 24, 24)];
        //toggleControl.tag = indexPath.row;  // for reference in notifications.
        [self.contentView addSubview: statusControl];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 10, 250, 24)];
        [self.contentView addSubview:titleLabel];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
}

@end
