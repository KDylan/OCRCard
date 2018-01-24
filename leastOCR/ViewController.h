//
//  ViewController.h
//  leastOCR
//
//  Created by UEdge on 2018/1/17.
//  Copyright © 2018年 UEdge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;


/**开始时间*/
@property(nonatomic,strong)NSDate *startTime;
/**结束时间*/
@property(nonatomic,strong)NSDate *endTime;

//  持续时间
@property(nonatomic,strong)NSString *stayTime;

@end

