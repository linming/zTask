//
//  ProjectSelectorController.m
//  zTask
//
//  Created by ming lin on 6/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "ProjectSelectorController.h"

@interface ProjectSelectorController ()

@end

@implementation ProjectSelectorController

@synthesize projectSearchBar, taskViewController;

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

    self.navigationItem.title = @"Project";
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    allProjects = [Project findAll];
    projects = [allProjects mutableCopy];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [projects count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    NSString *searchText = [projectSearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (searchText && ![searchText isEqualToString:@""]) {
        if (indexPath.row == projects.count) {
            cell.textLabel.text = [NSString stringWithFormat:@"Create \"%@\"", searchText];
        } else {
            Project *project = [projects objectAtIndex:indexPath.row];
            cell.textLabel.text = project.name;
        }
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"None";
            cell.textLabel.textColor = [UIColor grayColor];
        } else {
            Project *project = [projects objectAtIndex:indexPath.row - 1];
            cell.textLabel.text = project.name;
            cell.textLabel.textColor = [UIColor blackColor];
        }
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
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
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *searchText = [projectSearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (searchText && ![searchText isEqualToString:@""]) {
        if (indexPath.row == projects.count) {
            Project *project = [[Project alloc] init];
            project.name = searchText;
            NSInteger projectId = [Project create:project];
            [taskViewController updateProject:projectId projectName:project.name];
        } else {
            Project *project = [projects objectAtIndex:indexPath.row];
            [taskViewController updateProject:project.rowid projectName:project.name];
        }
    } else {
        if (indexPath.row == 0) {
            [taskViewController updateProject:0 projectName:@"None"];
        } else {
            Project *project = [projects objectAtIndex:indexPath.row - 1];
            [taskViewController updateProject:project.rowid projectName:project.name];
        }
    }
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - button actions

- (void)cancel
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchTerm 
{
    if ([searchTerm length] == 0) {
        [self resetSearch];
        [self.tableView reloadData];
        return;
    }
    [self handleSearchForTerm:searchTerm];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    projectSearchBar.text = @"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self resetSearch];
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    [self.tableView reloadData];
}

- (void)resetSearch {
    projects = [allProjects mutableCopy];
}

- (void)handleSearchForTerm:(NSString *)searchTerm {
    [self resetSearch];
    for (Project *project in projects) {
        if ([project.name rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound) {
            [projects removeObject:project];
        }
    }
    [self.tableView reloadData];
}

@end
