//
//  TaskListController.h
//  zTask
//
//  Created by ming lin on 6/22/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"

@interface TaskListController : UITableViewController
{
    NSArray *tasks;
    BOOL reloadSideMenu;
}

@property(nonatomic, retain) NSString *filter;
@property(nonatomic, retain) Project *project;

@end
