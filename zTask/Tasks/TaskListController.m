//
//  TaskListController.m
//  zTask
//
//  Created by ming lin on 6/22/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "TaskListController.h"
#import "Task.h"
#import "TaskCell.h"
#import "HomeViewController.h"
#import "TaskViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface TaskListController ()

@end

@implementation TaskListController

@synthesize filter, project;

-(id)initWithNibName:(NSString*)name bundle:(NSBundle*)bundle;
{
    self = [super initWithNibName:name bundle:bundle];
    if (self) {
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                      target:self 
                                                                                      action:@selector(addTask)];
        
        UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"eye"] 
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(filterTasks)];
        
        
        self.toolbarItems = [NSArray arrayWithObjects:
                             filterButton,
                             flexibleSpace,
                             addButton,
                             nil];
    }
    return self;
}

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
    viewOption = VIEW_OPTION_REMAINING;
    
    if ([filter isEqualToString:@"Project"]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithTitle:@"Edit" 
                                                  style:UIBarButtonItemStyleBordered 
                                                  target:self
                                                  action:@selector(editTasks)];
        self.navigationItem.title = project.name;
        viewConditions = [NSString stringWithFormat:@"project_id = %d", project.rowid];
        viewOrders = @"weight, created desc";
    } else if ([filter isEqualToString:@"Flagged"]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithTitle:@"Edit" 
                                                  style:UIBarButtonItemStyleBordered 
                                                  target:self
                                                  action:@selector(editTasks)];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                                 initWithImage:[UIImage imageNamed:@"menu"] 
                                                 style:UIBarButtonItemStylePlain 
                                                 target:self 
                                                 action:@selector(showMenu)];
        
        self.navigationItem.title = @"Flagged";
        viewConditions = @"flag = 1";
        viewOrders = nil;
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithTitle:@"Edit" 
                                                  style:UIBarButtonItemStyleBordered 
                                                  target:self
                                                  action:@selector(editTasks)];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                                 initWithImage:[UIImage imageNamed:@"menu"] 
                                                 style:UIBarButtonItemStylePlain 
                                                 target:self 
                                                 action:@selector(showMenu)];
        
        self.navigationItem.title = @"zTask";
        viewConditions = @"project_id = 0";
        viewOrders = nil;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTasks) name:@"TasksChanged" object:nil];
    reloadSideMenu = NO;
    
    //[self hideEmptySeparators];
    
    [self addStatLabel];
    
    [self reloadTasks];
}

- (void)addStatLabel
{
    for (UIView *subview in [self.navigationController.toolbar subviews]) {
        if ([subview isKindOfClass:[UILabel class]]) {
            [subview removeFromSuperview];
        }
    }
    
    statLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 44)];
    statLabel.backgroundColor = [UIColor clearColor];
    statLabel.textAlignment = UITextAlignmentCenter;
    statLabel.textColor = [UIColor whiteColor];
    [self.navigationController.toolbar addSubview:statLabel];
}

- (void)hideEmptySeparators
{
    UIView *emptyFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    emptyFooterView.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:emptyFooterView];
}

- (void)showMenu
{
    [self.revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionLeft animated:YES];
}

- (void)addTask
{
    TaskViewController *taskViewController = [[TaskViewController alloc] initWithNibName:@"TaskViewController" bundle:nil];
    if (project) {
        [taskViewController setProject:project];
    }
    if ([filter isEqualToString:@"Flagged"]) {
        [taskViewController setFromFlagged:YES];
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:taskViewController];
    [self presentModalViewController:navigationController animated:YES];
}

- (void)reloadTasks
{
    NSString *sql = @"1 = 1";
    if (viewOption == VIEW_OPTION_REMAINING) {
        sql = [sql stringByAppendingString:@" and status = 0"];
    }
    if (viewConditions) {
        sql = [sql stringByAppendingFormat:@" and %@", viewConditions];
    }
    tasks = [Task findAllByConditions:sql order:viewOrders];
    if (viewOption == VIEW_OPTION_REMAINING) {
        statLabel.text = [NSString stringWithFormat:@"Remaining: %d task%@", [tasks count], [tasks count] < 2 ? @"" : @"s"];
    } else {
        statLabel.text = [NSString stringWithFormat:@"Total: %d task%@", [tasks count], [tasks count] < 2 ? @"" : @"s"];
    }
    [self.tableView reloadData];
}

- (void)editTasks
{
    if (self.tableView.editing) {
        [self.tableView setEditing:NO];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleBordered];
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        if ([filter isEqualToString:@"Project"] && hasReordered) {
            [Task saveOrder:tasks];
        }
    } else {
        [self.tableView setEditing:YES];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
    }
}

- (void)filterTasks
{
    if (viewOption == VIEW_OPTION_ALL) {
        viewOption = VIEW_OPTION_REMAINING;
    } else {
        viewOption = VIEW_OPTION_ALL;
    }
    [self reloadTasks];
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
    
    [self.navigationController setToolbarHidden:NO];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *hudMessage = [appDelegate.session objectForKey:@"HUD_MESSAGE"];
    if (hudMessage) {
        [appDelegate.session removeObjectForKey:@"HUD_MESSAGE"];

        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = hudMessage;
        hud.margin = 10.f;
        hud.yOffset = 150.f;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:2];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES];
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
    return [tasks count];
    //NSInteger taskCount = [tasks count];
    //return taskCount == 0 ? 1 : taskCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if ([tasks count] == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"No Tasks";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        cell.userInteractionEnabled = NO;
        return cell;
    }
     */
    
    static NSString *CellIdentifier = @"TaskCell";
    TaskCell *cell = (TaskCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[TaskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Task *task = [tasks objectAtIndex:indexPath.row];
    [cell setTask:task];
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source

        [tableView beginUpdates];
        Task *deletedTask = [tasks objectAtIndex:indexPath.row];
        [tasks removeObjectAtIndex:indexPath.row];
        [Task remove:deletedTask.rowid];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    int from = fromIndexPath.row;
    int to = toIndexPath.row;
    if (to != from) {
        id obj = [tasks objectAtIndex:from];
        [tasks removeObjectAtIndex:from];
        if (to >= [tasks count]) {
            [tasks addObject:obj];
        } else {
            [tasks insertObject:obj atIndex:to];
        }
        hasReordered = YES;
    }
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    if ([filter isEqualToString:@"Project"]) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![filter isEqualToString:@"Project"]) {
        // We don't want to be able to pan on nav bar to see the left side when we pushed a controller
        [self.revealSideViewController unloadViewControllerForSide:PPRevealSideDirectionLeft];
        reloadSideMenu = YES;
    }
    
    TaskViewController *taskViewController = [[TaskViewController alloc] initWithNibName:@"TaskViewController" bundle:nil];
    Task *task = [tasks objectAtIndex:indexPath.row];
    taskViewController.taskId = task.rowid;
    taskViewController.tasks = tasks;
    taskViewController.currentIndex = indexPath.row;
    [self.navigationController pushViewController:taskViewController animated:YES];
}

@end
