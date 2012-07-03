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

@synthesize rowid, title, note, created;


+ (NSArray *)findAll:(NSInteger)perPage page:(NSInteger)page
{
    NSInteger rowStart = (page - 1) * perPage;
    NSMutableArray *tasks = [NSMutableArray array];
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = [NSString stringWithFormat:@"select rowid, title, created from tasks order by created desc limit %d,%d", rowStart, perPage];
    FMResultSet *result = [db executeQuery:sql];
    while ([result next]) {
        Task *task = [[Task alloc] init];
        task.rowid = [result intForColumn:@"rowid"];
        task.title = [result stringForColumn:@"title"];
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
    NSString *sql = [NSString stringWithFormat: @"select rowid, title, note, created from tasks where rowid = %d", rowid];
    FMResultSet *result = [db executeQuery:sql];
    while ([result next]) {
        task.rowid = [result intForColumn:@"rowid"];
        task.title = [result stringForColumn:@"title"];
        task.note = [result stringForColumn:@"note"];
        task.created = [result dateForColumn:@"created"];
    }
    [result close];
    [db close];
    return task;
}

+ (NSInteger)create:(Task *)task
{
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"insert into tasks (title, note) values (?, ?)";
    [db executeUpdate: sql, task.title, task.note];
    NSInteger lastId = [db lastInsertRowId];
    [db close];
    
    //[[NSNotificationCenter defaultCenter] taskNotificationName:@"TasksChanged" object:nil];
    return lastId;
}

+ (void)update:(Task *)task
{
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"update tasks set title = ?, note = ? where rowid = ?";
    [db executeUpdate: sql, task.title, task.note, [NSNumber numberWithInteger:task.rowid]];
    [db close];
    
    //[[NSNotificationCenter defaultCenter] taskNotificationName:@"TasksChanged" object:nil];
}

+ (void)remove:(NSInteger)rowid
{
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"delete from tasks where rowid = ?";
    [db executeUpdate: sql, [NSNumber numberWithInteger:rowid]];
    [db close];
    
    //[[NSNotificationCenter defaultCenter] taskNotificationName:@"TasksChanged" object:nil];
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
