//
//  BaseAlert.h
//  Hypermarket
//
//  Created by iosKF on 2020/6/23.
//  Copyright © 2020 Tikbee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAlert.h"
NS_ASSUME_NONNULL_BEGIN

// 自定义弹窗实现优先级
/*
 1 遵循实现协议 <AlertPriorityProtocol>
 2 在展示方法里 判断是否展示调用实现 BOOL show = [AlertManager.shared show:self superview:superview];
 3 在关闭方法调用：[AlertManager.shared showNextFrom:self]; 展示下一个弹窗
 */

@interface YourView : UIView <AlertPriorityProtocol>

@property (nonatomic) UILabel *lb;
- (void)show;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
