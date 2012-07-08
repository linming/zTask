//
//  Task.m
//  zTask
//
//  Created by ming lin on 6/22/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "Task.h"
#import "DBUtil.h"

@implementation Task

@synthesize rowid, projectId, title, note, status, flag, startDate, dueDate, created;


+ (NSArray *)findAll:(NSInteger)perPage page:(NSInteger)page
{
    NSInteger rowStart = (page - 1) * perPage;
    NSMutableArray *tasks = [NSMutableArray array];
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = [NSString stringWithFormat:@"select rowid, project_id, title, note, status, flag, start_date, due_date, created from tasks order by created desc limit %d,%d", rowStart, perPage];
    FMResultSet *result = [db executeQuery:sql];
    while ([result next]) {
        Task *task = [[Task alloc] init];
        task.rowid = [result intForColumn:@"rowid"];
        task.projectId = [result intForColumn:@"project_id"];
        task.title = [result stringForColumn:@"title"];
        task.note = [result stringForColumn:@"note"];
        task.status = [result boolForColumn:@"status"];
        task.flag = [result boolForColumn:@"flag"];
        task.startDate = [result dateForColumn:@"start_date"];
        task.dueDate = [result dateForColumn:@"due_date"];
        task.created = [result dateForColumn:@"created"];
        [tasks addObject:task];
    }
    [result close];
    [db close];
    return tasks;
}

+ (NSInteger)countAll
{
    NSInteger total = 0;
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"select count(*) from tasks";
    FMResultSet *result = [db executeQuery:sql];
    if ([result next]) {
        total = [result intForColumnIndex:0];
    }
    [result close];
    [db close];
    return total;
}

+ (Task *)find:(NSInteger)rowid
{
    Task *task = [[Task alloc] init];
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = [NSString stringWithFormat: @"select rowid, project_id, title, note, status, flag, start_date, due_date, created from tasks where rowid = %d", rowid];
    FMResultSet *result = [db executeQuery:sql];
    while ([result next]) {
        task.rowid = [result intForColumn:@"rowid"];
        task.projectId = [result intForColumn:@"project_id"];
        task.title = [result stringForColumn:@"title"];
        task.note = [result stringForColumn:@"note"];
        task.status = [result boolForColumn:@"status"];
        task.flag = [result boolForColumn:@"flag"];
        task.startDate = [result dateForColumn:@"start_date"];
        task.dueDate = [result dateForColumn:@"due_date"];
        task.created = [result dateForColumn:@"created"];
    }
    [result close];
    [db close];
    return task;
}

+ (NSInteger)create:(Task *)task
{
    if (!task.created) {
        task.created = [NSDate date];
    }
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"insert into tasks (project_id, title, note, status, flag, start_date, due_date, created) values (?, ?, ?, ?, ?, ?, ?, ?)";
    BOOL result = [db executeUpdate: sql, [NSNumber numberWithInteger:task.projectId], task.title, task.note, [NSNumber numberWithInteger:(task.status ? 1 : 0)], [NSNumber numberWithInteger:(task.flag ? 1 : 0)], task.startDate, task.dueDate, task.created];
    if (!result) {
        NSLog(@"db error: %@", [db lastErrorMessage]);
    }
    NSInteger lastId = [db lastInsertRowId];
    [db close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TasksChanged" object:nil];
    return lastId;
}

+ (void)update:(Task *)task
{
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"update tasks set project_id = ?, title = ?, note = ?, status = ?, flag = ?, start_date = ?, due_date = ?, created = ? where rowid = ?";
    [db executeUpdate: sql, task.projectId, task.title, task.note, [NSNumber numberWithInteger:(task.status ? 1 : 0)], [NSNumber numberWithInteger:(task.flag ? 1 : 0)], task.startDate, task.dueDate, task.created, [NSNumber numberWithInteger:task.rowid]];
    [db close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TasksChanged" object:nil];
}

+ (void)remove:(NSInteger)rowid
{
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"delete from tasks where rowid = ?";
    [db executeUpdate: sql, [NSNumber numberWithInteger:rowid]];
    [db close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TasksChanged" object:nil];
}

- (NSData *)jsonData
{
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt: self.rowid], @"rowid",
                          self.title, @"title", 
                          nil];
    
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&writeError];
    return jsonData;
}

@end
