//
//  ViewController.m
//  BNBaseAlert
//
//  Created by Tikbee on 2021/7/16.
//

#import "ViewController.h"
#import "TestAlert.h"
#import "Test2Alert.h"
#import "Test3Alert.h"
#import "YourView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 封装基本的弹出窗、可实现弹窗优先级
}
- (IBAction)clickPriority:(id)sender {
    // 弹窗顺序规则 1.如果不存在弹窗，则直接展示第一个弹窗，后续弹窗缓存， 2关闭第一个弹窗后 ，后面缓存的弹窗按优先级展示
    
    for (int i = 0; i < 2; i++) {
        TestAlert *alert  = [[TestAlert alloc]init];
        alert.lb.text = [NSString stringWithFormat:@"Test1  第%d个弹窗",i];
        [alert show];
    }
    for (int i = 0; i < 2; i++) {
        Test2Alert *alert  = [[Test2Alert alloc]init];
        alert.lb.text = [NSString stringWithFormat:@"Test2 : 第%d个弹窗",i];
        [alert show];
    }
    for (int i = 2; i < 4; i++) {
        TestAlert *alert  = [[TestAlert alloc]init];
        alert.lb.text = [NSString stringWithFormat:@"Test1  第%d个弹窗",i];
        [alert show];
    }
    for (int i = 2; i < 4; i++) {
        Test2Alert *alert  = [[Test2Alert alloc]init];
        alert.lb.text = [NSString stringWithFormat:@"Test2 : 第%d个弹窗",i];
        [alert show];
    }
    
    YourView *alert2  = [[YourView alloc]init];
    alert2.lb.text = @"不继承于BaseAlert的弹窗优先级展示";
    [alert2 show];
    
    Test3Alert *alert  = [[Test3Alert alloc]init];
    alert.lb.text = @"Test3 : 不使用优先级，与其他弹出窗共存";
    [alert show];
}

- (IBAction)clickDemo:(id)sender {
    // 无需继承BaseAlert  展示自定义view
    
    UIView *view = [[UIView alloc]init];
    view.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 300);
    view.backgroundColor = UIColor.blueColor;
    
    BaseAlert *alert = [[BaseAlert alloc]init] ;
    [alert showCustomView:view style:ShowAlertSheet];
    
}

@end
