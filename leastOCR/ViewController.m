//
//  ViewController.m
//  AipOcrDemo
//
//  Created by chenxiaoyu on 17/2/7.
//  Copyright © 2017年 baidu. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "AipOcrSdk.h"
#import "MBProgressHUD+MP.h"
#import "EdgeTimeHelper.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;


/**识别内容textView*/
@property (weak, nonatomic) IBOutlet UITextView *constantTextView;

@property (weak, nonatomic) IBOutlet UITextField *numTextFiled;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageView_W;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageView_H;

@property (nonatomic, strong) NSMutableArray<NSArray<NSString *> *> *actionList;

@property(nonatomic,assign)NSInteger Type;
/**是否是扫描操作*/
@property(nonatomic,assign,getter=isScan)BOOL isScan;
/**是否是出租车资格证*/
@property(nonatomic,assign,getter=isTaxiCard)BOOL isTaxiCard;
/**是否是线路牌*/
@property(nonatomic,assign,getter=isLineCard)BOOL isLineCard;

@end

@implementation ViewController {
    // 默认的识别成功的回调
    void (^_successHandler)(id);
    // 默认的识别失败的回调
    void (^_failHandler)(NSError *);
}



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    self.title = @"百度OCR";
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    //#error 【必须！】请在 ai.baidu.com中新建App, 绑定BundleId后，在此填写授权信息
    //#error 【必须！】上传至AppStore前，请使用lipo移除AipBase.framework、AipOcrSdk.framework的模拟器架构，参考FAQ：ai.baidu.com/docs#/OCR-iOS-SDK/top
    //     授权方法1：在此处填写App的Api Key/Secret Key
    [[AipOcrService shardService] authWithAK:@"9EvAtlZvWBBR4yPiEctLwaGG" andSK:@"NDm6j8YNPHWTiMqcG2GQAxDdDpR938pG"];
    
    //  请求内容数据
    [self configureData];
    //  扫描结果回调
    [self configCallback];
    
}

#pragma mark -------------------------    自定义函数方法   -------------------------------

/**
 数据list
 */
- (void)configureData {
    
    self.actionList = [NSMutableArray array];
    
    [self.actionList addObject:@[@"【车牌】识别", @"plateLicenseOCR"]];
    
    [self.actionList addObject:@[@"【路线牌】正面拍照识别", @"lineCardgeneralBasicOCR"]];
    
    [self.actionList addObject:@[@"【出租车资格证】识别", @"taxiCargeneralBasicOCR"]];
    
    [self.actionList addObject:@[@"【从业资格证】正面拍照识别", @"EmpoyledCardOCROnlineFront"]];
    
    [self.actionList addObject:@[@"【表格】文字通用识别", @"generalBasicOCR"]];
    
    [self.actionList addObject:@[@"【身份证正面】拍照识别", @"idcardOCROnlineFront"]];
    
    //    [self.actionList addObject:@[@"身份证正面【扫描识别】", @"localIdcardOCROnlineFront"]];
}

/**
 基础文字识别[表格]
 */
- (void)generalBasicOCR{
    self.isTaxiCard = NO;
    self.isLineCard = NO;
    __weak typeof(self) weakSelf  = self;
    
    AipGeneralVC * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image,NSDate *StartTime)  {
        
        [MBProgressHUD showMessage:@"识别中..." ToView:self.view];
        
        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
        [[AipOcrService shardService] detectTextBasicFromImage:image
                                                   withOptions:options
                                                successHandler:_successHandler
                                                   failHandler:_failHandler];
        
        
        [self demoDoThingImage:image startTime:StartTime];
    }];
    vc.GeneralVCscale = [self.numTextFiled.text doubleValue];
    vc.iSTaxiCard = NO;
    vc.isLineCard = NO;
    vc.isCarPlate = NO;
    [self presentViewController:vc animated:YES completion:nil];
}

/**
 基础文字识别【出租车资格证识别】
 */
- (void)taxiCargeneralBasicOCR{
    __weak typeof(self) weakSelf  = self;
    self.isTaxiCard = YES;
    self.isLineCard = NO;
    AipGeneralVC * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image,NSDate *StartTime) {
        
        [MBProgressHUD showMessage:@"识别中..." ToView:self.view];
        
        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
        [[AipOcrService shardService] detectTextBasicFromImage:image
                                                   withOptions:options
                                                successHandler:_successHandler
                                                   failHandler:_failHandler];
        
        //        [weakSelf performSelectorOnMainThread:@selector(demoDoThingImage:startTime:) withObject:nil waitUntilDone:NO];
        
        [self demoDoThingImage:image startTime:StartTime];
    }];
    vc.GeneralVCscale = [self.numTextFiled.text doubleValue];
    vc.iSTaxiCard = YES;
    vc.isLineCard = NO;
    vc.isCarPlate = NO;
    [self presentViewController:vc animated:YES completion:nil];
}

/**
 基础文字识别【线路牌资格证识别】
 */
- (void)lineCardgeneralBasicOCR{
    self.isTaxiCard = NO;
    self.isLineCard = YES;
    AipGeneralVC * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image,NSDate *StartTime) {
        
        [MBProgressHUD showMessage:@"识别中..." ToView:self.view];
        
        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
        [[AipOcrService shardService] detectTextBasicFromImage:image
                                                   withOptions:options
                                                successHandler:_successHandler
                                                   failHandler:_failHandler];
        [self demoDoThingImage:image startTime:StartTime];
        
    }];
    vc.GeneralVCscale = [self.numTextFiled.text doubleValue];
    vc.iSTaxiCard = NO;
    vc.isLineCard = YES;
    vc.isCarPlate = NO;
    [self presentViewController:vc animated:YES completion:nil];
}


//身份证正面
- (void)idcardOCROnlineFront {
    self.isTaxiCard = NO;
    self.isLineCard = NO;
    
    AipCaptureCardVC * vc = [AipCaptureCardVC ViewControllerWithCardType:CardTypeIdCardFont
                                                         andImageHandler:^(UIImage *image,NSDate *StartTime) {
                                                             [MBProgressHUD showMessage:@"识别中..." ToView:self.view];
                                                             
                                                             [[AipOcrService shardService] detectIdCardFrontFromImage:image
                                                                                                          withOptions:nil
                                                                                                       successHandler:_successHandler                                                                                failHandler:_failHandler];
                                                             [self demoDoThingImage:image startTime:StartTime];
                                                         }];
    
    vc.CaptureCardscale = [self.numTextFiled.text doubleValue];
    vc.iSEmployedCard = NO;
    [self presentViewController:vc animated:YES completion:nil];
    
}

//【从业资格证拍照识别---】身份证正面的接口
- (void)EmpoyledCardOCROnlineFront {
    self.isTaxiCard = NO;
    self.isLineCard = NO;
    
    AipCaptureCardVC * vc = [AipCaptureCardVC ViewControllerWithCardType:CardTypeIdCardFont
                                                         andImageHandler:^(UIImage *image,NSDate *StartTime) {
                                                             [MBProgressHUD showMessage:@"识别中..." ToView:self.view];
                                                             
                                                             
                                                             [[AipOcrService shardService] detectIdCardFrontFromImage:image
                                                                                                          withOptions:nil
                                                                                                       successHandler:_successHandler                                                                                failHandler:_failHandler];
                                                             [self demoDoThingImage:image startTime:StartTime];
                                                         }];
    vc.CaptureCardscale = [self.numTextFiled.text doubleValue];
    vc.iSEmployedCard = YES;//  是从业资格证
    [self presentViewController:vc animated:YES completion:nil];
}

/**车牌*/
- (void)plateLicenseOCR{
    self.isTaxiCard = NO;
    self.isLineCard = NO;
    
    AipGeneralVC * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image,NSDate *StartTime){
        
        [MBProgressHUD showMessage:@"识别中..." ToView:self.view];
        
        [[AipOcrService shardService] detectPlateNumberFromImage:image
                                                     withOptions:nil
                                                  successHandler:_successHandler
                                                     failHandler:_failHandler];
        [self demoDoThingImage:image startTime:StartTime];
        
    }];
    
    vc.GeneralVCscale = [self.numTextFiled.text doubleValue];
    vc.iSTaxiCard = NO;
    vc.isLineCard = NO;
    vc.isCarPlate = YES;
    [self presentViewController:vc animated:YES completion:nil];
}

//  扫描识别身份证正面
- (void)localIdcardOCROnlineFront {
    self.isTaxiCard = NO;
    self.isLineCard = NO;
    
    self.isScan = YES;
    
    AipCaptureCardVC * vc = [AipCaptureCardVC ViewControllerWithCardType:CardTypeLocalIdCardFont
                                                         andImageHandler:^(UIImage *image,NSDate *StartTime) {
                                                             [MBProgressHUD showMessage:@"识别中..." ToView:self.view];
                                                             
                                                             
                                                             [[AipOcrService shardService] detectIdCardFrontFromImage:image
                                                                                                          withOptions:nil
                                                                                                       successHandler:^(id result){
                                                                                                           _successHandler(result);
                                                                                                           // 这里可以存入相册
                                                                                                           //UIImageWriteToSavedPhotosAlbum(image, nil, nil, (__bridge void *)self);
                                                                                                       }
                                                                                                          failHandler:_failHandler];
                                                             
                                                         }];
    
    vc.CaptureCardscale = [self.numTextFiled.text doubleValue];
    vc.iSEmployedCard = NO;
    [self presentViewController:vc animated:YES completion:nil];
    
    
}



#pragma mark -------------------------    识别结果   -------------------------------

/**
 识别结果
 */
- (void)configCallback {
    
    __weak typeof(self) weakSelf = self;
    
    // 这是默认的识别成功的回调
    _successHandler = ^(id result){
        
        NSLog(@"%@", result);
        
        NSString *title = @"识别结果";
        
        NSLog(@"扫描=%d,出租车资格证=%d,线路牌=%d ",weakSelf.isScan,weakSelf.isTaxiCard,weakSelf.isLineCard);
        
        if (weakSelf.isTaxiCard) {//  出租车资格证
            
            [weakSelf ocrTaxiCardSuccessful:result];
            
        }else if (weakSelf.isLineCard) {//  线路牌
            
            [weakSelf ocrLinePlateSuccessful:result];
            
        }else{
            
            NSMutableString *message = [NSMutableString string];
            
            if(result[@"words_result"]){
                if([result[@"words_result"] isKindOfClass:[NSDictionary class]]){
                    
                    [result[@"words_result"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        
                        if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                            [message appendFormat:@"%@: %@\n", key, obj[@"words"]];
                        }else{
                            [message appendFormat:@"%@: %@\n", key, obj];
                        }
                    }];
                    
                }else if([result[@"words_result"] isKindOfClass:[NSArray class]]){
                    
                    for(NSDictionary *obj in result[@"words_result"]){
                        
                        if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                            [message appendFormat:@"%@\n", obj[@"words"]];
                        }else{
                            [message appendFormat:@"%@\n", obj];
                        }
                        
                    }
                }
                
            }else{
                
                [message appendFormat:@"%@", result];
            }
            
            weakSelf.endTime = [NSDate date];
            
            if (!weakSelf.isScan) {//  扫描操作
                //  隐藏hudView
                [weakSelf performSelectorOnMainThread:@selector(hideHudView) withObject:nil waitUntilDone:NO];
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }];
        }
    };
    
    _failHandler = ^(NSError *error){
        
        
        
        NSLog(@"%@", error);
        
        weakSelf.endTime = [NSDate date];
        
        [weakSelf performSelectorOnMainThread:@selector(hideHudView) withObject:nil waitUntilDone:NO];
        
        NSString *msg = [NSString stringWithFormat:@"%li:%@", (long)[error code], [error localizedDescription]];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[[UIAlertView alloc] initWithTitle:@"识别失败" message:msg delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }];
        
        
    };
    
}


/**
 识别出粗车资格证
 
 @param result result
 */
- (void)ocrTaxiCardSuccessful:(id)result {
    
    
    NSLog(@"result = %@",result);
    
    NSMutableString *message = [NSMutableString string];
    
    if(result[@"words_result"]){
        
        for(NSDictionary *obj in result[@"words_result"]){
            
            NSString *pureNumbers = [[obj[@"words"] componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
            
            
            if (pureNumbers.length==6) {
                
                [message appendFormat:@"%@",pureNumbers];
                
                NSLog(@"弹出：%@",message);
            }else{
                
                NSLog(@"过滤的字段：%@",obj[@"words"]);
            }
            
        }
        
        self.endTime = [NSDate date];
        //  隐藏hudView
        [self performSelectorOnMainThread:@selector(hideHudView) withObject:nil waitUntilDone:NO];
        
        
        [self alertActionTitle:@"出租车服务资格证号" message:message];
        
    }else{
        
        [message appendFormat:@"%@", result];
        
        self.endTime = [NSDate date];
        //  隐藏hudView
        [self performSelectorOnMainThread:@selector(hideHudView) withObject:nil waitUntilDone:NO];
        
        [self alertActionTitle:@"识别失败" message:message];
    }
    
}


/**
 识别线路牌
 
 @param result result
 */
- (void)ocrLinePlateSuccessful:(id)result {
    
    //    NSLog(@"result = %@",result);
    
    NSMutableString *message = [NSMutableString string];
    
    if(result[@"words_result"]){
        
        for(NSDictionary *obj in result[@"words_result"]){
            
            NSString *pureNumbers = [[obj[@"words"] componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
            
            if ((pureNumbers.length==0 )&& ([obj[@"words"] rangeOfString:@"-"].location != NSNotFound || [obj[@"words"] rangeOfString:@"一"].location != NSNotFound)) {//  字符里面没有数字并且含有-或者一
                
                [message appendFormat:@"%@",obj[@"words"]];
                
                NSLog(@"弹出：%@",message);
                
            }else{
                
                NSLog(@"过滤字段： %@",obj[@"words"]);
            }
        }
        self.endTime = [NSDate date];
        //  隐藏hudView
        [self performSelectorOnMainThread:@selector(hideHudView) withObject:nil waitUntilDone:NO];
        
        [self alertActionTitle:@"起点-终点" message:message];
        
    }else{
        
        [message appendFormat:@"%@", result];
        
        self.endTime = [NSDate date];
        //  隐藏hudView
        [self performSelectorOnMainThread:@selector(hideHudView) withObject:nil waitUntilDone:NO];
        
        [self alertActionTitle:@"识别失败" message:message];
        
    }
}

-(void)alertActionTitle:(NSString *)title message:(NSMutableString *)message{
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }];
    
}

#pragma mark ---------------------    界面函数方法处理    -------------------------

-(void)demoDoThingImage:(UIImage *)image startTime:(NSDate *)startTime{
    
    NSData * imageData = UIImageJPEGRepresentation(image,0.7);
    
    self.sizeLabel.text = [NSString stringWithFormat:@"size:%lukb",[imageData length]/1024];
    
    self.imageView_W.constant = image.size.width/3;
    self.imageView_H.constant = image.size.height/3;
    
    self.imageView.image = image;
    
    
    self.startTime = startTime;
    
}

//  计算请求时间
-(void)dealStayTime{
    
    EdgeTimeHelper *timeHelper = [[EdgeTimeHelper alloc]init];
    
    self.stayTime = [timeHelper dealWithStayTimeStartTime:self.startTime endTime:self.endTime];
    
    self.timeLabel.text = self.stayTime;
}

/**
 隐藏hudView
 */
-(void)hideHudView{
    
    [MBProgressHUD hideHUDForView:self.view];
    //  时间处理
    [self dealStayTime];
}
- (void)updateTableView {
    
    [self.tableView reloadData];
}

- (void)mockBundlerIdForTest {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self mockClass:[NSBundle class] originalFunction:@selector(bundleIdentifier) swizzledFunction:@selector(sapicamera_bundleIdentifier)];
#pragma clang diagnostic pop
}

- (void)mockClass:(Class)class originalFunction:(SEL)originalSelector swizzledFunction:(SEL)swizzledSelector {
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}

#pragma mark -------------------------    tableView代理  -------------------------------

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.actionList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"cell";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    NSArray *actions = self.actionList[indexPath.row];
    
    cell.textLabel.text = actions[0];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.Type = indexPath.row+1;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SEL funSel = NSSelectorFromString(self.actionList[indexPath.row][1]);
    if (funSel) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:funSel];
#pragma clang diagnostic pop
    }
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -------------------------    生命周期  -------------------------------

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isScan = NO;
    
    [self updateTableView];
    
    self.timeLabel.text = @"";
    //    self.sizeLabel.text = @"";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}




//#pragma mark - Action
//
//
//- (void)generalEnchancedOCR{
//
//    AipGeneralVC * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
//        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
//
//        [[AipOcrService shardService] detectTextEnhancedFromImage:image
//                                                      withOptions:options
//                                                   successHandler:_successHandler
//                                                      failHandler:_failHandler];
//
//    }];
//    [self presentViewController:vc animated:YES completion:nil];
//}


/**文字识别含位置信息*/
//- (void)generalOCR{
//
//    AipGeneralVC * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
////         在这个block里，image即为切好的图片，可自行选择如何处理
//        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
//        [[AipOcrService shardService] detectTextFromImage:image
//                                              withOptions:options
//                                           successHandler:_successHandler
//                                              failHandler:_failHandler];
//
//
//    }];
//
//    [self presentViewController:vc animated:YES completion:nil];
//}

//- (void)generalAccurateOCR{
//
//    AipGeneralVC * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
//        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
//        [[AipOcrService shardService] detectTextAccurateFromImage:image
//                                                      withOptions:options
//                                                   successHandler:_successHandler
//                                                      failHandler:_failHandler];
//
//    }];
//    [self presentViewController:vc animated:YES completion:nil];
//}

//
//- (void)webImageOCR{
//
//    AipGeneralVC * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
//
//        [[AipOcrService shardService] detectWebImageFromImage:image
//                                                  withOptions:nil
//                                               successHandler:_successHandler
//                                                  failHandler:_failHandler];
//    }];
//    [self presentViewController:vc animated:YES completion:nil];
//}
//
//- (void)localIdcardOCROnlineBack{
//
//    AipCaptureCardVC * vc =
//    [AipCaptureCardVC ViewControllerWithCardType:CardTypeLocalIdCardBack
//                                 andImageHandler:^(UIImage *image) {
//
//                                     [[AipOcrService shardService] detectIdCardBackFromImage:image
//                                                                                 withOptions:nil
//                                                                              successHandler:^(id result){
//                                                                                  _successHandler(result);
//                                                                                  // 这里可以存入相册
//                                                                                  // UIImageWriteToSavedPhotosAlbum(image, nil, nil, (__bridge void *)self);
//                                                                              }
//                                                                                 failHandler:_failHandler];
//                                 }];
//    [self presentViewController:vc animated:YES completion:nil];
//}

//- (void)bankCardOCROnline{
//
//    AipCaptureCardVC * vc =
//    [AipCaptureCardVC ViewControllerWithCardType:CardTypeBankCard
//                                 andImageHandler:^(UIImage *image) {
//
//                                     [[AipOcrService shardService] detectBankCardFromImage:image
//                                                                            successHandler:_successHandler
//                                                                               failHandler:_failHandler];
//
//                                 }];
//    [self presentViewController:vc animated:YES completion:nil];
//
//}

//
////  驾驶证
//- (void)drivingLicenseOCR{
//
//    AipGeneralVC * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
//
//        [[AipOcrService shardService] detectDrivingLicenseFromImage:image
//                                                        withOptions:nil
//                                                     successHandler:_successHandler
//                                                        failHandler:_failHandler];
//
//    }];
//
//
//    [self presentViewController:vc animated:YES completion:nil];
//}
////行驶证
//- (void)vehicleLicenseOCR{
//
//    AipGeneralVC * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
//
//        [[AipOcrService shardService] detectVehicleLicenseFromImage:image
//                                                        withOptions:nil
//                                                     successHandler:_successHandler
//                                                        failHandler:_failHandler];
//    }];
//    [self presentViewController:vc animated:YES completion:nil];
//}

//- (void)businessLicenseOCR{
//
//    AipGeneralVC * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
//
//        [[AipOcrService shardService] detectBusinessLicenseFromImage:image
//                                                         withOptions:nil
//                                                      successHandler:_successHandler
//                                                         failHandler:_failHandler];
//
//    }];
//    [self presentViewController:vc animated:YES completion:nil];
//}
//、、票据
//- (void)receiptOCR{
//
//    AipGeneralVC * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
//
//        [[AipOcrService shardService] detectReceiptFromImage:image
//                                                 withOptions:nil
//                                              successHandler:_successHandler
//                                                 failHandler:_failHandler];
//
//    }];
//    [self presentViewController:vc animated:YES completion:nil];
//}
/**
 身份证反面识别
 */
//- (void)idcardOCROnlineBack{
//
//    AipCaptureCardVC * vc =
//    [AipCaptureCardVC ViewControllerWithCardType:CardTypeIdCardBack
//                                 andImageHandler:^(UIImage *image) {
//
//                                     //                                     [[AipOcrService shardService] detectIdCardBackFromImage:image
//                                     //                                                                                 withOptions:nil
//                                     //                                                                              successHandler:_successHandler
//                                     //                                                                                 failHandler:_failHandler];
//
//                                     [self demoDoThingImage:image];
//                                 }];
//    vc.CaptureCardscale = [self.numTextFiled.text doubleValue];
//
//    [self presentViewController:vc animated:YES completion:nil];
//}

//
///**
// 文字识别高精度版本
// */
//- (void)generalAccurateBasicOCR{
//
//    AipGeneralVC * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image) {
//        //        NSDictionary *options = @{@"language_type": @"CHN_ENG", @"detect_direction": @"true"};
//        //        [[AipOcrService shardService] detectTextAccurateBasicFromImage:image
//        //                                                           withOptions:options
//        //                                                        successHandler:_successHandler
//        //                                                           failHandler:_failHandler];
//        //
//        [self demoDoThingImage:image];}];
//    vc.GeneralVCscale = [self.numTextFiled.text doubleValue];
//
//    [self presentViewController:vc animated:YES completion:nil];
//}

@end
