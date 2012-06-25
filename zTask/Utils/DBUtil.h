//
//  DBUtil.h
//  PortSite
//
//  Created by ming lin on 5/6/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"

#define kDBFile @"data.sqlite"

@interface DBUtil : NSObject

+ (void)createDatabase;
+ (FMDatabase *)openDatabase;


@end
