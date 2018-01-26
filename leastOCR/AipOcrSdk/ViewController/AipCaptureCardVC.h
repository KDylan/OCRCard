//
//  AipCaptureCardVC.h
//  OCRLib
//  卡片识别VewController
//  Created by Yan,Xiangda on 16/11/9.
//  Copyright © 2016年 Baidu Passport. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^handler)(UIImage *,NSDate *StartTime);

typedef NS_ENUM(NSInteger, CardType) {
    CardTypeIdCardFont = 0,//  身份证正面
    CardTypeIdCardBack,//  身份证背面
    CardTypeBankCard,//  银行卡
    CardTypeLocalIdCardFont ,//  云端识别身份证正面
    CardTypeLocalIdCardBack,//   云端识别身份证反面
    CardTypeLocalBankCard
};

@interface AipCaptureCardVC : UIViewController

@property (nonatomic, assign) CardType cardType;

@property (nonatomic, copy) handler handler;

//+(UIViewController *)ViewControllerWithCardType:(CardType)type andImageHandler:(void (^)(UIImage *image))handler;
+(AipCaptureCardVC *)ViewControllerWithCardType:(CardType)type andImageHandler:(handler)handler;

@property (nonatomic, assign)   CGFloat CaptureCardscale;

/** 从业资格证 */
@property(nonatomic,assign,getter=iSEmployedCard)BOOL iSEmployedCard;


@end
