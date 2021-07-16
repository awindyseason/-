//
//  BaseAlert.m
//  Hypermarket
//
//  Created by iosKF on 2020/6/23.
//  Copyright © 2020 Tikbee. All rights reserved.
//

#import "YourView.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
@interface YourView()

@property (nonatomic) UITapGestureRecognizer *tap;
@property (nonatomic) UIView *tapView;

@end

@implementation YourView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        self.frame = UIScreen.mainScreen.bounds;
        _tapView = [[UIView alloc]init];
        _tapView.userInteractionEnabled = true;
        // tap失效问题  需- 1
        _tapView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-1);
        //    _tapView.frame = self.bounds;
        [self addSubview:_tapView];
        [self insertSubview:_tapView atIndex:0];
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(grTap:)];
        [_tapView addGestureRecognizer:_tap];
        self.alpha = 0;
        
        _lb = [[UILabel alloc]init];
        _lb.textColor = UIColor.blueColor;
        _lb.frame = CGRectMake(30, 400, 300, 30);
        [self addSubview:_lb];
    }
    return self;
}




- (void)show{
    [self showOn:nil];
}
- (void)showOn:(UIView *)superview{
    BOOL show = [AlertManager.shared show:self superview:superview];

    if (show) {
        UIView *view = UIApplication.sharedApplication.windows.lastObject;
        self.frame = UIScreen.mainScreen.bounds;
        [view addSubview:self];
        [UIView animateWithDuration:[self time] delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
            [self insertSubview:self.tapView atIndex:0];
        }];
    }
}


- (void)dismiss{

    [AlertManager.shared showNextFrom:self];
    
    [UIView animateWithDuration:[self time] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}
- (NSTimeInterval)time{
    return 0.3;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self insertSubview:self.tapView atIndex:0];
}

- (void)grTap:(UITapGestureRecognizer *)gr{
    [self dismiss];
}

- (NSNumber *)alertPriority{
    return @(1000);
}

- (void)dealloc{
    NSLog(@"释放%@",self.class);
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
