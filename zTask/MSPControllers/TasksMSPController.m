//
//  TasksMSPController.m
//  zTask
//
//  Created by ming lin on 6/22/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "TasksMSPController.h"
#import "MSPResponse.h"
#import "Project.h"
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
    [dictionary setObject:[Project findAll] forKey:@"projects"];
    [dictionary setObject:[Utils getPaginationHtml:@"/tasks/index" total:total perPage:perPage currentPage:currentPage] forKey:@"pagination"];
    return dictionary;
}

- (HTTPDataResponse *)add
{
    NSDictionary *headers = [[NSDictionary alloc] initWithObjectsAndKeys:@"text/json", @"Content-Type", nil];
    
    Task *task = [[Task alloc] init];
    task.title = @"";
    int taskId = [Task create:task];
    task.rowid = taskId;
    return [[MSPResponse alloc] initWithData:[task jsonData] headers:headers];
}

- (HTTPDataResponse *)edit:(NSString *)taskId
{
    NSDictionary *headers = [[NSDictionary alloc] initWithObjectsAndKeys:@"text/json", @"Content-Type", nil];
    
    Task *task = [Task find:[taskId intValue]];
    if ([self.request.params objectForKey:@"title"]) {
        task.title = [self.request.params objectForKey:@"title"];
    }
    if ([self.request.params objectForKey:@"project_id"]) {
        task.projectId = [[self.request.params objectForKey:@"project_id"] intValue];
    }
    
    if ([self.request.params objectForKey:@"note"]) {
        task.note = [self.request.params objectForKey:@"note"];
    }
    [Task update:task];
    return [[MSPResponse alloc] initWithData:[task jsonData] headers:headers];
}

- (HTTPDataResponse *)view:(NSString *)taskId
{
    NSDictionary *headers = [[NSDictionary alloc] initWithObjectsAndKeys:@"text/json", @"Content-Type", nil];
    
    Task *task = [Task find:[taskId intValue]];
    return [[MSPResponse alloc] initWithData:[task jsonData] headers:headers];
}


- (HTTPDataResponse *)delete
{
    NSDictionary *headers = [[NSDictionary alloc] initWithObjectsAndKeys:@"text/json", @"Content-Type", nil];
    
    NSString *taskId = [self.request.params objectForKey:@"task_id"];
    [Task remove:[taskId intValue]];
    return [[MSPResponse alloc] initWithData:[@"ok" dataUsingEncoding:NSUTF8StringEncoding] headers:headers];
}


@end
