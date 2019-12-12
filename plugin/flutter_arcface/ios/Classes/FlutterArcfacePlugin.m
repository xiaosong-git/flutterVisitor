#import "FlutterArcfacePlugin.h"
#import "ArcFaceUtil.h"

@implementation FlutterArcfacePlugin {
    FlutterMethodChannel *_channel;
    
}
+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"flutter_arcface"
                  binaryMessenger:[registrar messenger]];
    FlutterArcfacePlugin *instance = [[FlutterArcfacePlugin alloc] initWithChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"flutter_arcface handleMethodCall call: %@", call.method);
    NSString *method = call.method;
    if([method isEqualToString:@"activeCode"]){
        BOOL res = [[ArcFaceUtil shareInstance] activeCode];
        result(res ? @"1" : @"0");
    }else if([method isEqualToString:@"singleImage"]){
        NSDictionary *dic = call.arguments;
        [[ArcFaceUtil shareInstance] singleImage:dic[@"path"] complation:^(BOOL res) {
            result(res ? @"1" : @"0");
        }];
    }else if([method isEqualToString:@"compareImage"]){
        NSDictionary *dic = call.arguments;
        [[ArcFaceUtil shareInstance] compareImage:dic[@"path1"] withImg:dic[@"path2"] complation:^(float res) {
            result([NSString stringWithFormat:@"%f",res]);
        }];
    }else {
        result(FlutterMethodNotImplemented);
    }
}
@end

