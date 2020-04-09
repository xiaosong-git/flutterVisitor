package com.realreflect.flutter_arcface;

import android.Manifest;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import com.arcsoft.face.AgeInfo;
import com.arcsoft.face.ErrorInfo;
import com.arcsoft.face.Face3DAngle;
import com.arcsoft.face.FaceEngine;
import com.arcsoft.face.FaceFeature;
import com.arcsoft.face.FaceInfo;
import com.arcsoft.face.FaceSimilar;
import com.arcsoft.face.GenderInfo;
import com.arcsoft.face.LivenessInfo;
import com.arcsoft.face.enums.DetectFaceOrientPriority;
import com.arcsoft.face.enums.DetectMode;
import com.arcsoft.imageutil.ArcSoftImageFormat;
import com.arcsoft.imageutil.ArcSoftImageUtil;
import com.arcsoft.imageutil.ArcSoftImageUtilError;

import java.util.ArrayList;
import java.util.List;

public class MultiImageActivity {
    private static final String TAG = "MultiImageActivity";

    /**
     * 选择图片时的类型
     */
    private static final int TYPE_MAIN = 0;
    private static final int TYPE_ITEM = 1;

    /**
     * 主图的第0张人脸的特征数据
     */
    private FaceFeature mainFeature;

    private List<ItemShowInfo> showInfoList;

    private FaceEngine faceEngine;

    private int faceEngineCode = -1;

    private Bitmap mainBitmap;

    private static String[] NEEDED_PERMISSIONS = new String[]{
            Manifest.permission.READ_PHONE_STATE
    };

    public void initEngine(Activity activity) {
        showInfoList = new ArrayList<>();
        faceEngine = new FaceEngine();
        faceEngineCode = faceEngine.init(activity, DetectMode.ASF_DETECT_MODE_IMAGE, DetectFaceOrientPriority.ASF_OP_0_ONLY,
                16, 6, FaceEngine.ASF_FACE_RECOGNITION | FaceEngine.ASF_AGE | FaceEngine.ASF_FACE_DETECT | FaceEngine.ASF_GENDER | FaceEngine.ASF_FACE3DANGLE);
        Log.i(TAG, "initEngine: init " + faceEngineCode);
    }

    public void unInitEngine() {
        if (faceEngine != null) {
            faceEngineCode = faceEngine.unInit();
            Log.i(TAG, "unInitEngine: " + faceEngineCode);
        }
    }
    public String CompareImage(Activity activity, final String path1, final String path2) {

        if (path1 == null || path2 == null) {
            return "0";
        }
        Bitmap bmp = BitmapFactory.decodeFile(path1);
        mainBitmap = bmp;
        if (mainBitmap == null) {
            return "0";
        }
        processImage(mainBitmap, TYPE_MAIN);

        Bitmap bitmap = BitmapFactory.decodeFile(path2);
        if (bitmap == null) {
            return "0";
        }
        if (mainFeature == null) {
            return "0";
        }
        processImage(bitmap, TYPE_ITEM);

        return String.valueOf(showInfoList.get(0).getSimilar());
    }

    public void processImage(Bitmap bitmap, int type) {
        if (bitmap == null) {
            return;
        }

        if (faceEngine == null) {
            return;
        }

        //NV21宽度必须为4的倍数,高度为2的倍数
        bitmap = ArcSoftImageUtil.getAlignedBitmap(bitmap, true);

        if (bitmap == null) {
            return;
        }
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        //bitmap转NV21
        byte[] bgr24 = ArcSoftImageUtil.createImageData(bitmap.getWidth(), bitmap.getHeight(), ArcSoftImageFormat.BGR24);
//        final byte[] nv21 = ImageUtil.bitmapToNv21(bitmap, width, height);
        int transformCode = ArcSoftImageUtil.bitmapToImageData(bitmap, bgr24, ArcSoftImageFormat.BGR24);
        if (transformCode != ArcSoftImageUtilError.CODE_SUCCESS) {
            return ;
        }
        if (bgr24 != null) {

            List<FaceInfo> faceInfoList = new ArrayList<>();
            //人脸检测
            int detectCode = faceEngine.detectFaces(bgr24, width, height, FaceEngine.CP_PAF_BGR24, faceInfoList);
            if (detectCode != 0 || faceInfoList.size() == 0) {
                return;
            }
            //绘制bitmap
            bitmap = bitmap.copy(Bitmap.Config.RGB_565, true);
            int faceProcessCode = faceEngine.process(bgr24, width, height, FaceEngine.CP_PAF_BGR24, faceInfoList, FaceEngine.ASF_AGE | FaceEngine.ASF_GENDER | FaceEngine.ASF_FACE3DANGLE);
            Log.i(TAG, "processImage: " + faceProcessCode);
            if (faceProcessCode != ErrorInfo.MOK) {
                return;
            }

            //年龄信息结果
            List<AgeInfo> ageInfoList = new ArrayList<>();
            //性别信息结果
            List<GenderInfo> genderInfoList = new ArrayList<>();
            //三维角度结果
            List<Face3DAngle> face3DAngleList = new ArrayList<>();
            //活体检测结果
            List<LivenessInfo> livenessInfoList = new ArrayList<>();
            //获取年龄、性别、三维角度
            int ageCode = faceEngine.getAge(ageInfoList);
            int genderCode = faceEngine.getGender(genderInfoList);
            int face3DAngleCode = faceEngine.getFace3DAngle(face3DAngleList);
            if ((ageCode | genderCode | face3DAngleCode) != ErrorInfo.MOK) {
                return;
            }
            //人脸比对数据显示
            if (faceInfoList.size() > 0) {
                if (type == TYPE_MAIN) {
                    Log.i(TAG, "type_main: " + faceInfoList.size());
                    showInfoList.clear();
                    mainFeature = new FaceFeature();
                    int res = faceEngine.extractFaceFeature(bgr24, width, height, FaceEngine.CP_PAF_BGR24, faceInfoList.get(0), mainFeature);
                    if (res != ErrorInfo.MOK) {
                        mainFeature = null;
                    }
                    StringBuilder stringBuilder = new StringBuilder();
                    if (faceInfoList.size() > 0) {
                        stringBuilder.append("face info:\n\n");
                    }
                    for (int i = 0; i < faceInfoList.size(); i++) {
                        stringBuilder.append("face[")
                                .append(i)
                                .append("]:\n")
                                .append(faceInfoList.get(i))
                                .append("\nage:")
                                .append(ageInfoList.get(i).getAge())
                                .append("\ngender:")
                                .append(genderInfoList.get(i).getGender() == GenderInfo.MALE ? "MALE"
                                        : (genderInfoList.get(i).getGender() == GenderInfo.FEMALE ? "FEMALE" : "UNKNOWN"))
                                .append("\nface3DAngle:")
                                .append(face3DAngleList.get(i))
                                .append("\n\n");
                    }

                } else if (type == TYPE_ITEM) {
                    Log.i(TAG, "type_item: " + faceInfoList.size());
                    FaceFeature faceFeature = new FaceFeature();
                    int res = faceEngine.extractFaceFeature(bgr24, width, height, FaceEngine.CP_PAF_BGR24, faceInfoList.get(0), faceFeature);
                    if (res == 0) {
                        FaceSimilar faceSimilar = new FaceSimilar();
                        int compareResult = faceEngine.compareFaceFeature(mainFeature, faceFeature, faceSimilar);
                        if (compareResult == ErrorInfo.MOK) {
                            ItemShowInfo showInfo = new ItemShowInfo(bitmap, ageInfoList.get(0).getAge(), genderInfoList.get(0).getGender(), faceSimilar.getScore());
                            showInfoList.add(showInfo);
                        } else {

                        }
                    }

                }
            } else {
                if (type == TYPE_MAIN) {
                    mainBitmap = null;
                }
            }

        }else {

        }
    }
}
