//
//  BaseAlert.m
//  Hypermarket
//
//  Created by iosKF on 2020/6/23.
//  Copyright © 2020 Tikbee. All rights reserved.
//

#import "BaseAlert.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
@interface BaseAlert()


@property (nonatomic,weak) UIView *customView;
@property (nonatomic) UITapGestureRecognizer *tap;
@property (nonatomic) UIView *tapView;
@property (nonatomic,weak) AlertPriorityObject *priorityObj;
@end

@implementation BaseAlert

- (instancetype)init{
    if (self = [super init]) {
        [self baseSetup];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self baseSetup];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self insertSubview:self.tapView atIndex:0];
}
- (void)baseSetup{
    _isTapDismiss = true;
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
}

- (void)show{
    if ([self alertPriority]) {
        [self showCheckPriority:nil];
    }else{
        [self showAlert:nil];
    }
    
}
- (void)showAlert:(UIView *)view{
    if (view) {
        self.frame = UIScreen.mainScreen.bounds;
        [view addSubview:self];
        [self appearAnimation];
    }else{
    self.frame = UIScreen.mainScreen.bounds;
    UIWindow *window = [self keyWindow];

    [window addSubview:self];

    [self preShow];
    [self appearAnimation];
    }
}

-(UIWindow*)keyWindow
{
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
- (void)preShow{
    
}
- (void)showOn:(UIView *)view{
    if ([self alertPriority]) {
        [self showCheckPriority:view];
    }else{
        [self showAlert:view];
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

- (void)priorityShow{
    [self showAlert:self.priorityObj.superView];
}


- (void)showCheckPriority:(UIView *)superview{
    NSNumber *priority = self.alertPriority;
    
    if (!priority) {
        [self showAlert:superview];
        return;
    }
    AlertPriorityObject *obj = [[AlertPriorityObject alloc]init];
    obj.alert = self;

    obj.priority = priority.intValue;
    obj.superView = superview;
    [AlertManager.shared.priorityArray addObject:obj];
    self.priorityObj = obj;
    AlertPriorityObject * showObj = AlertManager.shared.priorityArray.firstObject;
    if (![showObj isEqual:self.priorityObj]) {
        return;
    }
    NSMutableArray *removes = @[].mutableCopy;
    for (AlertPriorityObject * tmp in AlertManager.shared.priorityArray) {
        if (tmp.alert) {
            if (![tmp.alert isEqual:self] && tmp.priority > obj.priority) {// 找出優先級最高
                showObj = showObj.priority > tmp.priority?showObj:tmp;
            }
        }else{
            tmp.alert = nil;
            [removes addObject:tmp];
        }
    }
    
    if (removes.count > 0) {
        for (AlertPriorityObject * obj in removes) {
            obj.alert = nil;
            [AlertManager.shared.priorityArray removeObject:obj];
        }
    }

    [showObj.alert priorityShow];

    
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
- (void)showNextPriorityAlert{
    AlertPriorityObject * showObj = nil;
    
    for (AlertPriorityObject * obj in AlertManager.shared.priorityArray) {
        if (![obj.alert isEqual:self] && obj.priority > showObj.priority) {
                showObj = obj;
        }
    }
    if (showObj) {
        [showObj.alert priorityShow];
    }

}

- (void)dismiss{
    self.priorityObj.alert = nil;
    if ([self alertPriority]) {
        [AlertManager.shared.priorityArray removeObject:self.priorityObj];
        [self showNextPriorityAlert];
    }
    
    if (self.customView) {
        [UIView animateWithDuration:0.3 animations:^{
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
- (NSTimeInterval)time{
    return 0.3;
}
- (void)willDismiss{
}



- (void)showCustomView:(UIView *)view{
    [self showCustomView:view style:ShowAlertNormal];
}
- (void)showCustomView:(UIView *)view style:(NSInteger)style{

    UIWindow *window = [self keyWindow];
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
            [UIView animateWithDuration:0.3 animations:^{
                 view.frame = CGRectMake(0, SCREEN_HEIGHT - view.frame.size.height, SCREEN_WIDTH, view.frame.size.height);
                self.alpha = 1;
            }];
            
        }
            break;
            
        case ShowAlertNormal:{

            view.layer.cornerRadius = 15;
            view.clipsToBounds = true;
            self.alpha = 0;
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 1.f;
          
            }];
        }
            break;
        default:
            break;
    }

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

@end


@implementation AlertPriorityObject
- (void)dealloc{
    NSLog(@"释放%@",self);
}
@end
