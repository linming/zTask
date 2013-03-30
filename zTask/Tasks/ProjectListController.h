//
//  ProjectListController.h
//  zTask
//
//  Created by ming lin on 7/9/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"

@interface ProjectListController : UITableViewController
{
    NSMutableArray *projects;
    BOOL reloadSideMenu;
    BOOL hasReordered;
}

@end
