//
//  ReportController.h
//  zTask
//
//  Created by ming lin on 7/22/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "WeekView.h"

@interface ReportController : UIViewController
{
    NSArray *tasks;
    BOOL reloadSideMenu;
}

@property (nonatomic, retain) IBOutlet WeekView *weekView;

@end
