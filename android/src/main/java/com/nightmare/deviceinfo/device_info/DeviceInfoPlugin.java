package com.nightmare.deviceinfo.device_info;

import android.app.ActivityManager;

import androidx.annotation.NonNull;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

import static android.content.Context.ACTIVITY_SERVICE;


/**
 * DeviceInfoPlugin
 */
public class DeviceInfoPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private  FlutterPluginBinding flutterPluginBinding;
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        this.flutterPluginBinding=flutterPluginBinding;
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "device_info");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

        if (call.method.equals("getRamStat")) {
            final ActivityManager activityManager = (ActivityManager) flutterPluginBinding.getApplicationContext().getSystemService(ACTIVITY_SERVICE);
            ActivityManager.MemoryInfo info = new ActivityManager.MemoryInfo();
            assert activityManager != null;
            activityManager.getMemoryInfo(info);
            HashMap<String, Long> resultMap = new HashMap<>();
            resultMap.put("availMem", info.availMem);
            resultMap.put("totalMem", info.totalMem);
            result.success(resultMap);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
