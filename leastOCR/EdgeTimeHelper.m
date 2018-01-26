//
//  EdgeTimeHelper.m
//  百度APi调用
//
//  Created by comit on 2017/8/9.
//  Copyright © 2017年 comit. All rights reserved.
//

#import "EdgeTimeHelper.h"

@implementation EdgeTimeHelper

#pragma mark -----------------------------------时间处理--------------------------------------

/**
 处理持续时间数据
 */
-(NSString *)dealWithStayTimeStartTime:(NSDate *)startTime endTime:(NSDate *)endTime{
    
    NSDateComponents *cmps = [self dateFrom:startTime toDate:endTime];
    
    if(cmps.hour>=1){
        // 大于等于一小时
        return [NSString stringWithFormat:@"stay:%zdh %zdmin %zds",cmps.hour,cmps.minute,cmps.second];
    }else if (cmps.minute>=1){
        //  一小时以内
        return [NSString stringWithFormat:@"stay:%zdmin %zds",cmps.minute,cmps.second];
    }else{
        //  一分钟以内
        NSInteger  ms = cmps.nanosecond;
        
        NSString *msStr = [NSString stringWithFormat:@"%ld",(long)ms];
        
        msStr = [msStr substringToIndex:3];
        
        cmps.nanosecond = [msStr integerValue];
        
        return [NSString stringWithFormat:@"stay:%zd.%zds",cmps.second,cmps.nanosecond];
    }
}
/**比较时间*/
-(NSDateComponents *)dateFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    //  拿到日历
    NSCalendar *calend = [NSCalendar currentCalendar];
    //  比较时间
    NSCalendarUnit unit = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    
    return [calend components:unit fromDate:fromDate toDate:toDate options:kNilOptions];
}

/**
 处理时间string-date
 
 @param Date 时间
 @return date
 */
-(NSDate *)dealTimeStringToDate:(NSString *)Date{
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
    
    [dateFormat setDateFormat:@"MM-dd HH:mm:ss"];//设定时间格式,要注意跟下面的dateString匹配，否则日起将无效
    
    NSDate *date =[dateFormat dateFromString:Date];
    
    return date;
}

/**
 NSDate-string(月-日 时：分：秒)
 
 @param dateTime nsdate
 @return nsstring
 */
-(NSString *)dealTimeDateToString:(NSDate *)dateTime{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    dateFormatter.dateFormat = @"MM-dd HH:mm:ss";
    
    NSString *currentDateStr = [dateFormatter stringFromDate:dateTime];
    
    return currentDateStr;
}

@end
