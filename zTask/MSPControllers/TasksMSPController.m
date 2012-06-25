//
//  TasksMSPController.m
//  zTask
//
//  Created by ming lin on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TasksMSPController.h"
#import "Task.h"
#import "Utils.h"

@implementation TasksMSPController

- (NSDictionary *)index
{
    NSInteger total = [Task countAll];
    NSInteger perPage = 20;
    NSString *page = [self.request.params objectForKey:@"page"];
    NSInteger currentPage = 1;
    if (page) {
        currentPage = [page intValue];
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:@"page" forKey:@"page"];
    [dictionary setObject:[Task findAll:perPage page:currentPage] forKey:@"tasks"];
    [dictionary setObject:[Utils getPaginationHtml:@"/tasks/index" total:total perPage:perPage currentPage:currentPage] forKey:@"pagination"];
    return dictionary;
}

@end
