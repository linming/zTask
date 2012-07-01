//
//  DBUtil.m
//  PortSite
//
//  Created by ming lin on 5/6/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "DBUtil.h"

@implementation DBUtil

+ (void)createDatabase
{
    NSArray *sqls = [NSArray arrayWithObjects:
                     @"create table if not exists projects (name text, created date default (datetime('now','localtime')))",
                     @"create table if not exists tasks (title text, note text, status text, project_id int, flag int, start_date date, due_date date, created date default (datetime('now','localtime')))",
                     @"create table if not exists attaches (name text, type text, task_id int, created date default (datetime('now','localtime')))",
                     nil];
    FMDatabase *db = [DBUtil openDatabase];
    
    for (NSString *sql in sqls) {
        [db executeUpdate:sql];
    }
    [db close];
}

+ (FMDatabase *)openDatabase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kDBFile];
    NSLog(@"db path: %@", dbPath);
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        return nil;
    }
    return db;
}

@end
