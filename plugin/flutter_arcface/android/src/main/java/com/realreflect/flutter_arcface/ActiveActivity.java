package com.realreflect.flutter_arcface;
import android.app.Activity;

import com.arcsoft.face.FaceEngine;

public class ActiveActivity{

    public int active(Activity activity){
        String APP_ID="wHETygz6KVSUAZKcsSaowY5xk9b6pfSYzsEjpETXxFE";
        String SDK_KEY="HmaovUKqWbVMmLKo5nuqHarLJ11YPtC1QXa8Y5Qtx9jL";
        FaceEngine faceEngine=new FaceEngine();
        int activeCode=faceEngine.activeOnline(activity,APP_ID,SDK_KEY);
        return activeCode;
    }
}
