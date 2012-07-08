//
//  Project.m
//  zTask
//
//  Created by ming lin on 6/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "Project.h"
#import "DBUtil.h"

@implementation Project

@synthesize rowid, name, created;

+ (NSArray *)findAll
{
    NSMutableArray *projects = [NSMutableArray array];
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = [NSString stringWithFormat:@"select rowid, name, created from projects order by created desc"];
    FMResultSet *result = [db executeQuery:sql];
    while ([result next]) {
        Project *project = [[Project alloc] init];
        project.rowid = [result intForColumn:@"rowid"];
        project.name = [result stringForColumn:@"name"];
        project.created = [result dateForColumn:@"created"];
        
        [projects addObject:project];
    }
    [result close];
    [db close];
    return projects;
}

+ (NSInteger)countAll
{
    NSInteger total = 0;
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"select count(*) from projects";
    FMResultSet *result = [db executeQuery:sql];
    if ([result next]) {
        total = [result intForColumnIndex:0];
    }
    [result close];
    [db close];
    return total;
}

+ (Project *)find:(NSInteger)rowid
{
    Project *project = [[Project alloc] init];
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = [NSString stringWithFormat: @"select rowid, name, intro, created from projects where rowid = %d", rowid];
    FMResultSet *result = [db executeQuery:sql];
    while ([result next]) {
        project.rowid = [result intForColumn:@"rowid"];
        project.name = [result stringForColumn:@"name"];
        project.created = [result dateForColumn:@"created"];
    }
    [result close];
    [db close];
    return project;
}

+ (NSInteger)create:(Project *)project
{
    if (!project.created) {
        project.created = [NSDate date];
    }
    
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"insert into projects (name, created) values (?, ?)";
    [db executeUpdate: sql, project.name, project.created];
    int rowid = [db lastInsertRowId];
    [db close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProjectsChanged" object:nil];
    
    return rowid;
}

+ (void)update:(Project *)project
{
    FMDatabase *db = [DBUtil openDatabase];
    NSString *sql = @"update projects set name = ? where rowid = ?";
    [db executeUpdate: sql, project.name, [NSNumber numberWithInteger:project.rowid]];
    [db close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProjectsChanged" object:nil];
}

+ (void)remove:(NSInteger)rowid
{
    //remove db record
    FMDatabase *db = [DBUtil openDatabase];
    
    NSString *sql = @"delete from projects where rowid = ?";
    [db executeUpdate: sql, [NSNumber numberWithInteger:rowid]];
    [db close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProjectsChanged" object:nil];
}

@end
