//
//  BaseAlert.m
//  Hypermarket
//
//  Created by 雎琳 on 2020/6/23.
//  Copyright © 2020 Tikbee. All rights reserved.
//

#import "BaseAlert.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
@interface BaseAlert()

@property (nonatomic) ShowAlertStyle style;
@property (nonatomic,weak) UIView *customView;
@property (nonatomic) UITapGestureRecognizer *tap;
@property (nonatomic) UIView *tapView;

@end

@implementation BaseAlert

- (instancetype)init{
    if (self = [super init]) {
        [self prepare];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self prepare];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self insertSubview:self.tapView atIndex:0];
}
- (void)prepare{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.frame = UIScreen.mainScreen.bounds;
    
    _time = 0.3;
    _isTapDismiss = true;

    _tapView = [[UIView alloc]init];
    _tapView.userInteractionEnabled = true;
    // tap失效问题  需- 1
    _tapView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-1);
    
    [self addSubview:_tapView];
    [self insertSubview:_tapView atIndex:0];
    _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(grTap:)];
    [_tapView addGestureRecognizer:_tap];
    self.alpha = 0;
}

- (void)show{
    [self showOn:nil];
}



- (void)preShow{}
- (void)showOn:(UIView *)superview{
    BOOL show = [AlertManager.shared show:self superview:superview];
    if (show) {
        UIView *view = superview?:[self defaultWindow];
        self.frame = UIScreen.mainScreen.bounds;
        [view addSubview:self];
        [self preShow];
        [self appearAnimation];
    }
    
}
- (void)appearAnimation{
    
    [UIView animateWithDuration:[self time] delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 1;
        [self willShow];
    } completion:^(BOOL finished) {
        [self didShow];
        [self insertSubview:self.tapView atIndex:0];
    }];
}
- (void)didShow{
    
}
- (void)willShow{
    
}



- (void)grTap:(UITapGestureRecognizer *)gr{
    if (self.isTapDismiss ) {
        [self dismiss];
    }
}

- (void)setIsTapDismiss:(BOOL)isTapDismiss{
    _isTapDismiss = isTapDismiss;
    if (_isTapDismiss) {
        self.tap.enabled = true;
    }else{
        _tap.enabled = false;
    }
}

- (void)dismiss{
    if ([self alertPriority]) {
        [AlertManager.shared showNextFrom:self];
    }
    
    if (self.customView) {
        [UIView animateWithDuration:[self time] animations:^{
            switch (self.style) {
                case ShowAlertSheet:
                {
                    
                    self.customView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.customView.frame.size.height);
                    self.alpha = 0;
                }
                    break;
                    
                case ShowAlertNormal:{
                    
                    self.alpha = 0.f;
                }
                    break;
                    
                default:
                    break;
            }
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [self.customView removeFromSuperview];
            
        }];
    }else{
        [UIView animateWithDuration:[self time] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = 0;
            [self willDismiss];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

- (void)willDismiss{}



- (void)showCustomView:(UIView *)view{
    [self showCustomView:view style:ShowAlertNormal];
}
- (void)showCustomView:(UIView *)view style:(NSInteger)style{
    
    UIWindow *window = [self defaultWindow];
    [self showCustomView:view style:style superview:window];
}
- (void)showCustomView:(UIView *)view style:(NSInteger)style superview:(UIView *)superview{
    
    _customView = view;
    _style = style;
    
    CGRect frame = CGRectMake(0, 0, 0, 0);
    if (self.style == ShowAlertSheet) {
        frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, view.frame.size.height);
    }else{
        frame = CGRectMake(SCREEN_WIDTH / 2 - view.frame.size.width / 2, SCREEN_HEIGHT / 2 - view.frame.size.height / 2 - 50, view.frame.size.width, view.frame.size.height);
    }
    
    [view layoutIfNeeded];
    view.frame  = frame;
    
    self.frame = superview.bounds;
    [self addSubview:view];
    [superview addSubview:self];
    
    switch (self.style) {
        case ShowAlertSheet:{
            
            //            [view setCornerWithTopLeft:20 TopRight:20 bottomLeft:0 bottomRight:0];
            [UIView animateWithDuration:[self time] animations:^{
                view.frame = CGRectMake(0, SCREEN_HEIGHT - view.frame.size.height, SCREEN_WIDTH, view.frame.size.height);
                self.alpha = 1;
            }];
            
        }
            break;
            
        case ShowAlertNormal:{
            
            view.layer.cornerRadius = 15;
            view.clipsToBounds = true;
            self.alpha = 0;
            [UIView animateWithDuration:[self time] animations:^{
                self.alpha = 1.f;
                
            }];
        }
            break;
        default:
            break;
    }
    
}
- (UIWindow*)defaultWindow{
    UIWindow *foundWindow = [[UIApplication sharedApplication] windows].lastObject;
    NSArray  *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow  *window in windows) {
        if (window.isKeyWindow) {
            foundWindow = window;
            break;
        }
    }
    return foundWindow;
}
- (NSNumber *)alertPriority{
    // 默认不使用优先级
    return nil;
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
@implementation AlertManager

static AlertManager *shared = nil;

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[AlertManager alloc]init];
    });
    return shared;
}
- (NSMutableArray<AlertPriorityObject *> *)priorityArray{
    if (!_priorityArray) {
        _priorityArray = @[].mutableCopy;
    }
    return _priorityArray;
}
- (void)showNextFrom:(UIView *)fromAlert{
    NSLog(@"%@",self.priorityArray);
    AlertPriorityObject *containObj = nil;
    for (AlertPriorityObject *obj in self.priorityArray) {
        if ([obj.alert isEqual:fromAlert]) {
            containObj = obj;
            break;
        }
    }
    if (containObj) {
        [self.priorityArray removeObject:containObj];
    }
    AlertPriorityObject * showObj = nil;
    for (AlertPriorityObject * obj in self.priorityArray) {
        if (obj.priority > showObj.priority) {
            showObj = obj;
        }
    }
    if (showObj) {
        [showObj.alert showOn:showObj.superView];
    }
    
}

- (BOOL)show:(UIView<AlertPriorityProtocol> *)alert superview:(UIView *)superview{
    NSNumber *priority = alert.alertPriority;
    if (!priority) {
        return true;
    }
    BOOL contain = false;
    for (AlertPriorityObject *obj in self.priorityArray) {
        if ([obj.alert isEqual:alert]) {
            contain = true;
            break;
        }
    }

    BOOL show = false;
    if (contain) {
        show = true;
    }else{
        AlertPriorityObject *obj = [[AlertPriorityObject alloc]init];
        obj.alert = alert;
        obj.priority = priority.intValue;
        obj.superView = superview;
        [self.priorityArray addObject:obj];
        show = self.priorityArray.count <= 1;
    }
    return show;
}
@end


@implementation AlertPriorityObject
- (void)dealloc{
    NSLog(@"释放%@",self);
}
@end
