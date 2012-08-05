//
//  Task.m
//  zTask
//
//  Created by ming lin on 6/22/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "Task.h"
#import "DBUtil.h"
#import "DateUtil.h"
#import "Attach.h"

@implementation Task

@synthesize rowid, projectId, title, note, status, flag, startDate, completed, dueDate, created;

- (NSString *)getStartDateStr
{
    return [DateUtil formatDate:startDate to:@"yyyy-MM-dd"];
}
- (NSString *)getCompletedStr
{
    return [DateUtil formatDate:completed to:@"yyyy-MM-dd"];
}
- (NSString *)getDueDateStr
{
    return [DateUtil formatDate:dueDate to:@"yyyy-MM-dd"];
}
- (NSString *)getCreatedStr
{
    return [DateUtil formatDate:created to:@"yyyy-MM-dd"];
}

+ (NSMutableArray *)findAll:(NSInteger)perPage page:(NSInteger)page
{
    NSInteger rowStart = (page - 1) * perPage;
    NSMutableArray *tasks = [NSMutableArray array];
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = [NSString stringWithFormat:@"select rowid, project_id, title, note, status, flag, start_date, completed, due_date, created from tasks order by created desc limit %d,%d", rowStart, perPage];
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
        task.completed = [result dateForColumn:@"completed"];
        task.dueDate = [result dateForColumn:@"due_date"];
        task.created = [result dateForColumn:@"created"];
        [tasks addObject:task];
    }
    [result close];
    [db close];
    return tasks;
}

+ (NSMutableArray *)findAllByConditions:(NSString *)conditions
{
    NSMutableArray *tasks = [NSMutableArray array];
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = [NSString stringWithFormat:@"select rowid, project_id, title, note, status, flag, start_date, completed, due_date, created from tasks %@", conditions];
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
        task.completed = [result dateForColumn:@"completed"];
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
    NSString *sql = [NSString stringWithFormat: @"select rowid, project_id, title, note, status, flag, start_date, completed, due_date, created from tasks where rowid = %d", rowid];
    FMResultSet *result = [db executeQuery:sql];
    while ([result next]) {
        task.rowid = [result intForColumn:@"rowid"];
        task.projectId = [result intForColumn:@"project_id"];
        task.title = [result stringForColumn:@"title"];
        task.note = [result stringForColumn:@"note"];
        task.status = [result boolForColumn:@"status"];
        task.flag = [result boolForColumn:@"flag"];
        task.startDate = [result dateForColumn:@"start_date"];
        task.completed = [result dateForColumn:@"completed"];
        task.dueDate = [result dateForColumn:@"due_date"];
        task.created = [result dateForColumn:@"created"];
    }
    [result close];
    [db close];
    return task;
}

+ (NSInteger)create:(Task *)task
{
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"insert into tasks (project_id, title, note, status, flag, start_date, completed, due_date) values (?, ?, ?, ?, ?, ?, ?, ?)";
    BOOL result = [db executeUpdate: sql, [NSNumber numberWithInteger:task.projectId], task.title, task.note, [NSNumber numberWithInteger:(task.status ? 1 : 0)], [NSNumber numberWithInteger:(task.flag ? 1 : 0)], task.startDate, task.completed, task.dueDate];
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
    NSString *sql = @"update tasks set project_id = ?, title = ?, note = ?, status = ?, flag = ?, start_date = ?, completed = ?, due_date = ? where rowid = ?";
    [db executeUpdate: sql, [NSNumber numberWithInteger:task.projectId], task.title, task.note, [NSNumber numberWithInteger:(task.status ? 1 : 0)], [NSNumber numberWithInteger:(task.flag ? 1 : 0)], task.startDate, task.completed, task.dueDate, [NSNumber numberWithInteger:task.rowid]];
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

+ (void)saveOrder:(NSArray *)tasks
{
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"update tasks set weight = ? where rowid = ?";
    int i = 0;
    for (Task *task in tasks) {
        i++;
        [db executeUpdate:sql, [NSNumber numberWithInteger:i], [NSNumber numberWithInteger:task.rowid]];
    }
    
    [db close];
}

- (NSMutableDictionary *)dictData
{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if (self.rowid) {
        [data setObject:[NSNumber numberWithInt: self.rowid] forKey:@"rowid"];
    }
    if (self.title) {
        [data setObject:self.title forKey:@"title"];
    }
    if (self.note) {
        [data setObject:self.note forKey:@"note"];
    }
    if (self.projectId) {
        [data setObject:[NSNumber numberWithInt: self.projectId] forKey:@"project_id"];
    }
    if (self.dueDate) {
        [data setObject:[self getDueDateStr] forKey:@"due_date"];
    }
    if (self.startDate) {
        [data setObject:[self getStartDateStr] forKey:@"start_date"];
    }
    if (self.completed) {
        [data setObject:[self getCompletedStr] forKey:@"completed"];
    }
    if (self.created) {
        [data setObject:[self getCreatedStr] forKey:@"created"];
    }
    
    [data setObject:[NSNumber numberWithBool:self.status] forKey:@"status"];
    [data setObject:[NSNumber numberWithBool:self.flag] forKey:@"flag"];
    return data;
}

- (NSData *)jsonData
{
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self dictData] options:NSJSONWritingPrettyPrinted error:&writeError];
    return jsonData;
}

- (NSData *)jsonDataWithAttaches
{
    NSMutableDictionary *dictData = [self dictData];
    NSArray *attaches = [Attach findAll:self.rowid];
    NSMutableArray *attachesDictArray = [NSMutableArray array];
    for (Attach *attach in attaches) {
        [attachesDictArray addObject:[attach dictData]];
    }
    [dictData setObject:attachesDictArray forKey:@"attaches"];
    
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictData options:NSJSONWritingPrettyPrinted error:&writeError];
    return jsonData;
}

@end
