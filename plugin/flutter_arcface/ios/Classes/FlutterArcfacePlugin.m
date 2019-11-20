#import "FlutterArcfacePlugin.h"
#import <flutter_arcface/flutter_arcface-Swift.h>

@implementation FlutterArcfacePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterArcfacePlugin registerWithRegistrar:registrar];
}
@end
