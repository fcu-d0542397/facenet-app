package com.example.flutter_app;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Environment;
import android.renderscript.Allocation;
import android.renderscript.Element;
import android.renderscript.RenderScript;
import android.renderscript.ScriptIntrinsicYuvToRGB;
import android.renderscript.Type;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "flutter_app.example.com";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("convert")) {
          RenderScript rs = RenderScript.create(getBaseContext());

          HashMap imageData = call.arguments();

          int w = (int) imageData.get("width");
          int h = (int) imageData.get("height");
          ArrayList<Map> planes = (ArrayList) imageData.get("planes");

          byte[] data = packYUV420asNV21(w, h, planes);

          Bitmap bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
          ScriptIntrinsicYuvToRGB yuvToRgbIntrinsic = ScriptIntrinsicYuvToRGB.create(rs, Element.U8_4(rs));

          Type.Builder yuvType = new Type.Builder(rs, Element.U8(rs)).setX(data.length);
          Allocation in = Allocation.createTyped(rs, yuvType.create(), Allocation.USAGE_SCRIPT);
          in.copyFrom(data);

          Type.Builder rgbaType = new Type.Builder(rs, Element.RGBA_8888(rs)).setX(w).setY(h);
          Allocation out = Allocation.createTyped(rs, rgbaType.create(), Allocation.USAGE_SCRIPT);

          yuvToRgbIntrinsic.setInput(in);
          yuvToRgbIntrinsic.forEach(out);
          out.copyTo(bitmap);

          File extDir = Environment.getExternalStorageDirectory();
          String filename = "Pictures/facenet_app/out.png";
          File fullFilename = new File(extDir, filename);

          try (FileOutputStream outstream = new FileOutputStream(fullFilename)) {
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outstream);
            // PNG is a lossless format, the compression factor (100) is ignored
          } catch (IOException e) {
            e.printStackTrace();
          }
          int width = bitmap.getWidth();
          int height = bitmap.getHeight();
          int[] store = new int[width * height];
          bitmap.getPixels(store, 0, width, 0, 0, width, height);
          result.success(store);
        } else {
          result.notImplemented();
        }
      }
    });
  }

  public byte[] packYUV420asNV21(int width, int height, ArrayList<Map> planes) {
    byte[] yBytes = (byte[]) planes.get(0).get("bytes"), uBytes = (byte[]) planes.get(1).get("bytes"),
        vBytes = (byte[]) planes.get(2).get("bytes");
    final int color_pixel_stride = (int) planes.get(1).get("bytesPerRow");

    ByteArrayOutputStream outputbytes = new ByteArrayOutputStream();
    try {
      outputbytes.write(yBytes);
      outputbytes.write(vBytes);
      outputbytes.write(uBytes);
    } catch (IOException e) {
      e.printStackTrace();
    }

    byte[] data = outputbytes.toByteArray();
    final int y_size = yBytes.length;
    final int u_size = uBytes.length;
    final int data_offset = width * height;
    for (int i = 0; i < y_size; i++) {
      data[i] = (byte) (yBytes[i] & 255);
    }
    for (int i = 0; i < u_size / color_pixel_stride; i++) {
      data[data_offset + 2 * i] = vBytes[i * color_pixel_stride];
      data[data_offset + 2 * i + 1] = uBytes[i * color_pixel_stride];
    }
    return data;
  }

  public rtmpStream() {
    SrsCameraView cameraView = (SrsCameraView) findViewById(R.id.glsurfaceview_camera)
    mPublisher = new SrsPublisher(cameraView);
    //编码状态回调
    mPublisher.setEncodeHandler(new SrsEncodeHandler(this));
    mPublisher.setRecordHandler(new SrsRecordHandler(this));
    //rtmp推流状态回调
    mPublisher.setRtmpHandler(new RtmpHandler(this));
    //预览分辨率
    mPublisher.setPreviewResolution(1280, 720);
    //推流分辨率
    mPublisher.setOutputResolution(720, 1280);
    //传输率
    mPublisher.setVideoHDMode();
    //开启美颜（其他滤镜效果在MagicFilterType中查看）
    mPublisher.switchCameraFilter(MagicFilterType.BEAUTY);
    //打开摄像头，开始预览（未推流）
    mPublisher.startCamera();
    //mPublisher.switchToSoftEncoder();//选择软编码
    mPublisher.switchToHardEncoder();//选择硬编码
    //开始推流 rtmpUrl（ip换成服务器的部署ip）："rtmp://192.168.31.126/android/teststream"
    mPublisher.startPublish(rtmpUrl);
  }
}
