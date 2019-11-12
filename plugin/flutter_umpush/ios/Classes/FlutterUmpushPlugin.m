#import "FlutterUmpushPlugin.h"
#import <UserNotifications/UserNotifications.h>
#import <UMCommon/UMCommon.h>
#import <UMPush/UMessage.h>
#import <UMAnalytics/MobClick.h>
#import <UMCommonLog/UMCommonLogHeaders.h>

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

@interface FlutterUmpushPlugin () <UNUserNotificationCenterDelegate>
@end

#endif

@implementation FlutterUmpushPlugin {
    FlutterMethodChannel *_channel;
    NSDictionary *_launchNotification;
    BOOL _resumingFromBackground;
}
+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    NSLog(@"umeng_push_plugin registerWithRegistrar registrar: %@", registrar);
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"flutter_umpush"
                  binaryMessenger:[registrar messenger]];
    FlutterUmpushPlugin *instance = [[FlutterUmpushPlugin alloc] initWithChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
    [registrar addApplicationDelegate:instance];
    NSLog(@"umeng_push_plugin register ok");
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
        _resumingFromBackground = NO;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"umeng_push_plugin handleMethodCall call: %@", call);
    NSString *method = call.method;
    if ([@"configure" isEqualToString:method]) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        if (_launchNotification != nil) {
            [_channel invokeMethod:@"onLaunch" arguments:_launchNotification];
        }
        result(nil);
    }else if([@"test" isEqualToString:method]) {
        result(@"hello");
    }else {
        result(FlutterMethodNotImplemented);
    }
}

- (NSString *)convertToJsonData:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:nil error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;

}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"umeng_push_plugin didReceiveRemoteNotification userInfo: %@", userInfo);
    NSLog(@"umeng_push_plugin call onMessage: %@", _channel);
    [_channel invokeMethod:@"onMessage" arguments:[self convertToJsonData:userInfo]];
}

- (BOOL)          application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"umeng_push_plugin application didFinishLaunchingWithOptions %@", _launchNotification);
    // Override point for customization after application launch.
    [UMCommonLogManager setUpUMCommonLogManager];
    [UMConfigure setLogEnabled:YES];

    [UMConfigure initWithAppkey:@"5cef4a6c0cafb28c35000d98" channel:@"flutter"];
    [MobClick event:@"flutter_ok"];
    NSLog(@"umeng_push_plugin application init umeng ok");
    UMessageRegisterEntity *entity = [[UMessageRegisterEntity alloc] init];
    //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
    entity.types = UMessageAuthorizationOptionBadge | UMessageAuthorizationOptionAlert;
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
#endif
    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity completionHandler:^(BOOL granted, NSError *_Nullable error) {
        if (granted) {
        } else {
        }
    }];
    _launchNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    _resumingFromBackground = YES;
    NSLog(@"umeng_push_plugin applicationDidEnterBackground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    _resumingFromBackground = NO;
    NSLog(@"umeng_push_plugin applicationDidBecomeActive");
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
}

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

//iOS10新增：处理前台收到通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"umeng_push_plugin userNotificationCenter willPresentNotification");
    NSDictionary *userInfo = notification.request.content.userInfo;
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [UMessage setAutoAlert:NO];
        //应用处于前台时的远程推送接受
        //必须加这句代码
        //[UMessage didReceiveRemoteNotification:userInfo];
        [self didReceiveRemoteNotification:userInfo];
    } else {
        //应用处于前台时的本地推送接受
    }
    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionAlert);
}

//iOS10新增：处理后台点击通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSLog(@"umeng_push_plugin userNotificationCenter didReceiveNotificationResponse");
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        //[UMessage didReceiveRemoteNotification:userInfo];
        [self didReceiveRemoteNotification:userInfo];
    } else {
        //应用处于后台时的本地推送接受
    }
}

#endif

- (NSString *)stringDevicetoken:(NSData *)deviceToken {
    NSString *token = [deviceToken description];
    NSString *pushToken = [[[token stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"umeng_push_plugin token: %@", pushToken);
    return pushToken;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"umeng_push_plugin application didReceiveRemoteNotification userInfo: %@", userInfo);
    [self didReceiveRemoteNotification:userInfo];
//    [UMessage setAutoAlert:NO];
//    [UMessage didReceiveRemoteNotification:userInfo];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"userInfoNotification" object:self userInfo:@{@"userinfo": [NSString stringWithFormat:@"%@", userInfo]}];

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"umeng_push_plugin application didRegisterForRemoteNotificationsWithDeviceToken%@", deviceToken);
    [_channel invokeMethod:@"onToken" arguments:[self stringDevicetoken:deviceToken]];
}
@end

