//
//  ReportController.h
//  zTask
//
//  Created by ming lin on 7/22/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "HomeViewController.h"
#import "WeekView.h"

@interface ReportController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, WeekViewDelegate>
{
    NSArray *tasks;
    BOOL reloadSideMenu;
    BOOL isWeekReport;
    UISegmentedControl *reportPeriodSegmentedControl;
}

@property (nonatomic, retain) IBOutlet WeekView *weekView;
@property (nonatomic, retain) IBOutlet UITableView *taskListView;

@end
