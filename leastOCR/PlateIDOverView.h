//
//  OverView.h
//  TestCamera
//


#import <UIKit/UIKit.h>

@interface PlateIDOverView : UIView

@property (assign, nonatomic) BOOL leftHidden;
@property (assign, nonatomic) BOOL rightHidden;
@property (assign, nonatomic) BOOL topHidden;
@property (assign, nonatomic) BOOL bottomHidden;

@property (assign ,nonatomic) NSInteger smallX;
@property (assign ,nonatomic) CGRect smallrect;

-(void)drawLineWithWidth:(CGFloat)W_idth;
@end
