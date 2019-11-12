package com.github.flutterumpush;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.util.Log;
import android.widget.Toast;

import com.google.gson.Gson;
import com.umeng.commonsdk.UMConfigure;
import com.umeng.message.IUmengRegisterCallback;
import com.umeng.message.MsgConstant;
import com.umeng.message.PushAgent;
import com.umeng.message.UmengMessageHandler;
import com.umeng.message.UmengNotificationClickHandler;
import com.umeng.message.entity.UMessage;

import org.android.agoo.huawei.HuaWeiRegister;
import org.android.agoo.mezu.MeizuRegister;
import org.android.agoo.xiaomi.MiPushRegistar;

import io.flutter.plugin.common.MethodChannel;

public class UmengApplication extends io.flutter.app.FlutterApplication {
    private static final String TAG = "umeng_push_Application";
    public static final String UMENG_PUSH_DEVICE_TOKEN = "umeng_push_device_token";
    public static final String UMENG_PUSH_MESSAGE = "umeng_push_message";

    public static void savePushData(Context context, String key, String value) {
        SharedPreferences userSettings = context.getSharedPreferences("umeng_push_data", 0);
        SharedPreferences.Editor editor = userSettings.edit();
        editor.putString(key, value);
        editor.commit();
        Log.i(TAG, "uMessage：保存数据成功");
    }

    public static String getPushData(Context context, String key) {
        SharedPreferences userSettings = context.getSharedPreferences("umeng_push_data", 0);
        return userSettings.getString(key, null);
    }

    /**
     * flutter回调结果函数
     */
    public static final MethodChannel.Result FLUTTER_METHOD_CALLBACK = new MethodChannel.Result() {
        @Override
        public void success(Object o) {
            Log.i(TAG, "call flutter result: " + o.toString());
        }

        @Override
        public void error(String s, String s1, Object o) {
            Log.i(TAG, "call flutter result: object: " + o.toString() + " s: " + s + " s1: " + s1);
        }

        @Override
        public void notImplemented() {
            Log.i(TAG, "call flutter result: notImplemented");

        }
    };

    private String metaValue(String metaKey) {
        PackageManager packageManager = this.getPackageManager();
        ApplicationInfo appInfo = null;
        try {
            appInfo = packageManager.getApplicationInfo(this.getPackageName(), PackageManager.GET_META_DATA);
            String value = appInfo.metaData.get(metaKey).toString();
            Log.i(TAG, metaKey + ":" + value);
            if (value == null || value.equals("")) {
                value = "";
            }
            return value;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return "";
    }

    public static String formatMsg(UMessage uMessage) {
        return new Gson().toJson(uMessage, UMessage.class);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        UMConfigure.setLogEnabled(true);
        // 初始化组件化基础库, 统计SDK/推送SDK/分享SDK都必须调用此初始化接口

        String appSecret = this.metaValue("UMENG_MESSAGE_SECRET");
        // Log.d(TAG, "appSecret: " + appSecret);
        UMConfigure.init(this, UMConfigure.DEVICE_TYPE_PHONE, appSecret);
        PushAgent pushAgent = PushAgent.getInstance(this);
        pushAgent.setDisplayNotificationNumber(10);
        pushAgent.setNotificationPlaySound(MsgConstant.NOTIFICATION_PLAY_SDK_ENABLE);
        // sdk关闭通知声音
        // pushAgent.setNotificationPlaySound(MsgConstant.NOTIFICATION_PLAY_SDK_DISABLE);
        // 通知声音由服务端控制
        // pushAgent.setNotificationPlaySound(MsgConstant.NOTIFICATION_PLAY_SERVER);
        // pushAgent.setNotificationPlayLights(MsgConstant.NOTIFICATION_PLAY_SDK_DISABLE);
        // pushAgent.setNotificationPlayVibrate(MsgConstant.NOTIFICATION_PLAY_SDK_DISABLE);
        UmengMessageHandler messageHandler = new UmengMessageHandler() {
            @Override
            public void dealWithCustomMessage(final Context context, final UMessage uMessage) {
                Log.d(TAG, "uMessage: " + uMessage.toString());
                Toast.makeText(context, uMessage.custom, Toast.LENGTH_LONG).show();
            }
        };
        pushAgent.setMessageHandler(messageHandler);
        UmengNotificationClickHandler notificationClickHandler = new UmengNotificationClickHandler() {
            public void launchApp(Context context, UMessage uMessage) {
                String umengPushMsg = formatMsg(uMessage);
                Log.i(TAG, "umengPushMsg: " + umengPushMsg);
                FlutterUmpushPlugin.instance.channel.invokeMethod("onMessage", umengPushMsg, FLUTTER_METHOD_CALLBACK);
                super.launchApp(context, uMessage);
            }

            public void openUrl(Context context, UMessage uMessage) {
                String umengPushMsg = formatMsg(uMessage);
                Log.i(TAG, "umengPushMsg: " + umengPushMsg);
                FlutterUmpushPlugin.instance.channel.invokeMethod("onMessage", umengPushMsg, FLUTTER_METHOD_CALLBACK);
                super.openUrl(context, uMessage);
            }

            public void openActivity(Context context, UMessage uMessage) {
                String umengPushMsg = formatMsg(uMessage);
                Log.i(TAG, "umengPushMsg: " + umengPushMsg);
                FlutterUmpushPlugin.instance.channel.invokeMethod("onMessage", umengPushMsg, FLUTTER_METHOD_CALLBACK);
                super.openActivity(context, uMessage);
            }

            public void dealWithCustomAction(Context context, UMessage uMessage) {
                String umengPushMsg = formatMsg(uMessage);
                Log.i(TAG, "umengPushMsg: " + umengPushMsg);
                FlutterUmpushPlugin.instance.channel.invokeMethod("onMessage", umengPushMsg, FLUTTER_METHOD_CALLBACK);
                super.dealWithCustomAction(context, uMessage);
            }
        };
        pushAgent.setNotificationClickHandler(notificationClickHandler);
        pushAgent.register(new

                                   IUmengRegisterCallback() {
                                       @Override
                                       public void onSuccess(String deviceToken) {
                                           Log.i(TAG, "device token: " + deviceToken);
                                           if (FlutterUmpushPlugin.instance != null) {
                                               //Flutter插件已经初始化完成，可以直接调用
                                               FlutterUmpushPlugin.instance.channel.invokeMethod("onToken", deviceToken, FLUTTER_METHOD_CALLBACK);
                                           } else { //Flutter尚未初始化（主要原因是使用小米、华为、魅族的离线唤醒方式初始化的，首先执行的的UmengOtherPushActivity）
                                               //缓存
                                               UmengApplication.savePushData(getApplicationContext(), UMENG_PUSH_DEVICE_TOKEN, deviceToken);
                                           }
                                       }

                                       @Override
                                       public void onFailure(String s, String s1) {
                                           Log.i(TAG, "register failed: " + s + " " + s1);
                                       }
                                   });
        pushAgent.onAppStart();
        HuaWeiRegister.register(this);
        MeizuRegister.register(this, this.metaValue("MZ_APP_ID"), this.metaValue("MZ_APP_KEY"));
        MiPushRegistar.register(this, this.metaValue("XM_APP_ID"), this.metaValue("XM_APP_KEY"));
    }
}
