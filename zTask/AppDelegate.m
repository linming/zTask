//
//  AppDelegate.m
//  zTask
//
//  Created by ming lin on 6/22/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "AppDelegate.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "MingHTTPConnection.h"
#import "FileUtil.h"
#import "DBUtil.h"
#import "Utils.h"
#import "TaskListController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize revealSideViewController = _revealSideViewController;
@synthesize session;

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.session = [NSMutableDictionary dictionary];
    [self initWindow];
    
    // Configure our logging framework.
	// To keep things simple and fast, we're just going to log to the Xcode console.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    [self initAppData];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self stopWebServer];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self performSelectorInBackground:@selector(startWebServer) withObject:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

- (void)initWindow
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    TaskListController *taskListController = [[TaskListController alloc] initWithNibName:@"TaskListController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:taskListController];
    self.revealSideViewController = [[PPRevealSideViewController alloc] initWithRootViewController:nav];
    [self.revealSideViewController setDirectionsToShowBounce:PPRevealSideDirectionNone];
    [self.revealSideViewController setPanInteractionsWhenClosed:PPRevealSideInteractionContentView | PPRevealSideInteractionNavigationBar];
    
    self.window.rootViewController = self.revealSideViewController;
    
    [self.window makeKeyAndVisible];
}

- (void)initAppData
{
    [DBUtil createDatabase];
    
    NSNumber *requirePassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"PORTSITE_REQUIRE_PASSWORD"];
    if (!requirePassword) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"PORTSITE_REQUIRE_PASSWORD"];
    }
    
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"PORTSITE_PASSWORD"];
    if (!password) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"PORTSITE_PASSWORD"];
    }
    
    NSNumber *serviceBrowserable = [[NSUserDefaults standardUserDefaults] objectForKey:@"PORTSITE_SERVICE_BROWSERABLE"];
    if (!serviceBrowserable) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"PORTSITE_SERVICE_BROWSERABLE"];
    }
    
    NSString *passcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"PORTSITE_PASSCODE"];
    if (!passcode) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"PORTSITE_PASSCODE"];
    }
    
    NSString *port = [[NSUserDefaults standardUserDefaults] objectForKey:@"PORTSITE_PORT"];
    if (!port) {
        [[NSUserDefaults standardUserDefaults] setObject:@"12345" forKey:@"PORTSITE_PORT"];
    }
    
}

- (void)startWebServer
{    
    NSDictionary *addresses = [Utils localAddress];
    NSString *info;
	NSString *localIP = nil;
    NSInteger portNumber = [Utils getPortNumber];
	localIP = [addresses objectForKey:@"en0"];
	if (!localIP) {
		localIP = [addresses objectForKey:@"en1"];
	}
	if (!localIP) {
		info = @"Wifi: No Connection!";
	} else {
		info = [NSString stringWithFormat:@"http://%@:%d", localIP, portNumber];
    }
	
	// Create server using our custom MyHTTPServer class
	httpServer = [[HTTPServer alloc] init];
    
    [httpServer setConnectionClass:[MingHTTPConnection self]];
	
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
    
    NSNumber *serviceBrowserable = [[NSUserDefaults standardUserDefaults] objectForKey:@"PORTSITE_SERVICE_BROWSERABLE"];
    if ([serviceBrowserable boolValue]) {
        [httpServer setType:@"_http._tcp."];
    }
	
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
    
    [httpServer setPort:[Utils getPortNumber]];
	
	// Serve files from our embedded Web folder
    NSString *webPath = [FileUtil getWebRoot];
    DDLogInfo(@"Setting document root: %@", webPath);
	
	[httpServer setDocumentRoot:webPath];
	
	// Start the server (and check for problems)
	
	NSError *error;
	if([httpServer start:&error]) {
		DDLogInfo(@"Started HTTP Server on port %hu", [httpServer listeningPort]);
	} else {
		DDLogError(@"Error starting HTTP Server: %@", error);
	}
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WebServerStarted" object:info];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)stopWebServer
{
    [httpServer stop]; 
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (BOOL)isWebServerRunning
{
    return [httpServer isRunning];
}

@end
