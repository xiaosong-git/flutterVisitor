package com.github.flutterumpush;

import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class FlutterUmpushPlugin
        implements MethodCallHandler {
    private static String TAG = "umeng_push_Plugin";
    public static FlutterUmpushPlugin instance;
    public final MethodChannel channel;
    private static Registrar registrar;

    public static void registerWith(Registrar registrar) {
        instance = new FlutterUmpushPlugin(registrar);
    }

    private FlutterUmpushPlugin(Registrar registrar) {
        FlutterUmpushPlugin.registrar = registrar;
        MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_umpush");
        channel.setMethodCallHandler(this);
        this.channel = channel;
    }


    @Override
    public void onMethodCall(MethodCall call, Result result) {
        Log.i(TAG, "onMethodCall: " + call.toString());
        if ("configure".equals(call.method)) {
            //当通过友盟离线唤醒的时候，系统首先执行的是UmengOtherPushActivity，而MainActivity尚未启动
            // ，所以UmengApplication的onCreate函数执行友盟注册时，Flutter尚未准备完成，不能接收信息，
            // 为了防止丢失通知，先缓存到SharedPreferences，等flutter初始化完成后，
            // 调用configure函数时，才执行onToken或onMessage回调

            //查看缓存是否存在Token，存在在执行Flutter的回调函数onToken，通知flutter进行更新
            String token = UmengApplication.getPushData(registrar.activity(), UmengApplication.UMENG_PUSH_DEVICE_TOKEN);
            if (token != null && !token.equals("")) {
                channel.invokeMethod("onToken", token, new Result() {
                    @Override
                    public void success(Object o) {
                        UmengApplication.savePushData(registrar.activity(), UmengApplication.UMENG_PUSH_DEVICE_TOKEN, null);
                    }

                    @Override
                    public void error(String s, String s1, Object o) {

                    }

                    @Override
                    public void notImplemented() {

                    }
                });
            }
            //查看缓存是否存在Token，存在在回调
            String umsgPushMsg = UmengApplication.getPushData(registrar.activity(), UmengApplication.UMENG_PUSH_MESSAGE);
            if (umsgPushMsg != null && !umsgPushMsg.equals("")) {
                channel.invokeMethod("onMessage", umsgPushMsg, new Result() {
                    @Override
                    public void success(Object o) {
                        //删除数据
                        UmengApplication.savePushData(registrar.activity(), UmengApplication.UMENG_PUSH_MESSAGE, null);
                    }

                    @Override
                    public void error(String s, String s1, Object o) {

                    }

                    @Override
                    public void notImplemented() {

                    }
                });
            }
            result.success(null);
        } else if ("test".equals(call.method)) {
            channel.invokeMethod("onMessage", "hello");
            result.success(null);
        } else {
            result.notImplemented();
        }
    }


}
