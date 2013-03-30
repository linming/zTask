//
//  ProjectListController.m
//  zTask
//
//  Created by ming lin on 7/9/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "ProjectListController.h"
#import "HomeViewController.h"
#import "TaskListController.h"
#import "Task.h"

@interface ProjectListController ()

@end

@implementation ProjectListController

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

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                             initWithImage:[UIImage imageNamed:@"menu"] 
                                             style:UIBarButtonItemStylePlain 
                                             target:self 
                                             action:@selector(showMenu)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Edit"
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(editProjects)];
    
    self.navigationItem.title = @"Projects";
    
    /*
    projects = [Project findAll];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadProjects) name:@"ProjectsChanged" object:nil];
    */
     reloadSideMenu = NO;
}

- (void)showMenu
{
    [self.revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionLeft animated:YES];
}

- (void)reloadProjects
{
    projects = [Project findAll]; 
    [self.tableView reloadData];
}

- (void)editProjects
{
    if (self.tableView.editing) {
        [self.tableView setEditing:NO];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleBordered];
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        if (hasReordered) {
            [Project saveOrder:projects];
        }
    } else {
        [self.tableView setEditing:YES];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
    }
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
    
    [self reloadProjects];
    
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
    return [projects count];
    //return [projects count] == 0 ? 1 : [projects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if ([projects count] == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"No Projects";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        cell.userInteractionEnabled = NO;
        return cell;
    }
     */
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    Project *project = [projects objectAtIndex:indexPath.row];
    cell.textLabel.text = project.name;
    cell.imageView.image = [UIImage imageNamed:@"project.png"];
    
    NSArray *tasks = [Task findAllByConditions:[NSString stringWithFormat:@"project_id = %d and status = 0", project.rowid] order:nil];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d remaining", [tasks count]];
    
    [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
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
        Project *deletedProject = [projects objectAtIndex:indexPath.row];
        [projects removeObjectAtIndex:indexPath.row];
        [Project remove:deletedProject.rowid];
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
        id obj = [projects objectAtIndex:from];
        [projects removeObjectAtIndex:from];
        if (to >= [projects count]) {
            [projects addObject:obj];
        } else {
            [projects insertObject:obj atIndex:to];
        }
        hasReordered = YES;
    }
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.revealSideViewController unloadViewControllerForSide:PPRevealSideDirectionLeft];
    reloadSideMenu = YES;
    
    TaskListController *taskListController = [[TaskListController alloc] initWithNibName:@"TaskListController" bundle:nil];
    Project *project = [projects objectAtIndex:indexPath.row];
    taskListController.filter = @"Project";
    taskListController.project = project;
    [self.navigationController pushViewController:taskListController animated:YES];
}

@end
