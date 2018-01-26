//
//  AipGeneralVC.m
//  OCRLib
//  通用文字识别ViewController
//  Created by Yan,Xiangda on 2017/2/16.
//  Copyright © 2017年 Baidu. All rights reserved.
//

#import "AipGeneralVC.h"
#import "AipCameraController.h"
#import "AipCameraPreviewView.h"
#import "AipCutImageView.h"
#import "AipNavigationController.h"
#import "AipOcrService.h"
#import "AipImageView.h"
#import <CoreMotion/CoreMotion.h>
#import "UIImage+AipCameraAddition.h"

#import <CoreText/CoreText.h>

#import "AipDisplayLink.h"
#import "MBProgressHUD+MP.h"
#import "PlateIDOverView.h"
#import <Masonry.h>

#import "IOSpeScaleLayoutLabel.h"
#define MyLocal(x, ...) NSLocalizedString(x, nil)

#define V_X(v)      v.frame.origin.x
#define V_Y(v)      v.frame.origin.y
#define V_H(v)      v.frame.size.height
#define V_W(v)      v.frame.size.width

static const NSInteger scanViewCornerRadius = 14;
// 图片拓边处理的系数
static const CGFloat cardScale = 0.02;

@interface AipGeneralVC () <UIAlertViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,AipCutImageDelegate>
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *albumButton;
@property (weak, nonatomic) IBOutlet UIButton *lightButton;
@property (weak, nonatomic) IBOutlet UIButton *checkCloseBtn;
@property (weak, nonatomic) IBOutlet UIButton *checkChooseBtn;
@property (weak, nonatomic) IBOutlet UIButton *transformButton;
@property (weak, nonatomic) IBOutlet UIView *checkView;
@property (weak, nonatomic) IBOutlet UIView *toolsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolViewBoom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkViewBoom;
@property (weak, nonatomic) IBOutlet AipCameraPreviewView *previewView;
@property (weak, nonatomic) IBOutlet AipCutImageView *cutImageView;

@property (weak, nonatomic) IBOutlet AipImageView *maskImageView;

@property (strong, nonatomic) AipCameraController *cameraController;

@property (strong, nonatomic) CMMotionManager  *cmmotionManager;
@property (assign, nonatomic) UIDeviceOrientation curDeviceOrientation;
@property (assign, nonatomic) UIDeviceOrientation imageDeviceOrientation;
@property (assign, nonatomic) UIImageOrientation imageOrientation;
@property (assign, nonatomic) CGSize size;

@property (strong, nonatomic) CAShapeLayer *shapeLayer;

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic)AVCaptureDevice *device;
//  对焦用的view
@property (nonatomic)UIView *focusView;

/**车牌扫描框*/
@property (weak, nonatomic) IBOutlet UIView *plateScanView;

/**出租车资格证扫描框*/
@property (weak, nonatomic) IBOutlet UIView *taxiScanView;

//@property (assign, nonatomic) BOOL displaylinkisOn;
//@property (assign, nonatomic) BOOL recognizedSucceed;

@property (weak, nonatomic) IBOutlet UIView *backGroundView;

@property(nonatomic,strong)IOSpeScaleLayoutLabel *msgLabel;

@end

@implementation AipGeneralVC

#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self config];
    
    //  初始化View
    [self ViewInit];
    
}

-(void)config{
    
    self.cameraController = [[AipCameraController alloc] initWithCameraPosition:AVCaptureDevicePositionBack];
    
    self.cutImageView.imgDelegate = self;
    
    self.imageDeviceOrientation = UIDeviceOrientationPortrait;
    
    self.device  = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //  判断设备方向
    [self setupCmmotionManager];
    
    if (self.GeneralVCscale == 0) {
        
        if (self.isLineCard||self.iSTaxiCard) {
            self.cutImageView.scale = 1.2;
            
        }else if(self.isCarPlate){
            
            self.cutImageView.scale = 1.5;
            
        }else{
            self.cutImageView.scale = 1.2;
        }
        
    }else{
        
        self.cutImageView.scale = self.GeneralVCscale;
    }
    NSLog(@" self.cutImageView.scale = %f", self.cutImageView.scale);
    
}


-(void)ViewInit{
    
    self.checkChooseBtn.hidden = YES;
    self.albumButton.hidden = YES;
    [self setupViews];
    //  添加扫描线
    self.backGroundView.hidden = NO;
    self.shapeLayer = [CAShapeLayer layer];
    [self.backGroundView.layer addSublayer:self.shapeLayer];
    
    if (self.iSTaxiCard) {// 是出租车从业资格证 或者 线路牌
        //  添加提示框
        [self addMessageLabelTitle:@"对齐出租车服务资格证正面"];
        //  显示出租车服务资格证扫描框
        self.taxiScanView.hidden = NO;
        
    }else if(self.isLineCard){
        //  添加提示框
        [self addMessageLabelTitle:@"对齐线路牌正面"];
        //  显示出租车服务资格证扫描框
        self.taxiScanView.hidden = NO;
    }else if (self.isCarPlate){//  车牌扫描框
        //  添加车牌扫描框
        [self addScanView];
        
        [self addMessageLabelTitle:@"对齐车牌"];
    }else{//  普通的拍照
        
        self.backGroundView.hidden = YES;
        //        self.maskImageView.hidden = NO;
        //  添加图片裁剪view
        [self setUpMaskImageView];
        
        //  显示选择按钮
        self.checkChooseBtn.hidden = NO;
    }
    
    //  添加对焦View
    [self addFousView];
    
}



#pragma mark --------------------------  添加View  ---------------------------------------

/**
 添加车牌扫描框
 */
-(void)addScanView{
    //  显示车牌扫描框
    self.plateScanView.hidden = NO;
    
    CGPoint center = self.view.center;
    //
    CGFloat Scrren_W = self.view.frame.size.width;
    
    CGFloat scanView_w = Scrren_W*0.80;
    CGFloat scanView_h = scanView_w*0.4;
    CGFloat scanView_x = center.x-scanView_w/2;
    CGFloat scanView_y = (center.y-49)-scanView_h/2;//  底部拍照toolBar高度98
    //初始化识别框
    PlateIDOverView *plateScanView = [[PlateIDOverView alloc] initWithFrame:CGRectMake(scanView_x, scanView_y, scanView_w, scanView_h)];
    plateScanView.backgroundColor = [UIColor clearColor];
    self.plateScanView = plateScanView;
    
    [self.view addSubview:plateScanView];
    
}

/**
 添加提示框
 */
-(void)addMessageLabelTitle:(NSString *)msgtitle{
    
    IOSpeScaleLayoutLabel *msgLabel = [[IOSpeScaleLayoutLabel alloc]init];
    self.msgLabel = msgLabel;
    msgLabel.text = msgtitle;
    msgLabel.textColor = [UIColor whiteColor];
    msgLabel.textAlignment = NSTextAlignmentCenter;
    msgLabel.font = [UIFont systemFontOfSize:14.0];
    msgLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    msgLabel.layer.masksToBounds = YES;
    msgLabel.layer.cornerRadius = 6.0;
    
    [self.view addSubview:msgLabel];
    
    [msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@200);
        make.height.equalTo(@26);
        
        if (self.iSTaxiCard || self.isLineCard) {
            make.top.equalTo(self.taxiScanView.mas_bottom).offset(20);
        }else if (self.isCarPlate){
            make.top.equalTo(self.plateScanView.mas_bottom).offset(20);
        }
        
    }];
}
/**
 添加view周围白色线条
 */
- (void)setupViews {
    
    self.navigationController.navigationBarHidden = YES;
    
    self.previewView.translatesAutoresizingMaskIntoConstraints = NO;
    self.previewView.session = self.cameraController.session;
    
    if (self.iSTaxiCard || self.isLineCard) {
        self.taxiScanView.translatesAutoresizingMaskIntoConstraints = NO;
        self.taxiScanView.layer.borderColor = [UIColor whiteColor].CGColor;//  显示白色线条
        self.taxiScanView.layer.borderWidth = 1.0;
        self.taxiScanView.layer.cornerRadius = scanViewCornerRadius *[self.class speScale];
    }else if(self.isCarPlate){
        self.plateScanView.translatesAutoresizingMaskIntoConstraints = NO;
        self.plateScanView.layer.borderColor = [UIColor clearColor].CGColor;
        self.plateScanView.layer.borderWidth = 1.0;
    }
    
}

- (void)setUpMaskImageView {
    //delegate 用做传递手势事件
    self.maskImageView.delegate = self.cutImageView;
    
    self.maskImageView.showMidLines = YES;
    self.maskImageView.needScaleCrop = YES;
    self.maskImageView.showCrossLines = YES;
    self.maskImageView.cropAreaCornerWidth = 55;
    self.maskImageView.cropAreaCornerHeight = 55;
    self.maskImageView.minSpace = 30;
    self.maskImageView.cropAreaCornerLineColor = [UIColor colorWithWhite:1 alpha:1];
    self.maskImageView.cropAreaBorderLineColor = [UIColor colorWithWhite:1 alpha:0.7];
    self.maskImageView.cropAreaCornerLineWidth = 3;
    self.maskImageView.cropAreaBorderLineWidth = 1;
    self.maskImageView.cropAreaMidLineWidth = 30;
    self.maskImageView.cropAreaMidLineHeight = 1;
    self.maskImageView.cropAreaCrossLineColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.maskImageView.cropAreaCrossLineWidth = 1;
    self.maskImageView.cropAspectRatio = 662/1010.0;
    
}

#pragma mark ----------------------------  添加聚焦功能 ---------------------------
/**
 添加对焦View
 */
-(void)addFousView{
    _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    _focusView.layer.borderWidth = 1.0;
    _focusView.layer.borderColor =[UIColor greenColor].CGColor;
    _focusView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_focusView];
    _focusView.hidden = YES;
    
    //  添加对焦手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    
    [self.view addGestureRecognizer:tapGesture];
}

/**
 聚焦手势
 
 @param gesture sender
 */
- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                _focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _focusView.hidden = YES;
            }];
        }];
    }
    
}

//-(void)returnTimeBlock:(getTimeStringBlock)block{
//
//    self.startTime  = block;
//}

#pragma mark -----------------------  按钮点击方法  ------------------------------

//设置背景图
- (void)setupCutImageView:(UIImage *)image fromPhotoLib:(BOOL)isFromLib {
    
    //    if (self.startTime) {
    //
    //        self.startTime([NSDate date]);
    //
    //    }else{
    //        NSLog(@"起始时间为空");
    //    }
    
    if (isFromLib) {
        
        self.cutImageView.userInteractionEnabled = YES;
        self.transformButton.hidden = NO;
    }else{
        
        self.cutImageView.userInteractionEnabled = NO;
        self.transformButton.hidden = YES;
    }
    self.previewView.hidden = YES;
    [self.cutImageView setBGImage:image fromPhotoLib:isFromLib useGestureRecognizer:NO];
    self.cutImageView.hidden = NO;
    self.closeButton.hidden = YES;
    self.checkViewBoom.constant = 0;
    self.toolViewBoom.constant = -V_H(self.toolsView);
    
    if (!self.isCarPlate&&!self.iSTaxiCard&&!self.isLineCard) {//  进入普通拍照
        
        self.maskImageView.hidden = NO;
        
    }
    [self shapeLayerChangeDark];
    
    if (self.isCarPlate||self.isLineCard||self.iSTaxiCard) {
        
        [self CutImageAndRequest];
    }
}

#pragma mark - Action handling -----------------  点击按钮响应方法  ------------------------

- (IBAction)turnLight:(id)sender {
    
    if(![self.device isTorchModeSupported:AVCaptureTorchModeOn] || ![self.device isTorchModeSupported:AVCaptureTorchModeOff]) {
        
        //ytodo [self passport_showTextHUDWithTitle:@"暂不支持照明功能" hiddenAfterDelay:0.2];
        return;
    }
    [self.previewView.session beginConfiguration];
    [self.device lockForConfiguration:nil];
    if (!self.lightButton.selected) { // 照明状态
        if (self.device.torchMode == AVCaptureTorchModeOff) {
            // Set torch to on
            [self.device setTorchMode:AVCaptureTorchModeOn];
        }
        
    }else
    {
        // Set torch to on
        [self.device setTorchMode:AVCaptureTorchModeOff];
    }
    self.lightButton.selected = !self.lightButton.selected;
    [self.device unlockForConfiguration];
    [self.previewView.session commitConfiguration];
}

- (IBAction)pressTransform:(id)sender {
    
    //向右转90'
    self.cutImageView.bgImageView.transform = CGAffineTransformRotate (self.cutImageView.bgImageView.transform, M_PI_2);
    if (self.imageOrientation == UIImageOrientationUp) {
        
        self.imageOrientation = UIImageOrientationRight;
    }else if (self.imageOrientation == UIImageOrientationRight){
        
        self.imageOrientation = UIImageOrientationDown;
    }else if (self.imageOrientation == UIImageOrientationDown){
        
        self.imageOrientation = UIImageOrientationLeft;
    }else{
        
        self.imageOrientation = UIImageOrientationUp;
    }
    
}

/**
 //上传图片识别结果
 
 @param sender sender
 */
- (IBAction)pressCheckChoose:(id)sender {
    
    if (!self.isCarPlate&&!self.isLineCard&&!self.iSTaxiCard) {
        
        [self CutImageAndRequest];
    }
}

-(void)CutImageAndRequest{
    
    NSLog(@"进来请求");
    //  开启截图
    CGRect rect  = [self TransformTheRect];
    
    UIImage *cutImage = [self.cutImageView cutImageFromView:self.cutImageView.bgImageView withSize:self.size atFrame:rect];
    
    UIImage *image = [UIImage sapicamera_rotateImageEx:cutImage.CGImage byDeviceOrientation:self.imageDeviceOrientation];
    
    UIImage *finalImage = [UIImage sapicamera_rotateImageEx:image.CGImage orientation:self.imageOrientation];
    
    if (self.handler) {
        
        //        self.handler(finalImage);
        self.handler(finalImage, [NSDate date]);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        //  保存图片到本地相册
        UIImageWriteToSavedPhotosAlbum(finalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }];
    
}

/**
 重新拍照
 
 @param sender sender
 */
- (IBAction)pressCheckBack:(id)sender {
    
    [self reset];
}


/**
 点击进行拍照
 
 @param sender sender
 */
- (IBAction)captureIDCard:(id)sender {
    
    __weak __typeof (self) weakSelf = self;
    [self.cameraController captureStillImageWithHandler:^(NSData *imageData) {
        
        
        [weakSelf setupCutImageView:[UIImage imageWithData:imageData]fromPhotoLib:NO];
    }];
}

//  退出页面
- (IBAction)pressBackButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
//  打开相册
- (IBAction)openPhotoAlbum:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypePhotoLibrary)]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //model 一个 View
        [self presentViewController:picker animated:YES completion:^{
            
            
        }];
    }
    else {
        NSAssert(NO, @" ");
    }
}

#pragma mark ------------------------ 自定义函数  --------------------------

//还原初始值
- (void)reset{
    
    self.imageOrientation = UIImageOrientationUp;
    self.closeButton.hidden = NO;
    self.previewView.hidden = NO;
    self.cutImageView.hidden = YES;
    self.maskImageView.hidden = YES;
    self.checkViewBoom.constant = -V_H(self.checkView);
    self.toolViewBoom.constant = 0;
    
    [self shapeLayerChangeLight];
    
    //关灯
    [self OffLight];
}


/**
 关灯
 */
- (void)OffLight {
    
    if (self.lightButton.selected) {
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [self.previewView.session beginConfiguration];
        [device lockForConfiguration:nil];
        if([device isTorchModeSupported:AVCaptureTorchModeOff]) {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
        [self.previewView.session commitConfiguration];
    }
    
    self.lightButton.selected = NO;
}

#pragma mark ------------------------ 设置添加扫描框  --------------------------

//  线框白线框区域
- (void)setupShapeLayer{
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    if (self.iSTaxiCard || self.isLineCard) {//  出租车
        
        [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:self.taxiScanView.frame cornerRadius:scanViewCornerRadius *[self.class speScale]] bezierPathByReversingPath]];
        
    }else  if (self.isCarPlate) {
        
        [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:self.plateScanView.frame cornerRadius:0] bezierPathByReversingPath]];
    }
    
    [self shapeLayerChangeLight];
    
    self.shapeLayer.path = path.CGPath;
}


- (void)shapeLayerChangeLight{
    
    self.shapeLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.4].CGColor;
}

- (void)shapeLayerChangeDark{
    //    self.shapeLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    self.shapeLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.8].CGColor;
}

+(CGFloat)speScale{
    
    return (CGFloat) (([UIScreen mainScreen].bounds.size.width == 414) ? 1.1: ([UIScreen mainScreen].bounds.size.width == 320) ? 0.85 : 1);
}



#pragma mark - ------    private --------
#pragma mark ------------------------ 系统处理方法 --------------------------


+(AipGeneralVC *)ViewControllerWithHandler:(handler)handler{
    
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"AipOcrSdk" bundle:[NSBundle bundleForClass:[self class]]];
    
    AipGeneralVC *GeneralVC  = [mainSB instantiateViewControllerWithIdentifier:@"AipGeneralVC"];
    
    GeneralVC .handler = handler;
    
    //    AipNavigationController *navController = [[AipNavigationController alloc] initWithRootViewController:vc];
    return GeneralVC ;
}

//UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSAssert(image, @" ");
    if (image) {
        
        [self setupCutImageView:image fromPhotoLib:YES];
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

//UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    if (error) {
        NSLog(@"图片保存失败");
    }else{
        NSLog(@"图片保存成功");
    }
}

/**
 /利用陀螺仪判断设备方向
 */
- (void)setupCmmotionManager{
    
    self.cmmotionManager = [[CMMotionManager alloc]init];
    
    __weak typeof(self) wself = self;
    
    if([self.cmmotionManager isDeviceMotionAvailable]) {
        [self.cmmotionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            
            if (accelerometerData.acceleration.x >= 0.75) {//home button left
                wself.curDeviceOrientation = UIDeviceOrientationLandscapeRight;
            }
            else if (accelerometerData.acceleration.x <= -0.75) {//home button right
                wself.curDeviceOrientation = UIDeviceOrientationLandscapeLeft;
            }
            else if (accelerometerData.acceleration.y <= -0.75) {
                wself.curDeviceOrientation = UIDeviceOrientationPortrait;
            }
            else if (accelerometerData.acceleration.y >= 0.75) {
                wself.curDeviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            }
            else {
                // Consider same as last time
                return;
            }
            
            [wself orientationChanged];
            
        }];
    }
}

//监测设备方向
- (void)orientationChanged{
    
    CGAffineTransform transform;
    
    if (self.curDeviceOrientation == UIDeviceOrientationPortrait) {
        
        transform = CGAffineTransformMakeRotation(0);
        
        self.msgLabel.hidden = NO;
        
        self.imageDeviceOrientation = UIDeviceOrientationPortrait;
    }else if (self.curDeviceOrientation == UIDeviceOrientationLandscapeLeft){
        
        transform = CGAffineTransformMakeRotation(M_PI_2);
        
        self.msgLabel.hidden = YES;
        
        self.imageDeviceOrientation = UIDeviceOrientationLandscapeLeft;
    }else if (self.curDeviceOrientation == UIDeviceOrientationLandscapeRight){
        
        transform = CGAffineTransformMakeRotation(-M_PI_2);
        
        self.msgLabel.hidden = YES;
        
        self.imageDeviceOrientation = UIDeviceOrientationLandscapeRight;
    }else {
        transform = CGAffineTransformMakeRotation(0);
        
        self.msgLabel.hidden = NO;
        
        self.imageDeviceOrientation = UIDeviceOrientationPortrait;
        
    }
    
    //重置shapeLayer
    [self setupShapeLayer];
    
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        self.albumButton.transform = transform;
        self.closeButton.transform = transform;
        self.lightButton.transform = transform;
        self.closeButton.transform = transform;
        self.captureButton.transform = transform;
        self.checkCloseBtn.transform = transform;
        self.checkChooseBtn.transform = transform;
        self.transformButton.transform = transform;
        
        self.plateScanView.transform = transform;
        self.taxiScanView.transform = transform;
        
    } completion:^(BOOL finished) {
        
        
    }];
    
    
}

//获取裁剪图片的 CGRect
- (CGRect)TransformTheRect{
    
    CGFloat x;
    CGFloat y;
    CGFloat width;
    CGFloat height;
    CGFloat scanViewX = 0.0;
    CGFloat scanViewY = 0.0;
    CGFloat scanViewW = 0.0;
    CGFloat scanViewH = 0.0;
    CGFloat scale;
    CGFloat scale2;
    
    if (self.iSTaxiCard || self.isLineCard) {//  卡片【矩形】
        
        scale = cardScale * V_W(self.taxiScanView);
        scale2 = cardScale * V_H(self.taxiScanView);
        
        //此算法版本对于身份证完整性要求较为严格，所以传给算法识别的图片会略大于裁剪框的大小
        scanViewX = V_X(self.taxiScanView) - scale;
        scanViewY = V_Y(self.taxiScanView) - scale2;
        scanViewW = V_W(self.taxiScanView) + scale*2;
        scanViewH = V_H(self.taxiScanView) + scale2*2;
        
    }else if (self.isCarPlate){//  车牌【正方形】
        
        scale = cardScale * V_W(self.plateScanView);
        scale2 = cardScale * V_H(self.plateScanView);
        
        //此算法版本对于身份证完整性要求较为严格，所以传给算法识别的图片会略大于裁剪框的大小
        scanViewX = V_X(self.plateScanView) - scale;
        scanViewY = V_Y(self.plateScanView) - scale2;
        scanViewW = V_W(self.plateScanView) + scale*2;
        scanViewH = V_H(self.plateScanView) + scale2*2;
        
    }else{//  普通拍照裁剪[自定义]
        
        scanViewX = V_X(self.maskImageView.cropAreaView);
        scanViewY = V_Y(self.maskImageView.cropAreaView);
        scanViewW = V_W(self.maskImageView.cropAreaView);
        scanViewH = V_H(self.maskImageView.cropAreaView);
    }
    
    CGFloat bgImageViewX  = V_X(self.cutImageView.bgImageView);
    CGFloat bgImageViewY  = V_Y(self.cutImageView.bgImageView);
    CGFloat bgImageViewW  = V_W(self.cutImageView.bgImageView);
    CGFloat bgImageViewH  = V_H(self.cutImageView.bgImageView);
    
    if (self.imageOrientation == UIImageOrientationUp) {
        
        
        if (scanViewX< bgImageViewX) {
            
            x = 0;
            width = scanViewW - (bgImageViewX - scanViewX);
        }else{
            
            x = scanViewX-bgImageViewX;
            width = scanViewW;
        }
        
        if (scanViewY< bgImageViewY) {
            
            y = 0;
            height = scanViewH - (bgImageViewY - scanViewY);
        }else{
            
            y = scanViewY-bgImageViewY;
            height = scanViewH;
        }
        
        self.size = CGSizeMake(bgImageViewW, bgImageViewH);
    }else if (self.imageOrientation == UIImageOrientationRight){
        
        if (scanViewY<bgImageViewY) {
            
            x = 0;
            width = scanViewH - (bgImageViewY - scanViewY);
        }else{
            
            x = scanViewY - bgImageViewY;
            width = scanViewH;
        }
        
        CGFloat newCardViewX = scanViewX + scanViewW;
        CGFloat newBgImageViewX = bgImageViewX + bgImageViewW;
        
        if (newCardViewX>newBgImageViewX) {
            y = 0;
            height = scanViewW - (newCardViewX - newBgImageViewX);
        }else{
            
            y = newBgImageViewX - newCardViewX;
            height = scanViewW;
        }
        
        self.size = CGSizeMake(bgImageViewH, bgImageViewW);
        
    }else if (self.imageOrientation == UIImageOrientationLeft){
        
        if (scanViewX < bgImageViewX) {
            
            y = 0;
            height = scanViewW - (bgImageViewX - scanViewX);
        }else{
            
            y = scanViewX-bgImageViewX;
            height = scanViewW;
        }
        
        CGFloat newCardViewY = scanViewY + scanViewH;
        CGFloat newBgImageViewY = bgImageViewY + bgImageViewH;
        
        if (newCardViewY< newBgImageViewY) {
            
            x = newBgImageViewY - newCardViewY;
            width = scanViewH;
        }else{
            
            x = 0;
            width = scanViewH - (newCardViewY - newBgImageViewY);
        }
        
        self.size = CGSizeMake(bgImageViewH, bgImageViewW);
    }else{
        
        CGFloat newCardViewX = scanViewX + scanViewW;
        CGFloat newBgImageViewX = bgImageViewX + bgImageViewW;
        
        CGFloat newCardViewY = scanViewY + scanViewH;
        CGFloat newBgImageViewY = bgImageViewY + bgImageViewH;
        
        if (newCardViewX < newBgImageViewX) {
            
            x = newBgImageViewX - newCardViewX;
            width = scanViewW;
        }else{
            
            x = 0;
            width = scanViewW - (newCardViewX - newBgImageViewX);
        }
        
        if (newCardViewY < newBgImageViewY) {
            
            y = newBgImageViewY - newCardViewY;
            height = scanViewH;
            
        }else{
            
            y = 0;
            height = scanViewH - (newCardViewY - newBgImageViewY);
        }
        
        self.size = CGSizeMake(bgImageViewW, bgImageViewH);
    }
    
    return CGRectMake(x, y, width, height);
}


#pragma mark ----------------  生命周期   -------------------

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self setupShapeLayer];
    
    [self.cameraController startRunningCamera];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden{
    
    return YES;
}

- (void)dealloc{
    
    [self.cameraController stopRunningCamera];
    NSLog(@"♻️ Dealloc %@", NSStringFromClass([self class]));
}

#pragma mark - dataSource && delegate

//AipCutImageDelegate

- (void)AipCutImageBeginPaint{
    
}
- (void)AipCutImageScale{
    [self shapeLayerChangeLight];
}
- (void)AipCutImageMove{
    [self shapeLayerChangeLight];
}
- (void)AipCutImageEndPaint{
    [self shapeLayerChangeDark];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
