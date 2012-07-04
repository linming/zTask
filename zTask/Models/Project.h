//
//  Project.h
//  zTask
//
//  Created by ming lin on 6/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Project : NSObject

@property NSInteger rowid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *created;

+ (NSArray *)findAll;
+ (NSInteger)countAll;
+ (Project *)find:(NSInteger)rowid;
+ (NSInteger)create:(Project *)project;
+ (void)update:(Project *)project;
+ (void)remove:(NSInteger)rowid;

@end
