//
//  TaskListController.h
//  zTask
//
//  Created by ming lin on 6/22/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"

#define VIEW_OPTION_ALL 1
#define VIEW_OPTION_REMAINING 2

@interface TaskListController : UITableViewController
{
    NSMutableArray *tasks;
    BOOL reloadSideMenu;
    NSInteger viewOption;
    NSString *viewConditions;
    NSString *viewOrders;
    UILabel *statLabel;
    BOOL hasReordered;
}

@property(nonatomic, retain) NSString *filter;
@property(nonatomic, retain) Project *project;

@end
