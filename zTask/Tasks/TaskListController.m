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

@interface TaskListController ()

@end

@implementation TaskListController

@synthesize filter, project;

-(id)initWithNibName:(NSString*)name bundle:(NSBundle*)bundle;
{
    self = [super initWithNibName:name bundle:bundle];
    if (self) {
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *organizeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                                      target:self 
                                                                                      action:@selector(organizeTasks)];
        
        UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"eye"] 
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(filterTasks)];
        
        
        NSArray *toolbarItems = [NSArray arrayWithObjects:
                                 flexibleSpace,
                                 filterButton,
                                 flexibleSpace,
                                 flexibleSpace,
                                 flexibleSpace,
                                 organizeButton,
                                 flexibleSpace,
                                 nil];
        self.toolbarItems = toolbarItems;
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
    
    if ([filter isEqualToString:@"Project"]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                  target:self
                                                  action:@selector(compose)];        
        self.navigationItem.title = project.name;
        tasks = [Task findAllByConditions:[NSString stringWithFormat:@"where project_id = %d", project.rowid]];
    } else if ([filter isEqualToString:@"Flagged"]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                  target:self
                                                  action:@selector(compose)];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                                 initWithImage:[UIImage imageNamed:@"menu"] 
                                                 style:UIBarButtonItemStylePlain 
                                                 target:self 
                                                 action:@selector(showMenu)];
        
        self.navigationItem.title = @"Flagged";
        tasks = [Task findAllByConditions:@"where flag = 1"];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                  target:self
                                                  action:@selector(compose)];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                                 initWithImage:[UIImage imageNamed:@"menu"] 
                                                 style:UIBarButtonItemStylePlain 
                                                 target:self 
                                                 action:@selector(showMenu)];
        
        self.navigationItem.title = @"zTask";
        tasks = [Task findAll:20 page:1]; 
    }

    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTasks) name:@"TasksChanged" object:nil];
    reloadSideMenu = NO;
}

- (void)showMenu
{
    [self.revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionLeft animated:YES];
}

- (void)compose
{
    TaskViewController *taskViewController = [[TaskViewController alloc] initWithNibName:@"TaskViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:taskViewController];
    [self presentModalViewController:navigationController animated:YES];
}

- (void)reloadTasks
{
    tasks = [Task findAll:20 page:1]; 
    [self.tableView reloadData];
}

- (void)organizeTasks
{
    if (self.tableView.editing) {
        [self.tableView setEditing:NO];
    } else {
        [self.tableView setEditing:YES];
    }
}

- (void)filterTasks
{
    
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
    
    self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
    [self.navigationController setToolbarHidden:NO];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog(@"move from %d to %d", fromIndexPath.row, toIndexPath.row);
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
    [self.navigationController pushViewController:taskViewController animated:YES];
}

@end
