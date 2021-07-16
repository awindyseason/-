//
//  Test2Alert.m
//  BNBaseAlert
//
//  Created by Tikbee on 2021/7/16.
//

#import "Test2Alert.h"

@implementation Test2Alert

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lb = [[UILabel alloc]init];
        _lb.textColor = UIColor.redColor;
        _lb.frame = CGRectMake(30, 200, 200, 30);
        [self addSubview:_lb];
        
    }
    return self;
}

- (NSNumber *)alertPriority{
    return @(200);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
