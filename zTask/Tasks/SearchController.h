//
//  SearchController.h
//  zTask
//
//  Created by ming lin on 7/14/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "TaskCell.h"
#import "TaskViewController.h"
#import "HomeViewController.h"

@interface SearchController : UITableViewController <UISearchBarDelegate>
{
    NSArray *tasks;
    BOOL reloadSideMenu;
}

@property (nonatomic, retain) IBOutlet UISearchBar *taskSearchBar;

@end
