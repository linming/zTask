//
//  Attach.m
//  zTask
//
//  Created by ming lin on 6/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "Attach.h"
#import "DBUtil.h"
#import "FileUtil.h"
#import "DateUtil.h"

@implementation Attach

@synthesize rowid, taskId, name, type, created, index;
@synthesize audioStatus;

- (NSString *)getPath
{
    NSString *relativePath = [NSString stringWithFormat:@"/files/tmp/%@", name];
    if (taskId) {
        [FileUtil makeFilePath:[NSString stringWithFormat:@"/files/tasks/%d", taskId]];
        relativePath = [NSString stringWithFormat:@"/files/tasks/%d/%@", taskId, name];
    }
    return [FileUtil getFilePath:relativePath];
}

- (NSString *)getCreatedInterval
{
    return [DateUtil dateToInterval:self.created];
}

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.rowid = [[dict objectForKey:@"rowid"] intValue];
        self.name = [dict objectForKey:@"name"];
        self.type = [dict objectForKey:@"type"];
    }
    return self;
}

+ (NSArray *)findAll:(NSInteger)taskId
{
    NSMutableArray *attaches = [NSMutableArray array];
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = [NSString stringWithFormat:@"select rowid, task_id, name, type, created from attaches where task_id = %d order by created", taskId];
    FMResultSet *result = [db executeQuery:sql];
    int index = 1;
    while ([result next]) {
        Attach *attach = [[Attach alloc] init];
        attach.index = index;
        index ++;
        attach.rowid = [result intForColumn:@"rowid"];
        attach.taskId = [result intForColumn:@"task_id"];
        attach.name = [result stringForColumn:@"name"];
        attach.type = [result stringForColumn:@"type"];
        attach.created = [result dateForColumn:@"created"];
        [attaches addObject:attach];
    }
    [result close];
    [db close];
    return attaches;
}

+ (NSInteger)countAll:(NSInteger)taskId
{
    NSInteger total = 0;
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = [NSString stringWithFormat: @"select count(*) from attaches where task_id = %d", taskId];
    FMResultSet *result = [db executeQuery:sql];
    if ([result next]) {
        total = [result intForColumnIndex:0];
    }
    [result close];
    [db close];
    return total;
}

+ (Attach *)find:(NSInteger)rowid
{
    Attach *attach = [[Attach alloc] init];
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = [NSString stringWithFormat: @"select rowid, task_id, name, type, created from attaches where rowid = %d", rowid];
    FMResultSet *result = [db executeQuery:sql];
    while ([result next]) {
        attach.rowid = [result intForColumn:@"rowid"];
        attach.taskId = [result intForColumn:@"task_id"];
        attach.name = [result stringForColumn:@"name"];
        attach.type = [result stringForColumn:@"type"];
        attach.created = [result dateForColumn:@"created"];
    }
    [result close];
    [db close];
    return attach;
}

+ (Attach *)findFirst:(NSInteger)taskId
{
    Attach *attach = [[Attach alloc] init];
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = [NSString stringWithFormat: @"select rowid, task_id, name, type, created from attaches where task_id = %d limit 1", taskId];
    FMResultSet *result = [db executeQuery:sql];
    while ([result next]) {
        attach.rowid = [result intForColumn:@"rowid"];
        attach.taskId = [result intForColumn:@"task_id"];
        attach.name = [result stringForColumn:@"name"];
        attach.type = [result stringForColumn:@"type"];
        attach.created = [result dateForColumn:@"created"];
    }
    [result close];
    [db close];
    return attach;
}

+ (NSInteger)create:(Attach *)attach
{
    if (!attach.created) {
        attach.created = [NSDate date];
    }
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"insert into attaches (task_id, name, type, created) values (?, ?, ?, ?)";
    [db executeUpdate: sql, [NSNumber numberWithInteger:attach.taskId], attach.name, attach.type, attach.created];
    NSInteger lastId = [db lastInsertRowId];
    [db close];
    
    //move file
    NSString *srcFile = [FileUtil getFilePath:[NSString stringWithFormat:@"/files/tasks/tmp/%@", attach.name]];
    NSString *destFile = [attach getPath];
    [FileUtil moveFile:srcFile target:destFile];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AttachesChanged" object:nil];
    return lastId;
}

+ (void)update:(Attach *)attach
{
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"update attaches set name = ? where rowid = ?";
    [db executeUpdate: sql, attach.name, [NSNumber numberWithInteger:attach.rowid]];
    [db close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AttachesChanged" object:nil];
}

+ (void)remove:(Attach *)attach
{
    //remove files
    NSString *attachPath = [attach getPath];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:attachPath]) {
        [fileManager removeItemAtPath:attachPath error:nil];
    }
    
    if (attach.rowid) {
        FMDatabase *db = [DBUtil openDatabase];
        NSString *sql = @"delete from attaches where rowid = ?";
        [db executeUpdate: sql, [NSNumber numberWithInteger:attach.rowid]];
        [db close];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AttachsChanged" object:nil];
    }

}

- (NSMutableDictionary *)dictData
{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if (self.rowid) {
        [data setObject:[NSNumber numberWithInt: self.rowid] forKey:@"rowid"];
    }
    if (self.name) {
        [data setObject:self.name forKey:@"name"];
    }
    if (self.type) {
        [data setObject:self.type forKey:@"type"];
    }
    if (self.taskId) {
        [data setObject:[NSNumber numberWithInt: self.taskId] forKey:@"task_id"];
    }
    if (self.created) {
        [data setObject:[DateUtil formatDate:self.created to:@"yyyy-MM-dd"] forKey:@"created"];
    }
    return data;
}

@end
