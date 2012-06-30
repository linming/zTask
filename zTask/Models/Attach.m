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

@implementation Attach

@synthesize rowid, taskId, name, path, type, created, index;
@synthesize audioStatus;


- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.rowid = [[dict objectForKey:@"rowid"] intValue];
        self.name = [dict objectForKey:@"name"];
    }
    return self;
}

+ (NSArray *)findAll:(NSInteger)taskId
{
    NSMutableArray *attaches = [NSMutableArray array];
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = [NSString stringWithFormat:@"select rowid, task_id, name, created from attaches where task_id = %d order by created", taskId];
    FMResultSet *result = [db executeQuery:sql];
    int index = 1;
    while ([result next]) {
        Attach *attach = [[Attach alloc] init];
        attach.index = index;
        index ++;
        attach.rowid = [result intForColumn:@"rowid"];
        attach.taskId = [result intForColumn:@"task_id"];
        attach.name = [result stringForColumn:@"name"];
        attach.created = [result stringForColumn:@"created"];
        
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
    NSString *sql = [NSString stringWithFormat: @"select rowid, task_id, name, intro, created from attaches where rowid = %d", rowid];
    FMResultSet *result = [db executeQuery:sql];
    while ([result next]) {
        attach.rowid = [result intForColumn:@"rowid"];
        attach.taskId = [result intForColumn:@"task_id"];
        attach.name = [result stringForColumn:@"name"];
        attach.created = [result stringForColumn:@"created"];
    }
    [result close];
    [db close];
    return attach;
}

+ (Attach *)findFirst:(NSInteger)taskId
{
    Attach *attach = [[Attach alloc] init];
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = [NSString stringWithFormat: @"select rowid, task_id, name, intro, created from attaches where task_id = %d limit 1", taskId];
    FMResultSet *result = [db executeQuery:sql];
    while ([result next]) {
        attach.rowid = [result intForColumn:@"rowid"];
        attach.taskId = [result intForColumn:@"task_id"];
        attach.name = [result stringForColumn:@"name"];
        attach.created = [result stringForColumn:@"created"];
    }
    [result close];
    [db close];
    return attach;
}

+ (NSInteger)create:(Attach *)attach
{
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"insert into attaches (task_id, name, intro) values (?, ?, ?)";
    [db executeUpdate: sql, [NSNumber numberWithInteger:attach.taskId], attach.name];
    NSInteger lastId = [db lastInsertRowId];
    [db close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AttachsChanged" object:nil];
    return lastId;
}

+ (void)update:(Attach *)attach
{
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"update attaches set name = ?, intro = ? where rowid = ?";
    [db executeUpdate: sql, attach.name, [NSNumber numberWithInteger:attach.rowid]];
    [db close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AttachsChanged" object:nil];
}

+ (void)remove:(NSInteger)rowid
{
    Attach *attach = [Attach find:rowid];
    //remove files
    NSString *albumRelativePath = [NSString stringWithFormat:@"/files/albums/%d", attach.taskId];
    NSString *albumPath = [FileUtil getFilePath:albumRelativePath];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSString *oriAttach = [[albumPath stringByAppendingPathComponent:@"ori"] stringByAppendingPathComponent:attach.name];
    if ([fileManager fileExistsAtPath:oriAttach]) {
        [fileManager removeItemAtPath:oriAttach error:nil];
    }
    
    NSString *thumbAttach = [[albumPath stringByAppendingPathComponent:@"thumb"] stringByAppendingPathComponent:attach.name];
    if ([fileManager fileExistsAtPath:thumbAttach]) {
        [fileManager removeItemAtPath:thumbAttach error:nil];
    }
    
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"delete from attaches where rowid = ?";
    [db executeUpdate: sql, [NSNumber numberWithInteger:rowid]];
    [db close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AttachsChanged" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AlbumsChanged" object:nil];
}

@end
