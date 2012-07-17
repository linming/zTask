//
//  Task.h
//  zTask
//
//  Created by ming lin on 6/22/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject

@property NSInteger rowid;
@property NSInteger projectId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *note;
@property BOOL status;
@property BOOL flag;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *dueDate;
@property (nonatomic, retain) NSDate *created;

+ (NSMutableArray *)findAll:(NSInteger)perPage page:(NSInteger)page;
+ (NSMutableArray *)findAllByConditions:(NSString *)conditions;
+ (NSInteger)countAll;
+ (Task *)find:(NSInteger)rowid;
+ (NSInteger)create:(Task *)task;
+ (void)update:(Task *)task;
+ (void)remove:(NSInteger)rowid;
+ (void)saveOrder:(NSArray *)tasks;

- (NSData *)jsonData;
- (NSData *)jsonDataWithAttaches;

@end

