//
//  MainTabBarController.m
//  PortSite
//
//  Created by ming lin on 6/10/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "MainTabBarController.h"
#import "HomeViewController.h"
#import "MainViewController.h"
#import "TaskViewController.h"
#import "SettingsController.h"
#import "KTPhotoScrollViewController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (id)init
{
    self = [super init];
    if (self) {
        UIViewController *homeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
        homeNavigationController.tabBarItem.title = @"Home";
        homeNavigationController.tabBarItem.image = [UIImage imageNamed:@"home"];
        homeNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        UIViewController *mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
        UINavigationController *mainNavigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
        mainNavigationController.tabBarItem.title = @"WiFi";
        mainNavigationController.tabBarItem.image = [UIImage imageNamed:@"wifi"];
        mainNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        
        UITableViewController *setttingsController = [[SettingsController alloc] initWithNibName:@"SettingsController" bundle:nil];
        UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:setttingsController];
        settingsNavigationController.tabBarItem.title = @"Settings";
        settingsNavigationController.tabBarItem.image = [UIImage imageNamed:@"settings"];
        settingsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        self.viewControllers = [NSArray arrayWithObjects:homeNavigationController, mainNavigationController, settingsNavigationController, nil];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    /*
    UINavigationController *selectedController = (UINavigationController *)self.selectedViewController;
    if ([selectedController.topViewController isKindOfClass:[KTPhotoScrollViewController class]]) {
        return YES;
    }
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
     */
    return YES;
}

@end
