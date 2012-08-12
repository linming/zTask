//
//  SearchController.m
//  zTask
//
//  Created by ming lin on 7/14/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "SearchController.h"

@interface SearchController ()

@end

@implementation SearchController

@synthesize taskSearchBar;

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

    self.navigationItem.title = @"Search";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                             initWithImage:[UIImage imageNamed:@"menu"] 
                                             style:UIBarButtonItemStylePlain 
                                             target:self 
                                             action:@selector(showMenu)];
    
    [taskSearchBar becomeFirstResponder];
}

- (void)showMenu
{
    [taskSearchBar resignFirstResponder];
    [self.revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionLeft animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (reloadSideMenu) {
        HomeViewController *homeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        [self.revealSideViewController preloadViewController:homeViewController forSide:PPRevealSideDirectionLeft];
        reloadSideMenu = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger taskCount = [tasks count];
    return (taskCount == 0 && taskSearchBar.text) ? 1 : taskCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tasks count] == 0 && taskSearchBar.text) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"No Results Found";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        cell.userInteractionEnabled = NO;
        return cell;
    }
    
    static NSString *CellIdentifier = @"TaskCell";
    TaskCell *cell = (TaskCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Task *task = [tasks objectAtIndex:indexPath.row];
    [cell setTask:task];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.revealSideViewController unloadViewControllerForSide:PPRevealSideDirectionLeft];
    reloadSideMenu = YES;
    
    TaskViewController *taskViewController = [[TaskViewController alloc] initWithNibName:@"TaskViewController" bundle:nil];
    Task *task = [tasks objectAtIndex:indexPath.row];
    taskViewController.taskId = task.rowid;
    [self.navigationController pushViewController:taskViewController animated:YES];
}

#pragma mark - search bar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *sql = [NSString stringWithFormat:@"title like '%%%@%%'", searchBar.text];
    tasks = [Task findAllByConditions:sql order:nil];
    [self.tableView reloadData];
}

@end
