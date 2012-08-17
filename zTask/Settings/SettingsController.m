//
//  SettingsController.m
//  PortSite
//
//  Created by ming lin on 4/3/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "SettingsController.h"
#import "PSLabelTextFieldCell.h"
#import "PSLabelSwitchCell.h"
#import "AppDelegate.h"
#import "Utils.h"

#define kPortTextField 101
#define kPasswordTextField 102

@interface SettingsController ()

@end

@implementation SettingsController

@synthesize data, sections;

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

    self.navigationItem.title = @"Settings";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                             initWithImage:[UIImage imageNamed:@"menu"] 
                                             style:UIBarButtonItemStylePlain 
                                             target:self 
                                             action:@selector(showMenu)];
    
    self.data = [NSArray arrayWithObjects:
                 [NSArray arrayWithObjects:@"require password", @"password", nil],
                 [NSArray arrayWithObjects:@"port number", nil],
                 [NSArray arrayWithObjects:@"version number", nil],
                 nil];
    self.sections = [NSArray arrayWithObjects:
                     @"WiFi Share",
                     @"Connection",
                     @"About",
                     nil];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void)showMenu
{
    [self.revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionLeft animated:YES];
}

- (void)hideKeyboard 
{
    [passwordTextField resignFirstResponder];
    [portTextField resignFirstResponder];
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
    return [data count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *rows = (NSArray *)[self.data objectAtIndex:section];
    return [rows count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sections objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell_%i_%i", indexPath.section, indexPath.row];
        PSLabelSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PSLabelSwitchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        // Configure the cell...
        cell.textLabel.text = [[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        passwordSwitch = cell.switcher;
        [passwordSwitch addTarget:self action:@selector(requirePasswordSwitchDidChange) forControlEvents:UIControlEventValueChanged];
        NSNumber *status = [[NSUserDefaults standardUserDefaults] objectForKey:@"WIFI_REQUIRE_PASSWORD"];
        if (status) {
            passwordSwitch.on = [status boolValue];
        }
        
        return cell;
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell_%i_%i", indexPath.section, indexPath.row];
        PSLabelTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PSLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        // Configure the cell...
        passwordTextField = cell.textField;
        cell.textLabel.text = [[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        [passwordTextField setPlaceholder:@"enter password here"];
        [passwordTextField setTextAlignment:UITextAlignmentRight];
        [passwordTextField setTag: kPasswordTextField];
        [passwordTextField setDelegate:self];
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"WIFI_PASSWORD"];
        if (password) {
            [passwordTextField setText:password];
        }
        return cell;
    } else if (indexPath.section == 1 && indexPath.row == 0) { // port number
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell_%i_%i", indexPath.section, indexPath.row];
        PSLabelTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PSLabelTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        // Configure the cell...
        portTextField = cell.textField;
        cell.textLabel.text = [[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        [portTextField setPlaceholder:@"enter port here"];
        [portTextField setTextAlignment:UITextAlignmentRight];
        [portTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [portTextField setTag: kPortTextField];
        [portTextField setDelegate:self];
        NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:@"WIFI_PORT"];
        if (port) {
            [portTextField setText:port];
        }
        return cell;
    } else if (indexPath.section == 2 && indexPath.row == 0) { // version
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell_%i_%i", indexPath.section, indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        // Configure the cell...
        cell.textLabel.text = [[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = @"1.0";
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }

    return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField 
{
    //This line dismisses the keyboard.       
    [theTextField resignFirstResponder];
    //Your view manipulation here if you moved the view up due to the keyboard etc. 

    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)theTextField  
{
    [theTextField resignFirstResponder];
    if (theTextField.tag == kPortTextField) {
        NSString *port = [theTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (port.intValue > 1024 && port.intValue < 65535) {
            [[NSUserDefaults standardUserDefaults] setObject:port forKey:@"WIFI_PORT"];
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if ([delegate isWebServerRunning]) {
                [delegate stopWebServer];
                [delegate startWebServer];
            } 
        } else {
            [Utils alertWithMessage:@"Port number must be between 1024 and 65535."];
            theTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"WIFI_PORT"];
        }
    
    } else if (theTextField.tag == kPasswordTextField) {
        NSString *password = [theTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"WIFI_PASSWORD"];
    }
}

- (void)requirePasswordSwitchDidChange
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:passwordSwitch.on] forKey:@"WIFI_REQUIRE_PASSWORD"];
}

@end
