//
//  BaseAlert.h
//  Hypermarket
//
//  Created by iosKF on 2020/6/23.
//  Copyright © 2020 Tikbee. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol AlertPriorityProtocol <NSObject>
@optional

- (void)priorityShow;

- (NSNumber *)alertPriority;
@end
typedef NS_ENUM(NSInteger,ShowAlertStyle){
    ShowAlertNormal = 0,
    ShowAlertSheet = 1
} ;
@class AlertPriorityObject;
@interface BaseAlert : UIView<AlertPriorityProtocol>

@property (nonatomic) ShowAlertStyle style;
// 点击关闭
@property (nonatomic) BOOL isTapDismiss;

- (void)show;
- (void)showOn:(UIView *)view;
- (void)didShow;
- (void)dismiss;
- (void)willShow;
- (void)willDismiss;
- (void)appearAnimation;
- (void)preShow;
- (NSTimeInterval)time;
- (void)grTap:(UITapGestureRecognizer *)gr;
- (void)showCustomView:(nonnull UIView *)view;
- (void)showCustomView:(nonnull UIView *)view style:(NSInteger)style;
- (void)showCustomView:(UIView *)view style:(NSInteger)style superview:(UIView *)superview;

@end
@interface AlertManager : NSObject

@property (nonatomic) NSMutableArray <AlertPriorityObject *>*priorityArray;
@property (nonatomic,readonly) NSDictionary *registerPriorityDic;


+ (instancetype)shared;

@end

@interface AlertPriorityObject : NSObject
@property (nonatomic,weak) UIView *superView;
@property (nonatomic) NSInteger priority;
@property (nonatomic,strong,nullable) BaseAlert *alert;

@end
NS_ASSUME_NONNULL_END
