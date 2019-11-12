package com.github.flutterumpush;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import com.umeng.message.UmengNotifyClickActivity;

import org.android.agoo.common.AgooConstants;

public class UmengOtherPushActivity extends UmengNotifyClickActivity {


    private static String TAG = "umeng_push_OtherActivity";

    private String metaValue(String metaKey) {
        PackageManager packageManager = this.getPackageManager();
        ApplicationInfo appInfo = null;
        try {
            appInfo = packageManager.getApplicationInfo(this.getPackageName(),
                    PackageManager.GET_META_DATA);
            String channel = appInfo.metaData.get(metaKey).toString();
            if (channel == null || channel.equals("")) {
                channel = "";
            }
            return channel;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return "";
    }

    @SuppressLint("HandlerLeak")
    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            String umengPushMsg = (String) msg.obj;
            //考虑到FlutterActivity尚未初始化，所以先暂存一下
            UmengApplication.savePushData(UmengOtherPushActivity.this, UmengApplication.UMENG_PUSH_MESSAGE, umengPushMsg);
            Log.i(TAG, "handler umengPushMsg：" + umengPushMsg);
            Context context = UmengOtherPushActivity.this.getApplicationContext();
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(UmengOtherPushActivity.this.metaValue("URL_SCHEME") + "://"));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            Log.i(TAG, "URL唤醒intent：" + intent.toString());
            context.startActivity(intent);
            finish();
        }
    };


    @Override
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        Log.i(TAG, "onCreate：");
        try {
            setContentView(this.getResources().getIdentifier("umeng_other_push", "layout", this.getPackageName()));
        } catch (Exception e) {
            Log.e(TAG, "", e);
        }
    }

    @Override
    public void onMessage(Intent intent) {
        super.onMessage(intent);
        Log.i(TAG, "onMessage " + intent.toString());
        String umengPushMsg = intent.getStringExtra(AgooConstants.MESSAGE_BODY);
        Log.i(TAG, "onMessage umengPushMsg：" + umengPushMsg);
        Message message = Message.obtain();
        message.obj = umengPushMsg;
        //异步处理
        handler.sendMessage(message);
    }

}