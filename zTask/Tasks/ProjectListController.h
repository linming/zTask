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
    NSArray *projects;
    BOOL reloadSideMenu;
}

@end
