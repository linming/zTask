//
//  DateUtil.m
//  zTask
//
//  Created by ming lin on 7/2/12.
//  Copyright (c) 2012 mingslab. All rights reserved.
//

#import "DateUtil.h"

@implementation DateUtil

+ (NSDate *)stringToDate:(NSString *)dateStr format:(NSString *)format
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:format];
    return [dateFormat dateFromString:dateStr]; 
}

+ (NSInteger)getIntervalDay:(NSDate *)date
{
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    NSDate *now = [[NSDate alloc] init];
    
    unsigned int unitFlags = NSDayCalendarUnit;
    
    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:date  toDate:now  options:0];
    
    return [conversionInfo day];
}

+ (NSString *)formatDateWithoutSecond:(NSDate *)date 
{
    return [DateUtil formatDate:date to:@"yyyy-MM-dd HH:mm"];
}

+ (NSString *)formatDate:(NSDate *)date to:(NSString *)formatString
{
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) 
        dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)dateToInterval:(NSDate *)date 
{
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) 
        dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSTimeInterval interval = -[date timeIntervalSinceNow];
    if (interval < 60) {
        return @"刚刚";
    } else if (interval < 60 * 60) {
        NSArray *periods = [[NSArray alloc] initWithObjects:@"秒", @"分钟" , @"小时", @"天", @"星期", @"月", @"年", @"十年", nil];
        float lengths[7] = { 60.0f, 60.0f, 24.0f, 7.0f , 4.35f, 12.0f, 10.0f };
        int i = 0;
        for (i = 0; interval >= lengths[i] && i < 7 ; i++) {
            interval = interval / lengths[i];
        }
        interval = round(interval);
        return [NSString stringWithFormat:@"%d%@前", (int)interval, [periods objectAtIndex:i]];
    } else {
        NSDate *now = [[NSDate alloc] init];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSDateComponents *nowComponents = [calendar components:unitFlags fromDate:now];
        NSDate *yesterday = [now dateByAddingTimeInterval: - 60 * 60 * 24];
        NSDateComponents *yesterdayComponents = [calendar components:unitFlags fromDate:yesterday];
        NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
        if ([dateComponents day] == [nowComponents day] && [dateComponents month] == [nowComponents month] && [dateComponents year] == [nowComponents year]) {
            return [NSString stringWithFormat:@"今天 %@", [dateFormatter stringFromDate:date]];
        } else if ([dateComponents day] == [yesterdayComponents day] && [dateComponents month] == [yesterdayComponents month] && [dateComponents year] == [yesterdayComponents year]) {
            return [NSString stringWithFormat:@"昨天 %@", [dateFormatter stringFromDate:date]];
        } else {
            return [NSString stringWithFormat:@"%d月%d日", [dateComponents month], [dateComponents day]];
        }
    } 
    
}


@end
