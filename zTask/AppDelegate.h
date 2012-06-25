//
//  AppDelegate.h
//  zTask
//
//  Created by ming lin on 6/22/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPServer.h"
#import "MainTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate> {
    HTTPServer *httpServer;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MainTabBarController *tabBarController;

@property (nonatomic, retain) NSMutableDictionary *session;

- (void)startWebServer;
- (void)stopWebServer;
- (BOOL)isWebServerRunning;

@end
