package com.realreflect.flutter_arcface;
import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterArcfacePlugin */
public class FlutterArcfacePlugin implements MethodCallHandler,PluginRegistry.RequestPermissionsResultListener {

    private final Registrar registrar;
   private Activity activitys;
    private Result result;
    private MethodCall call;
    private MultiImageActivity multiImageActivity;
    private SingleActivity singleActivity;
    private final PermissionManager permissionManager;

   static final int REQUEST_EXTERNAL_ARCFACE_STORAGE_PERMISSION = 15880;

   private FlutterArcfacePlugin(Registrar registrat,final Activity activity){

       this.registrar=registrat;

       activitys=activity;

       permissionManager = new PermissionManager() {
           @Override
           public boolean isPermissionGranted(String permissionName) {
               return ActivityCompat.checkSelfPermission(activity, permissionName)
                       == PackageManager.PERMISSION_GRANTED;
           }

           @Override
           public void askForPermission(String[] permissions, int requestCode) {
               ActivityCompat.requestPermissions(activity, permissions, requestCode);
           }

       };
   }

    interface PermissionManager {
        boolean isPermissionGranted(String permissionName);

        void askForPermission(String[] permissions, int requestCode);
    }


    /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_arcface");
    FlutterArcfacePlugin flutterArcfacePlugin=new FlutterArcfacePlugin(registrar,registrar.activity());
    channel.setMethodCallHandler(flutterArcfacePlugin);
    registrar.addRequestPermissionsResultListener(flutterArcfacePlugin);
  }

    @Override
    public boolean onRequestPermissionsResult(
            int requestCode, String[] permissions, int[] grantResults) {
        boolean permissionGranted =
                grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED;
        switch (requestCode) {
            case REQUEST_EXTERNAL_ARCFACE_STORAGE_PERMISSION:
                if (permissionGranted) {
                    if (this.call != null){
                        if (this.call.method.equals("activeCode")) {
                            active();
                        } else if(this.call.method.equals("singleImage")){
                            String rStr=singleImage(this.call.argument("path"));
                            unInit();
                            result.success(rStr);
                        }else if(this.call.method.equals("compareImage")){
                            String similar=compareImage(this.call.argument("path1"),this.call.argument("path2"));
                            unInit();
                            result.success(similar);
                        }else{
                            result.notImplemented();
                        }
                    }
                    return true;
                }
                break;

            default:
                return false;
        }

        if (!permissionGranted) {
            return false;
        }

        return true;
    }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
      this.call=call;
      this.result=result;
    if (call.method.equals("activeCode")) {
        active();
    } else if(call.method.equals("singleImage")){
        String rStr=singleImage(call.argument("path"));
        unInit();
        result.success(rStr);
    }else if(call.method.equals("compareImage")){
        String similar=compareImage(call.argument("path1"),call.argument("path2"));
        unInit();
        result.success(similar);
    }else{
        result.notImplemented();
    }
  }
  private void active(){
      if (!checkPermission()){
          return;
      }
      ActiveActivity activeActivity=new ActiveActivity();
      singleActivity=new SingleActivity();
      multiImageActivity=new MultiImageActivity();
      int code=activeActivity.active(activitys);
      result.success("ActiveCode" + code);
  }
  private  boolean checkPermission(){
      if (!permissionManager.isPermissionGranted(Manifest.permission.READ_PHONE_STATE) ||
              !permissionManager.isPermissionGranted(Manifest.permission.INTERNET)||
              !permissionManager.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE)||
              !permissionManager.isPermissionGranted(Manifest.permission.WRITE_EXTERNAL_STORAGE)||
              !permissionManager.isPermissionGranted(Manifest.permission.CAMERA)){

          permissionManager.askForPermission(new String[]{
                          Manifest.permission.READ_EXTERNAL_STORAGE,
                          Manifest.permission.WRITE_EXTERNAL_STORAGE,
                          Manifest.permission.INTERNET,
                          Manifest.permission.CAMERA,
                          Manifest.permission.READ_PHONE_STATE},
                  REQUEST_EXTERNAL_ARCFACE_STORAGE_PERMISSION);
          return false;
      }
          return true;
  }
  private String singleImage(Object path){
      if(!checkPermission()){
          return "-15880";
      }
      String rStr;
      singleActivity.initEngine(activitys);
      rStr=singleActivity.processImage(String.valueOf(path));
      return rStr;
  }
  private String compareImage(Object path1,Object path2){
      if(!checkPermission()){
          return "-15880";
      }
      multiImageActivity.initEngine(activitys);
      String similar = multiImageActivity.CompareImage(activitys,String.valueOf(path1),String.valueOf(path2));
      return similar;
  }
  private void unInit(){
      if(singleActivity!=null){
          singleActivity.unInitEngine();
      }
      if(multiImageActivity!=null){
          multiImageActivity.unInitEngine();
      }
  }
}
