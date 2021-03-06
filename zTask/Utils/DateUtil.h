//
//  DateUtil.h
//  zTask
//
//  Created by ming lin on 7/2/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject

+ (NSDate *)stringToDate:(NSString *)dateStr format:(NSString *)format;
+ (NSInteger)getIntervalDay:(NSDate *)date;
+ (NSString *)formatDateWithoutSecond:(NSDate *)date;
+ (NSString *)formatDate:(NSDate *)date to:(NSString *)formatString;
+ (NSString *)dateToInterval:(NSDate *)date;
+ (NSArray *)getWeekdays:(NSDate *)selectedDate;

@end
