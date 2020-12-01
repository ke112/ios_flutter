//
//  ViewController.m
//  ios_project
//
//  Created by 张志华 on 12/1/20.
//

#import "ViewController.h"
#import <Flutter/Flutter.h>

@interface ViewController ()<FlutterBinaryMessenger>
@property (nonatomic, strong) FlutterEngine * flutterEngine;
@property (nonatomic, strong) FlutterViewController * flutterVC;
@property (nonatomic, strong) FlutterBasicMessageChannel * msgChannel;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.flutterVC = [[FlutterViewController alloc] initWithEngine:self.flutterEngine nibName:nil bundle:nil];
    self.flutterVC.modalPresentationStyle = UIModalPresentationFullScreen;//模态展示风格（全屏显示）
    self.flutterVC.view.backgroundColor = [UIColor whiteColor];
    
    //    接收Flutter 的数据
    //   这里因为messenger 需要 FlutterBinaryMessenger 类型所以报警告
    self.msgChannel = [FlutterBasicMessageChannel messageChannelWithName:@"messageChannel" binaryMessenger:self.flutterVC];
    
    [self.msgChannel setMessageHandler:^(id  _Nullable message, FlutterReply  _Nonnull callback) {
        NSLog(@"ios收到Flutter的传值: %@",message);
    }];

}
- (IBAction)jumpToFlutter:(UIButton *)sender {
    NSLog(@"ios jump To Flutter");
    
    NSString * pageIndex = @"one";
    NSString * page = @"one_page";
    if (sender.tag == 1002) {
        pageIndex = @"two";
        page = @"two_page";
    }
    
//    使用Channel 通道传值
    FlutterMethodChannel * methodChannel = [FlutterMethodChannel methodChannelWithName:page binaryMessenger:self.flutterVC];
//    发送消息
    [methodChannel invokeMethod:pageIndex arguments:@{@"t":@"我是iOS传过来的参数:"}];
    
    [self presentViewController:self.flutterVC animated:YES completion:nil];
    //也可以推 self.navigationController pushController:xxx
    
//   监听 Flutter 回调回来的参数
    [methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        if ([call.method isEqualToString:@"exit"]) {
            [self.flutterVC dismissViewControllerAnimated:YES completion:nil];
        }
    }];

}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    static int a = 0;
    [self.msgChannel sendMessage:[NSString stringWithFormat:@"%d",a++]];
}


- (FlutterEngine *)flutterEngine
{
    if (!_flutterEngine) {
        FlutterEngine * flutterEngine = [[FlutterEngine alloc] initWithName:@"liujilou44444"];
        if (flutterEngine.run) {//Flutter 运行运行起来了
            _flutterEngine = flutterEngine;
        }
    }
    return _flutterEngine;
}


@end
