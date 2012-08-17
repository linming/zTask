//
//  ApisMSPController.m
//  PortSite
//
//  Created by ming lin on 4/19/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "ApisMSPController.h"
#import "FileUtil.h"
#import "Utils.h"
#import "MSPResponse.h"

@implementation ApisMSPController

- (MSPResponse *)login
{
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"WIFI_PASSWORD"];
    NSLog(@"wifi password: %@", password);
    NSLog(@"input password: %@", [self.request.params objectForKey:@"password"]);
    if ([[self.request.params objectForKey:@"password"] isEqualToString:password]) {
        NSString *output = @"<script> window.location = '/tasks/index'; </script>";
        NSString *sessionId = [NSString stringWithFormat:@"MSP%d", rand()];
        
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.session setObject:[NSDate date] forKey:sessionId];
        
        NSString *cookie = [NSString stringWithFormat:@"SESSIONID=%@;path=/;max-age=7200", sessionId];
        NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:cookie, @"Set-Cookie", nil];
        return [[MSPResponse alloc] initWithData: [output dataUsingEncoding:NSUTF8StringEncoding] headers:headers];
    } else {
        NSString *output = @"<script> window.location = '/login.html'; </script>";
        return [[MSPResponse alloc] initWithData: [output dataUsingEncoding:NSUTF8StringEncoding] headers:nil];
    }
}


- (HTTPDataResponse *)upload
{
    NSString *output = self.request.uploadFileUri;
    return [[HTTPDataResponse alloc] initWithData: [output dataUsingEncoding:NSUTF8StringEncoding]];
}


- (HTTPDataResponse *)need_passcode
{
    NSString *passcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"PORTSITE_PASSCODE"];
    
    NSString *output = @"0";
    if (passcode && ![passcode isEqualToString:@""]) {
        output = @"1";
    } else {
        NSString *sessionId = [NSString stringWithFormat:@"MSP%d", rand()];
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.session setObject:[NSDate date] forKey:sessionId];
        output = sessionId;
    }
    
    return [[HTTPDataResponse alloc] initWithData: [output dataUsingEncoding:NSUTF8StringEncoding]];
}

- (HTTPDataResponse *)verify_passcode
{
    NSString *passcode = [[NSUserDefaults standardUserDefaults] objectForKey:@"PORTSITE_PASSCODE"];
    NSString *output = @"0";
    if ([[self.request.params objectForKey:@"passcode"] isEqualToString:passcode]) {
        NSString *sessionId = [NSString stringWithFormat:@"MSP%d", rand()];
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.session setObject:[NSDate date] forKey:sessionId];
        output = sessionId;
    }
    NSLog(@"verify passcode output: %@", output);
    return [[HTTPDataResponse alloc] initWithData: [output dataUsingEncoding:NSUTF8StringEncoding]];
}


@end
