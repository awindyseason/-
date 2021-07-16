//
//  BaseAlert.h
//  Hypermarket
//
//  Created by 雎琳 on 2020/6/23.
//  Copyright © 2020 Tikbee. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol AlertPriorityProtocol <NSObject>
// 弹出窗展示方法实现
- (void)showOn:(UIView *__nullable)superview;
// 全局优先级 
- (NSNumber *)alertPriority;

@end

typedef NS_ENUM(NSInteger,ShowAlertStyle){
    ShowAlertNormal = 0,
    ShowAlertSheet = 1
} ;
@class AlertPriorityObject;

@interface BaseAlert : UIView<AlertPriorityProtocol>

// 是否点击关闭
@property (nonatomic) BOOL isTapDismiss;
// 打开 关闭时间
@property (nonatomic) NSTimeInterval time;
//
- (void)preShow;
- (void)show;
- (void)willShow;
- (void)didShow;
- (void)dismiss;
- (void)willDismiss;


// 展示 自定义 view
- (void)showCustomView:(nonnull UIView *)view;
- (void)showCustomView:(nonnull UIView *)view style:(NSInteger)style;
- (void)showCustomView:(UIView *)view style:(NSInteger)style superview:(UIView *)superview;

@end

@interface AlertManager : NSObject

@property (nonatomic) NSMutableArray <AlertPriorityObject *>*priorityArray;
//@property (nonatomic,readonly) NSDictionary *registerPriorityDic;


+ (instancetype)shared;
// 展示下一个弹窗框 alert:
- (void)showNextFrom:(UIView *)fromAlert;
// return : 是否展示 
- (BOOL)show:(UIView <AlertPriorityProtocol> *)alert superview:(UIView *)superview;
@end

@interface AlertPriorityObject : NSObject
@property (nonatomic,weak) UIView *superView;
@property (nonatomic) NSInteger priority;
// 持有alert 避免被释放
@property (nonatomic,strong,nullable) NSObject <AlertPriorityProtocol> *alert;


@end
NS_ASSUME_NONNULL_END
