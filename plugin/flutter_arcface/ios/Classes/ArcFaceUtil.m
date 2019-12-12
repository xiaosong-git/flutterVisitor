//
//  FaceLiveVC.m
//  Runner
//

#import <ArcSoftFaceEngine/ArcSoftFaceEngine.h>
#import <ArcSoftFaceEngine/ArcSoftFaceEngineDefine.h>
#import <ArcSoftFaceEngine/amcomdef.h>
#import <ArcSoftFaceEngine/merror.h>
#import <Photos/Photos.h>
#import "ArcFaceUtil.h"

#import "util/Utility.h"
#import "util/ColorFormatUtil.h"

#define FacePass                         (0.8)

static ArcSoftFaceEngine *engine;
static BOOL faceInit;

@interface ArcFaceUtil(){
}

@property (nonatomic, strong)UIImage* compareImage1;
@property (nonatomic, strong)UIImage* compareImage2;
@end

@implementation ArcFaceUtil

+ (instancetype)shareInstance{
    static ArcFaceUtil *obj = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

-(instancetype)init{
    if (self=[super init]) {
        NSLog(@"init");
        faceInit = NO;
    }
    return self;
}

-(BOOL)activeCode{
    NSLog(@"activeCode");
    BOOL faceRes = NO;
    NSString *appid = @"wHETygz6KVSUAZKcsSaowY5xk9b6pfSYzsEjpETXxFE";
    NSString *sdkkey = @"HmaovUKqWbVMmLKo5nuqHarLKd8AeG3wm2ehmCVeBeTW";
    engine = [[ArcSoftFaceEngine alloc] init];
    MRESULT mr = [engine activeWithAppId:appid SDKKey:sdkkey];
    NSLog(@"activeCode active1：%ld", mr);
    if (mr == ASF_MOK || mr == MERR_ASF_ALREADY_ACTIVATED) {//SDK激活成功,SDK已激活
        mr = [engine initFaceEngineWithDetectMode:ASF_DETECT_MODE_IMAGE
                                   orientPriority:ASF_OP_0_HIGHER_EXT
                                            scale:16
                                       maxFaceNum:10
                                     combinedMask:ASF_FACE_DETECT | ASF_FACERECOGNITION | ASF_AGE | ASF_GENDER | ASF_FACE3DANGLE];
        NSLog(@"activeCode结果为：%ld", mr);
        faceRes = YES;
        faceInit = YES;
    } else {//SDK激活失败
        faceRes = NO;
    }
    return faceRes;
}

-(void)singleImage:(NSString*)imgPath complation:(void(^)(BOOL res))complation{
    if (!faceInit) {
        if(![[ArcFaceUtil shareInstance] activeCode]){
            complation(NO);
        }
    }
    NSLog(@"singleImage");
    [[ArcFaceUtil shareInstance] getCurrentImg:imgPath complation:^(UIImage *img) {
        BOOL res = [[ArcFaceUtil shareInstance] faceFind:img];
        NSLog(@"singleImage结果为：%d", res);
        complation(res);
    }];
}

-(void)compareImage:(NSString*)imgPath1 withImg:(NSString*)imgPath2 complation:(void(^)(float res))complation{
    NSLog(@"compareImage");
    if (!faceInit) {
        if(![[ArcFaceUtil shareInstance] activeCode]){
            complation(NO);
        }
    }
    __weak typeof(self) weakSelf= self;
    [[ArcFaceUtil shareInstance] getCurrentImg:imgPath1 complation:^(UIImage *img) {
        weakSelf.compareImage1 = img;
        [weakSelf compareImages:complation];
    }];
    [[ArcFaceUtil shareInstance] getCurrentImg:imgPath2 complation:^(UIImage *img) {
        weakSelf.compareImage2 = img;
        [weakSelf compareImages:complation];
    }];
}

-(void)compareImages:(void(^)(float res))complation{
    if (self.compareImage1 != nil && self.compareImage2 != nil) {
        float mr = [[ArcFaceUtil shareInstance] faceCompare:self.compareImage1 withPath:self.compareImage2];
        NSLog(@"compareImage结果为：%f", mr);
        complation(mr);
    }
}

/**
 比较两张头像图片

 @param selectImage1 头像图片1
 @param selectImage2 头像图片2
 @return 对比结果
 */
-(MFloat)faceCompare:(UIImage*)selectImage1 withPath:(UIImage*)selectImage2{
    NSLog(@"faceCompare");
    MRESULT mr = 0;
    
    LPASF_FaceFeature copyFeature1 = (LPASF_FaceFeature)malloc(sizeof(ASF_FaceFeature));
    ASF_FaceFeature feature1 = [self faceFeature:selectImage1];
    
    copyFeature1->featureSize = feature1.featureSize;
    copyFeature1->feature = (MByte*)malloc(feature1.featureSize);
    memcpy(copyFeature1->feature, feature1.feature, copyFeature1->featureSize);
    
    ASF_FaceFeature feature2 = [self faceFeature:selectImage2];
    
    if (copyFeature1->featureSize > 0 && feature2.featureSize > 0) {
        //FM
        MFloat confidence = 0.0;
        mr = [engine compareFaceWithFeature:copyFeature1
                                   feature2:&feature2
                            confidenceLevel:&confidence];
        if (mr == ASF_MOK) {
            NSLog(@"FM比对结果为：%f", confidence);
            return confidence;
        }
    }
    return 0;
}

/**
 根据路径获取图片

 @param picPath 图片路径
 */
-(void)getCurrentImg:(NSString*)picPath complation:(void(^)(UIImage *img))complation{
    NSLog(@"getCurrentImg");
    if(![picPath containsString:@"/Application/"]){//from photos :/var/mobile/Media/DCIM/100APPLE/IMG_0114.JPG
    
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHAssetMediaType type = PHAssetMediaTypeImage;
        
        PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:type options:option];

        NSLog(@"dispatch_async1");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                PHAsset *asset = (PHAsset *)obj;
                NSString* fileName = [obj filename];
                NSLog(@"fileName:%@",fileName);
                if([picPath hasSuffix:fileName]){
                    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
                    option.networkAccessAllowed = NO;
                    PHImageManager *manager = [PHImageManager defaultManager];
                    [manager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize
                                      contentMode:PHImageContentModeDefault
                                          options:option
                                    resultHandler:^(UIImage *resultImage, NSDictionary *info){
                                        NSURL * url = [info objectForKey:@"PHImageFileURLKey"];
                                        NSLog(@"getCurrentImg:%@",url.path);
                                        complation(resultImage);
                     }];
                    *stop = YES;
                }
            }];
        });
        NSLog(@"dispatch_async1");
    
    }else{
        NSArray *array = [picPath componentsSeparatedByString:@"/"];
        NSString *path = [NSString stringWithFormat:@"%@/%@",
                          NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject,
                          array.lastObject];
        // 拿到沙盒路径图片
        UIImage* selectImage =[[UIImage alloc]initWithContentsOfFile:path];
        complation(selectImage);
    }
}

/**
 根据给定图片查找是否存在头像

 @param selectImage 给定图片
 @return 查找结果
 */
-(BOOL)faceFind:(UIImage*)selectImage{
    NSLog(@"faceFind");
    MRESULT mr = 0;
    unsigned char* pRGBA = [ColorFormatUtil bitmapFromImage:selectImage];
    MInt32 dataWidth = selectImage.size.width;
    MInt32 dataHeight = selectImage.size.height;
    MUInt32 format = ASVL_PAF_NV12;
    MInt32 pitch0 = dataWidth;
    MInt32 pitch1 = dataWidth;
    MUInt8* plane0 = (MUInt8*)malloc(dataHeight * dataWidth * 3/2);
    MUInt8* plane1 = plane0 + dataWidth * dataHeight;
    unsigned char* pBGR = (unsigned char*)malloc(dataHeight * LINE_BYTES(dataWidth, 24));
    RGBA8888ToBGR(pRGBA, dataWidth, dataHeight, dataWidth * 4, pBGR);
    BGRToNV12(pBGR, dataWidth, dataHeight, plane0, pitch0, plane1, pitch1);
    
    ASF_MultiFaceInfo* fdResult = (ASF_MultiFaceInfo*)malloc(sizeof(ASF_MultiFaceInfo));
    fdResult->faceRect = (MRECT*)malloc(sizeof(fdResult->faceRect));
    fdResult->faceOrient = (MInt32*)malloc(sizeof(fdResult->faceOrient));
    
    //FD
    mr = [engine detectFacesWithWidth:dataWidth
                                       height:dataHeight
                                         data:plane0
                                       format:format
                                      faceRes:fdResult];
    NSLog(@"faceFind结果为：%ld,num: %d", mr, fdResult->faceNum);
    SafeArrayFree(pBGR);
    SafeArrayFree(pRGBA);
    if(mr == ASF_MOK && fdResult->faceNum > 0){
        return YES;
    }
    return NO;
}

/**
 获取给定图片中头像的特征

 @param selectImage 给定的头像图片
 @return 头像特征
 */
-(ASF_FaceFeature)faceFeature:(UIImage*)selectImage{
    NSLog(@"faceFeature");
    ASF_FaceFeature feature = {0};
    MRESULT mr = 0;
    
    unsigned char* pRGBA = [ColorFormatUtil bitmapFromImage:selectImage];
    MInt32 dataWidth = selectImage.size.width;
    MInt32 dataHeight = selectImage.size.height;
    MUInt32 format = ASVL_PAF_NV12;
    MInt32 pitch0 = dataWidth;
    MInt32 pitch1 = dataWidth;
    MUInt8* plane0 = (MUInt8*)malloc(dataHeight * dataWidth * 3/2);
    MUInt8* plane1 = plane0 + dataWidth * dataHeight;
    unsigned char* pBGR = (unsigned char*)malloc(dataHeight * LINE_BYTES(dataWidth, 24));
    RGBA8888ToBGR(pRGBA, dataWidth, dataHeight, dataWidth * 4, pBGR);
    BGRToNV12(pBGR, dataWidth, dataHeight, plane0, pitch0, plane1, pitch1);
    
    ASF_MultiFaceInfo* fdResult = (ASF_MultiFaceInfo*)malloc(sizeof(ASF_MultiFaceInfo));
    fdResult->faceRect = (MRECT*)malloc(sizeof(fdResult->faceRect));
    fdResult->faceOrient = (MInt32*)malloc(sizeof(fdResult->faceOrient));
    
    //FD
    mr = [engine detectFacesWithWidth:dataWidth
                               height:dataHeight
                                 data:plane0
                               format:format
                              faceRes:fdResult];
    NSLog(@"faceFeature-----FD----结果为：%ld", mr);
    if (mr == ASF_MOK) {
        //NSTimeInterval begin = [[NSDate date] timeIntervalSince1970];
        //process
        mr = [engine processWithWidth:dataWidth
                               height:dataHeight
                                 data:plane0
                               format:format
                              faceRes:fdResult
                                 mask:ASF_AGE | ASF_GENDER | ASF_FACE3DANGLE];
        NSLog(@"faceFeature-----process----结果为：%ld", mr);
        //NSTimeInterval cost = [[NSDate date] timeIntervalSince1970] - begin;
        //NSLog(@"processTime=%d", (int)(cost * 1000));
        //NSLog(@"process:%ld", mr);
        if (mr == ASF_MOK) {
            
            //FR
            ASF_SingleFaceInfo frInputFace = {0};
            frInputFace.rcFace.left = fdResult->faceRect[0].left;
            frInputFace.rcFace.top = fdResult->faceRect[0].top;
            frInputFace.rcFace.right = fdResult->faceRect[0].right;
            frInputFace.rcFace.bottom = fdResult->faceRect[0].bottom;
            frInputFace.orient = fdResult->faceOrient[0];
            
            //NSTimeInterval begin = [[NSDate date] timeIntervalSince1970];
            mr = [engine extractFaceFeatureWithWidth:dataWidth
                                              height:dataHeight
                                                data:plane0
                                              format:format
                                            faceInfo:&frInputFace
                                             feature:&feature];
            NSLog(@"faceFeature-----FR----结果为：%ld", mr);
            //NSTimeInterval cost = [[NSDate date] timeIntervalSince1970] - begin;
//            if (mr == ASF_MOK) {
//                NSLog(@"FRTime:%dms, feature:%d", (int)(cost * 1000), feature.featureSize);
//            }
        }
    }
    SafeArrayFree(pBGR);
    SafeArrayFree(pRGBA);
    return feature;
}


@end
