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
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) NSString *created;

+ (NSArray *)findAll:(NSInteger)perPage page:(NSInteger)page;
+ (NSInteger)countAll;
+ (Task *)find:(NSInteger)rowid;
+ (NSInteger)create:(Task *)task;
+ (void)update:(Task *)task;
+ (void)remove:(NSInteger)rowid;

- (NSData *)jsonData;

@end

