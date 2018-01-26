//
//  AipGeneralVC.h
//  OCRLib
//
//  Created by Yan,Xiangda on 2017/2/16.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^handler)(UIImage *,NSDate *StartTime);

@interface AipGeneralVC : UIViewController


@property (nonatomic, copy) handler handler;

//+(UIViewController *)ViewControllerWithHandler:(void (^)(UIImage *image))handler;

@property (nonatomic, assign)   CGFloat GeneralVCscale;

+(AipGeneralVC *)ViewControllerWithHandler:(handler)handler;

/** 出租车资格证 */
@property(nonatomic,assign,getter=iSTaxiCard)BOOL iSTaxiCard;
/** 线路牌 */
@property(nonatomic,assign,getter=isLineCard)BOOL isLineCard;
/** 车牌 */
@property(nonatomic,assign,getter=isCarPlate)BOOL isCarPlate;

//
///**开始时间*/
//@property(nonatomic,copy)getTimeStringBlock startTime;
//
//-(void)returnTimeBlock:(getTimeStringBlock)block;

@end
