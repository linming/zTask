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
                       @"create table if not exists tasks (title text, content text, status text,created date default (datetime('now','localtime')))",
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
