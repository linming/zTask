//
//  HomeViewController.m
//  zTask
//
//  Created by ming lin on 6/27/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "HomeViewController.h"
#import "TaskListController.h"
#import "TaskViewController.h"
#import "CountIndicator.h"

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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                              target:self
                                              action:@selector(compose)];
    
    tableItems = [[NSArray alloc] initWithObjects: @"Inbox", @"Projects", @"Flagged", @"Search",nil];
}

- (void)compose
{
    TaskViewController *taskViewController = [[TaskViewController alloc] initWithNibName:@"TaskViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:taskViewController];
    [self presentModalViewController:navigationController animated:YES];
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
    if ([title isEqualToString: @"Inbox"]) {
        cell.textLabel.text = title;
        cell.tag = TAG_INBOX_CELL;
        cell.imageView.image = [UIImage imageNamed:@"inbox.png"];
        
        CountIndicator *countIndicator = [[CountIndicator alloc] initWithPoint:CGPointMake(265.0f, 14.0f) andFontSize:15.0f andWidth:26.0f];
        countIndicator.backgroundColor = [UIColor clearColor];
        countIndicator.indicatorText = [NSString stringWithFormat:@"%d", 12];
        [cell.contentView addSubview:countIndicator];
        
    } else if ([title isEqualToString:@"Projects"]) {
        cell.textLabel.text = title;
        cell.imageView.image = [UIImage imageNamed:@"project.png"];
    } else if ([title isEqualToString:@"Flagged"]) {
        cell.textLabel.text = title;
        cell.imageView.image = [UIImage imageNamed:@"flag.png"];
    } else if ([title isEqualToString:@"Search"]) {
        cell.textLabel.text = title;
        cell.imageView.image = [UIImage imageNamed:@"search.png"];
        
    } else {
        cell.textLabel.text = title;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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
    if (indexPath.row == 0) {
        TaskListController *taskListController = [[TaskListController alloc] initWithNibName:@"TaskListController" bundle:nil];
        [self.navigationController pushViewController:taskListController animated:YES];
    } 
}

@end