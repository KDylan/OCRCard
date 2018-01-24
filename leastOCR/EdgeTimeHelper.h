//
//  EdgeTimeHelper.h
//  百度APi调用
//
//  Created by comit on 2017/8/9.
//  Copyright © 2017年 comit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EdgeTimeHelper : NSObject

#pragma mark -----------------------------------时间处理----------------------------------
/**
 计算时间

 @param startTime 开始时间
 @param endTime 结束时间
 @return NSString
 */
-(NSString *)dealWithStayTimeStartTime:(NSDate *)startTime endTime:(NSDate *)endTime;

/**
 处理时间string-date
 
 @param Date 时间
 @return date
 */
-(NSDate *)dealTimeStringToDate:(NSString *)Date;
/**
 NSDate-string
 
 @param dateTime nsdate
 @return nsstring
 */
-(NSString *)dealTimeDateToString:(NSDate *)dateTime;
@end
