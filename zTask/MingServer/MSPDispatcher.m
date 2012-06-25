//
//  MSPDispatcher.m
//  PortSite
//
//  Created by ming lin on 4/8/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "MSPDispatcher.h"
#import "GRMustache.h"
#import "MSPController.h"
#import "FileUtil.h"
#import "AppDelegate.h"

@implementation MSPDispatcher

- (id)dispatch:(MSPRequest *)request
{
    NSArray *whiteList = [NSArray arrayWithObjects:@"/apis/login", @"/apis/need_passcode", @"/apis/verify_passcode", nil];
    //verify login
    NSNumber *requirePasswordNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"PORTSITE_REQUIRE_PASSWORD"];
    if (requirePasswordNumber && requirePasswordNumber.boolValue) {
        if (![whiteList containsObject:request.relativePath]) {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if (![request.params objectForKey:@"SESSIONID"] || 
                ![delegate.session objectForKey:[request.params objectForKey:@"SESSIONID"]]) {
                return [[HTTPRedirectResponse alloc] initWithPath:@"/login.html"];
            }
        }
    }
    
    NSArray *chunks = [request.relativePath componentsSeparatedByString:@"/"];
    
    if ([chunks count] < 3) {
        return nil;
    }
    
    NSString *controllerClassName = [NSString stringWithFormat:@"%@MSPController", [[chunks objectAtIndex:1] capitalizedString]];
    
    NSString *mspRelativePath = [NSString stringWithFormat:@"/%@/%@", [chunks objectAtIndex:1], [chunks objectAtIndex:2]];
    
    MSPController *mspController = [[NSClassFromString(controllerClassName) alloc] init];
    
    [mspController setRequest:request];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id ret = nil;
    if ([chunks count] == 4) {
        NSString *methodName = [NSString stringWithFormat:@"%@:", [chunks objectAtIndex:2]];
        if ([mspController respondsToSelector:NSSelectorFromString(methodName)]) {
            ret = [mspController performSelector:NSSelectorFromString(methodName) withObject:[chunks objectAtIndex:3]];
        } 
    } else if ([chunks count] == 3) {
        if ([mspController respondsToSelector:NSSelectorFromString([chunks objectAtIndex:2])]) {
            ret = [mspController performSelector:NSSelectorFromString([chunks objectAtIndex:2])];
        }
    } 
#pragma clang diagnostic pop
    
    if ([ret isKindOfClass:[NSDictionary class]]) {
        NSString *rendering = [GRMustacheTemplate renderObject:ret fromContentsOfFile:[FileUtil getMspPath:mspRelativePath] error:nil];
        
        if (rendering == nil) {
            NSString *output = @"Server page error, please try to restart app.";
            return [[MSPResponse alloc] initWithData: [output dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:ret];
        
        [dictionary setObject:rendering forKey:@"content"];
        
        
        NSString *output = [GRMustacheTemplate renderObject:dictionary fromContentsOfFile:[FileUtil getMspPath:@"/layouts/default"] error:nil];
        return [[MSPResponse alloc] initWithData: [output dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return ret;
}




@end
