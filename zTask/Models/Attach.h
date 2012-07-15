//
//  Attach.h
//  zTask
//
//  Created by ming lin on 6/30/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Attach : NSObject

@property NSInteger rowid;
@property NSInteger index;
@property NSInteger taskId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSDate *created;

@property (nonatomic, retain) NSString *audioStatus;

- (NSString *)getPath;
- (id)initWithDict:(NSDictionary *)dict;
- (NSMutableDictionary *)dictData;

+ (NSArray *)findAll:(NSInteger)taskId;
+ (NSInteger)countAll:(NSInteger)taskId;
+ (Attach *)find:(NSInteger)rowid;
+ (Attach *)findFirst:(NSInteger)taskId;
+ (NSInteger)create:(Attach *)attach;
+ (void)update:(Attach *)attach;
+ (void)remove:(Attach *)attach;

@end
