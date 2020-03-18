package com.realreflect.flutter_arcface;
import android.app.Activity;

import com.arcsoft.face.FaceEngine;

public class ActiveActivity{

    public int active(Activity activity){
        FaceEngine faceEngine=new FaceEngine();
        int activeCode=faceEngine.active(activity,"wHETygz6KVSUAZKcsSaowY5xk9b6pfSYzsEjpETXxFE","HmaovUKqWbVMmLKo5nuqHarLJ11YPtC1QXa8Y5Qtx9jL");
        return activeCode;
    }
}
