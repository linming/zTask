//
//  ReportController.m
//  zTask
//
//  Created by ming lin on 7/22/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "ReportController.h"
#import "TaskViewController.h"
#import "TaskCell.h"
#import "DateUtil.h"
#import "MBProgressHUD.h"

@interface ReportController ()

@end

@implementation ReportController

@synthesize weekView, taskListView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        weekView = [[WeekView alloc] initWithFrame:CGRectMake(0, 0, 320, 89) date:[NSDate date] delegate:self];
        [self.view addSubview:weekView];
        
        //taskListView.frame = CGRectMake(0, 0, 320, 460 - 89);
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleBordered target:self action:@selector(today)];
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                   target:self
                                                                                   action:@selector(share)];
                
        self.toolbarItems = [NSArray arrayWithObjects:
                             todayButton,
                             flexibleSpace,
                             shareButton,
                             nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Daily Report";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                             initWithImage:[UIImage imageNamed:@"menu"] 
                                             style:UIBarButtonItemStylePlain 
                                             target:self 
                                             action:@selector(showMenu)];
    
    [self reloadTasks];
}

- (void)reloadTasks
{
    NSString *sql;
    if (isWeekReport) {
        self.navigationItem.title = @"Weekly Report";
        NSArray *weekdays = weekView.weekdays;
        sql = [NSString stringWithFormat:@"date(completed, 'unixepoch', 'localtime') >= '%@' and date(completed, 'unixepoch', 'localtime') <= '%@' and status = 1", [DateUtil formatDate:[weekdays objectAtIndex:0] to:@"yyyy-MM-dd"], [DateUtil formatDate:[weekdays objectAtIndex:6] to:@"yyyy-MM-dd"]];
    } else {
        self.navigationItem.title = @"Daily Report";
        sql = [NSString stringWithFormat:@"date(completed, 'unixepoch', 'localtime') = '%@' and status = 1", [DateUtil formatDate:weekView.selectedDate to:@"yyyy-MM-dd"]];
    }
    tasks = [Task findAllByConditions:sql order:@"completed asc"];
    [taskListView reloadData];
}

- (void)showMenu
{
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
    
    [self.navigationController setToolbarHidden:NO];
    NSArray *buttonNames = [NSArray arrayWithObjects:@"Day", @"Week", nil];
    reportPeriodSegmentedControl = [[UISegmentedControl alloc] initWithItems:buttonNames];
    reportPeriodSegmentedControl.frame = CGRectMake(90, 7, 150, 30);
    reportPeriodSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    if (isWeekReport) {
        [reportPeriodSegmentedControl setSelectedSegmentIndex:1];
    } else {
        [reportPeriodSegmentedControl setSelectedSegmentIndex:0];
    }
    [reportPeriodSegmentedControl addTarget:self action:@selector(changeReportPeriod) forControlEvents:UIControlEventValueChanged];
    [self.navigationController.toolbar addSubview:reportPeriodSegmentedControl];
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
    NSInteger taskCount = [tasks count];
    return taskCount == 0 ? 1 : taskCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tasks count] == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"No Tasks";
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

#pragma mark - go to today
- (void)today
{
    [weekView setSelectedDate:[NSDate date]];
}

- (void)changeReportPeriod
{
    isWeekReport = (reportPeriodSegmentedControl.selectedSegmentIndex == 1);
    [weekView setIsWeekReport:isWeekReport];
}

#pragma mark - week view delegate
- (void)selectedDateChanged:(NSDate *)_selectedDate
{
    [self reloadTasks];
}

#pragma mark - Compose Mail
- (void)share
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
    NSString *subject;
    if (isWeekReport) {
        subject = [NSString stringWithFormat:@"Weekly Report"];
    } else {
        subject = [NSString stringWithFormat:@"Daily Report"];
    }
    [picker setSubject:subject];
    /*
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"];
	NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
	NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
	
	[picker setToRecipients:toRecipients];
	[picker setCcRecipients:ccRecipients];
	[picker setBccRecipients:bccRecipients];
	
	// Attach an image to the email
	NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
    NSData *myData = [NSData dataWithContentsOfFile:path];
	[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
     */
	
	// Fill out the email body text
	NSString *emailBody = @"<ul>";
    for (Task *task in tasks) {
        emailBody = [emailBody stringByAppendingFormat:@"<li>%@</li>", task.title];
    }
    emailBody = [emailBody stringByAppendingFormat:@"</ul>"];
	[picker setMessageBody:emailBody isHTML:YES];
	
	[self presentModalViewController:picker animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSString *message;
    switch (result) {
		case MFMailComposeResultCancelled:
			message = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			message = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			message = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			message = @"Result: failed";
			break;
		default:
			message = @"Result: not sent";
			break;
	}
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];
	[self dismissModalViewControllerAnimated:YES];
}

@end
