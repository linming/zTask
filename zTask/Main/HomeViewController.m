//
//  HomeViewController.m
//  zTask
//
//  Created by ming lin on 6/27/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "HomeViewController.h"
#import "SettingsController.h"
#import "WiFiViewController.h"
#import "TaskListController.h"
#import "TaskViewController.h"
#import "ProjectListController.h"
#import "SearchController.h"
#import "ReportController.h"
#import "CountIndicator.h"
#import "MenuCell.h"

#define TAG_INBOX_CELL 101
#define TAG_INBOX_CELL_DISCLOSURE_COUNT_BUTTON 102

@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"zTask";
    
    tableItems = [[NSArray alloc] initWithObjects: @"Inbox", @"Projects", @"Flagged", @"Report", @"Search", @"WiFi", @"Settings", nil];
    
    self.tableView.backgroundColor = [UIColor darkGrayColor];
    
    [self hideEmptySeparators];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)hideEmptySeparators
{
    UIView *emptyFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    emptyFooterView.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:emptyFooterView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *title = [tableItems objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    cell.textLabel.textColor = [UIColor whiteColor];
    
    UIImageView *disclosureButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessoryIndicator"]];
    disclosureButton.frame = CGRectMake( 220, (cell.frame.size.height - 14) / 2, 9, 14);
    [cell.contentView addSubview:disclosureButton];
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [tableItems objectAtIndex:indexPath.row];
    if ([title isEqualToString: @"Inbox"]) {
        TaskListController *taskListController = [[TaskListController alloc] initWithNibName:@"TaskListController" bundle:nil];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:taskListController];
        [self.revealSideViewController popViewControllerWithNewCenterController:navigationController animated:YES];
    } else if ([title isEqualToString:@"Projects"]) {
        ProjectListController *projectListController = [[ProjectListController alloc] initWithNibName:@"ProjectListController" bundle:nil];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:projectListController];
        [self.revealSideViewController popViewControllerWithNewCenterController:navigationController animated:YES];
    } else if ([title isEqualToString:@"Flagged"]) {
        TaskListController *taskListController = [[TaskListController alloc] initWithNibName:@"TaskListController" bundle:nil];
        taskListController.filter = @"Flagged";
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:taskListController];
        [self.revealSideViewController popViewControllerWithNewCenterController:navigationController animated:YES];
    } else if ([title isEqualToString:@"Report"]) {
        ReportController *reportController = [[ReportController alloc] initWithNibName:@"ReportController" bundle:nil];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:reportController];
        [self.revealSideViewController popViewControllerWithNewCenterController:navigationController animated:YES];
    } else if ([title isEqualToString:@"Search"]) {
        SearchController *searchController = [[SearchController alloc] initWithNibName:@"SearchController" bundle:nil];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:searchController];
        [self.revealSideViewController popViewControllerWithNewCenterController:navigationController animated:YES];
    } else if ([title isEqualToString:@"WiFi"]) {
        WiFiViewController *wifiViewController = [[WiFiViewController alloc] initWithNibName:@"WiFiViewController" bundle:nil];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:wifiViewController];
        [self.revealSideViewController popViewControllerWithNewCenterController:navigationController animated:YES];
    } else if ([title isEqualToString:@"Settings"]) {
        SettingsController *settingsController = [[SettingsController alloc] initWithNibName:@"SettingsController" bundle:nil];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsController];
        [self.revealSideViewController popViewControllerWithNewCenterController:navigationController animated:YES];
    } else {
        
    }

}

@end
