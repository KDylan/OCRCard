//
//  OverView.m
//  TestCamera
//


#import "PlateIDOverView.h"
#import <CoreText/CoreText.h>

//#define width 100
//#define lineLength 20

@interface PlateIDOverView(){
    
    CGContextRef _context;
    
}
@end

@implementation PlateIDOverView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    //  描绘四个角
    [super drawRect:rect];
    
    [[UIColor blueColor] set];
    CGFloat line_w = 5.0f;
    //获得当前画布区域
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //设置线的宽度
    CGContextSetLineWidth(currentContext, line_w);
    //  X方向长度
    CGFloat X_line =  self.frame.size.width/12;
    //  Y方向长度
    CGFloat Y_line =  X_line;
    //  顶点X
    CGFloat W_X = self.frame.size.width;
    //  顶点Y
    CGFloat H_Y = self.frame.size.height;
    
    
    /*画四个角线段*/
    //起点--左上角[Y,0]->[0,0]->[0,X]
    CGContextMoveToPoint(currentContext,Y_line, 0);
    CGContextAddLineToPoint(currentContext,0,0);
    CGContextAddLineToPoint(currentContext, 0, X_line);
    // 右上角
    CGContextMoveToPoint(currentContext,W_X-Y_line, 0);
    CGContextAddLineToPoint(currentContext,W_X,0);//  右上角顶点
    CGContextAddLineToPoint(currentContext, W_X, X_line);
    //  右下角
    CGContextMoveToPoint(currentContext,W_X, H_Y-Y_line);
    CGContextAddLineToPoint(currentContext,W_X,H_Y);//  右下角顶点
    CGContextAddLineToPoint(currentContext, W_X-X_line, H_Y);
    
    //  左下角
    CGContextMoveToPoint(currentContext,0, H_Y-Y_line);
    CGContextAddLineToPoint(currentContext,0,H_Y);//  左下角顶点
    CGContextAddLineToPoint(currentContext,X_line, H_Y);
    
    
    CGContextStrokePath(currentContext);
    
    
}
// 绘制四个角
-(void)drawLineWithWidth:(CGFloat)W_idth{
    
    
    //    [[UIColor blueColor] set];
    //    //获得当前画布区域
    //    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //    //设置线的宽度
    //    CGContextSetLineWidth(currentContext, 2.0f);
    //    CGPoint center = self.center;
    //    /*画线*/
    //    //起点--左上角
    //    CGContextMoveToPoint(currentContext,center.x-W_idth, center.y-W_idth+lineLength);
    //    CGContextAddLineToPoint(currentContext, center.x-W_idth, center.y-W_idth);
    //    CGContextAddLineToPoint(currentContext, center.x-W_idth+lineLength, center.y-W_idth);
    //    //右上
    //    CGContextMoveToPoint(currentContext, center.x+W_idth-lineLength,center.y-W_idth);
    //    CGContextAddLineToPoint(currentContext, center.x+W_idth,center.y-W_idth);
    //    CGContextAddLineToPoint(currentContext, center.x+W_idth,center.y-W_idth+lineLength);
    //    //左下
    //    CGContextMoveToPoint(currentContext, center.x-W_idth,center.y+W_idth-lineLength);
    //    CGContextAddLineToPoint(currentContext, center.x-W_idth,center.y+W_idth);
    //    CGContextAddLineToPoint(currentContext, center.x-W_idth+lineLength,center.y+W_idth);
    //    //右下
    //    CGContextMoveToPoint(currentContext, center.x+W_idth-lineLength,center.y+W_idth);
    //    CGContextAddLineToPoint(currentContext, center.x+W_idth,center.y+W_idth);
    //    CGContextAddLineToPoint(currentContext, center.x+W_idth,center.y+W_idth-lineLength);
    //
    //
    //    CGContextStrokePath(currentContext);
    
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
