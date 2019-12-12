//
//  FaceLiveVC.h
//  Runner
//

#import <UIKit/UIKit.h>

@interface ArcFaceUtil : NSObject

+ (instancetype)shareInstance;

-(BOOL)activeCode;

-(void)singleImage:(NSString*)imgPath complation:(void(^)(BOOL res))complation;

-(void)compareImage:(NSString*)imgPath1 withImg:(NSString*)imgPath2 complation:(void(^)(float res))complation;

@end

