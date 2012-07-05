//
//  WiFiViewController.m
//  PortSite
//
//  Created by ming lin on 4/3/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "WiFiViewController.h"
#import "AppDelegate.h"
#import "Utils.h"

@interface WiFiViewController ()

@end

@implementation WiFiViewController

@synthesize urlLabel, addressBarLabel, serverSwitch, urlHintLabel, addressBarImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"WiFi";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                             initWithImage:[UIImage imageNamed:@"menu"] 
                                             style:UIBarButtonItemStylePlain 
                                             target:self 
                                             action:@selector(showMenu)];

    
    [serverSwitch addTarget:self action:@selector(serverSwitchDidChange) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInfoUpdate:) name:@"WebServerStarted" object:nil];
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

}



- (void)displayInfoUpdate:(NSNotification *)notification
{
	NSLog(@"displayInfoUpdate:");
    
    NSString *info;
	if (notification) {
		info = [[notification object] copy];
	}
    
	if(info == nil) {
		return;
	} else if ([info isEqualToString:@"Wifi: No Connection!"]) {
        [serverSwitch setOn:NO];
        [self hideUrlHints];
    } else {
        [serverSwitch setOn:YES];
        [self showUrlHints:info];
    }
}

- (void)hideUrlHints
{
    urlLabel.text = @"";
    addressBarLabel.text = urlLabel.text;
    [urlHintLabel setHidden:YES];
    [addressBarImageView setHidden:YES];
}

- (void)showUrlHints:(NSString *)info
{
    [urlHintLabel setHidden:NO];
    [addressBarImageView setHidden:NO];
    urlLabel.text = info;
    addressBarLabel.text = urlLabel.text;
}


- (void)serverSwitchDidChange
{
    if ([Utils isEnableWIFI]) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (serverSwitch.on) {
            [delegate startWebServer];
        } else {
            [delegate stopWebServer];
            [self hideUrlHints];
        }
    } else {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        
        [self.view addSubview:hud];
        hud.delegate = self;
        //hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"X-Mark.png"]];
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = @"No Wi-Fi Connection";
        [hud showWhileExecuting:@selector(waitForTwoSeconds) onTarget:self withObject:nil animated:YES];
        
        [serverSwitch setOn:NO];
        [self hideUrlHints];
    }
}



#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden 
{    
    [hud removeFromSuperview];
}

- (void)waitForTwoSeconds 
{
    sleep(2);
}

@end
