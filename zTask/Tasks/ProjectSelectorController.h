//
//  ProjectSelectorController.h
//  zTask
//
//  Created by ming lin on 6/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"

@interface ProjectSelectorController : UITableViewController <UISearchBarDelegate>
{
    NSArray *allProjects;
    NSMutableArray *projects;
}

@property (nonatomic, retain) IBOutlet UISearchBar *projectSearchBar;

@end
