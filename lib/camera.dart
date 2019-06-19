import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:image/image.dart' as imglib;
import 'package:flutter/services.dart';
import 'socket.dart' as socket;

class CameraExampleHome extends StatefulWidget {
  @override
  _CameraExampleHomeState createState() {
    return _CameraExampleHomeState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver {
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;

  static const platform = const MethodChannel('flutter_app.example.com');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color:
                        controller != null && controller.value.isStreamingImages
                            ? Colors.redAccent
                            : Colors.grey,
                    width: 3.0,
                  ),
                ),
              ),
            ),
            _captureControlRowWidget(),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _cameraTogglesRowWidget(),
                  _thumbnailWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Stack(
          alignment: Alignment.center,
          overflow: Overflow.visible,
          children: <Widget>[
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller),
            ),
            Container(
              width: 150,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset(
                  'assets/smile.png',
                  color: Colors.blue[600],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue[600],
                  width: 15,
                ),
              ),
            ),
          ]);
    }
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            videoController == null && imagePath == null
                ? Container()
                : SizedBox(
                    child: (videoController == null)
                        ? Image.file(File(imagePath))
                        : Container(
                            child: Center(
                              child: AspectRatio(
                                  aspectRatio:
                                      videoController.value.size != null
                                          ? videoController.value.aspectRatio
                                          : 1.0,
                                  child: VideoPlayer(videoController)),
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.pink)),
                          ),
                    width: 48.0,
                    height: 48.0,
                  ),
          ],
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  !controller.value.isStreamingImages
              ? onTakePictureButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          color: Colors.blue,
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  !controller.value.isStreamingImages
              ? onVideoRecordButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  controller.value.isStreamingImages
              ? onStopButtonPressed
              : null,
        )
      ],
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in cameras) {
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: controller != null && controller.value.isRecordingVideo
                  ? null
                  : onNewCameraSelected,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      // if (filePath != null) showInSnackBar('Saving video to $filePath');
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recorded to: $videoPath');
    });
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (controller.value.isStreamingImages) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      controller.startImageStream((CameraImage img) async {
        controller.stopImageStream();
        Map imageMap = cameraImagetoMap(img);
        List<int> results = await platform.invokeMethod('convert', imageMap);
        print("aaaaaaaaaaaaa$results");
        await socket.main(results);
      });
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    // return filePath;
    return null;
  }

  Map cameraImagetoMap(CameraImage image) {
    var imageMap = new Map();
    imageMap['planes'] = new List(3);
    for (int i = 0; i < image.planes.length; i++) {
      var value = {};
      value['bytes'] = image.planes[i].bytes;
      value['bytesPerRow'] = image.planes[i].bytesPerRow;
      value['height'] = image.planes[i].height;
      value['width'] = image.planes[i].width;
      imageMap['planes'][i] = value;
    }
    imageMap['height'] = image.height;
    imageMap['width'] = image.width;
    return imageMap;
  }

  void savePicture(List<int> intArray) async {
    final Directory extDir = await getExternalStorageDirectory();
    final String dirPath = '${extDir.path}/Pictures/facenet_app';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';
    File('$filePath').writeAsBytesSync(intArray);
  }

  // using cpu thread to run this is WAY TOO SLOW
  // Future<List<int>> convertYUV420toImage(CameraImage image) async {
  //   final Directory extDir = await getExternalStorageDirectory();
  //   final String dirPath = '${extDir.path}/Pictures/facenet_app';
  //   await Directory(dirPath).create(recursive: true);
  //   final String filePath = '$dirPath/${timestamp()}.jpg';
  //   try {
  //     final int width = image.width;
  //     final int height = image.height;
  //     final int uvRowStride = image.planes[1].bytesPerRow;
  //     final int uvPixelStride = image.planes[1].bytesPerPixel;

  //     print("uvRowStride: " + uvRowStride.toString());
  //     print("uvPixelStride: " + uvPixelStride.toString());

  //     // imgLib -> Image package from https://pub.dartlang.org/packages/image
  //     var img = imglib.Image(width, height); // Create Image buffer

  //     // Fill image buffer with plane[0] from YUV420_888
  //     for (int x = 0; x < width; x++) {
  //       for (int y = 0; y < height; y++) {
  //         final int uvIndex =
  //             uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
  //         final int index = y * width + x;

  //         final yp = image.planes[0].bytes[index];
  //         final up = image.planes[1].bytes[uvIndex];
  //         final vp = image.planes[2].bytes[uvIndex];
  //         // Calculate pixel color
  //         int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
  //         int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
  //             .round()
  //             .clamp(0, 255);
  //         int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
  //         // color: 0x FF  FF  FF  FF
  //         //           A   B   G   R
  //         img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
  //       }
  //     }

  //     // Convert to png using pngencoder
  //     imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0, filter: 0);
  //     // img = imglib.copyResize(img, width: 480);
  //     List<int> png = pngEncoder.encodeImage(img);
  //     print(png.length);
  //     File('$filePath').writeAsBytesSync(png);
  //     return png;
  //   } catch (e) {
  //     print("ERROR:" + e.toString());
  //   }
  //   return null;
  // }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isStreamingImages) {
      return null;
    }

    try {
      await controller.stopImageStream();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    await _startVideoPlayer();
  }

  Future<void> _startVideoPlayer() async {
    final VideoPlayerController vcontroller =
        VideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imagePath = null;
        videoController = vcontroller;
      });
    }
    await vcontroller.play();
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getExternalStorageDirectory();
    print(extDir.path);
    final String dirPath = '${extDir.path}/Pictures/facenet_app';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraExampleHome(),
    );
  }
}

List<CameraDescription> cameras;

Future<void> init() async {
  // Fetch the available cameras before initializing the app.
  try {
    cameras = await availableCameras();
    await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    await SimplePermissions.requestPermission(Permission.Camera);
    await SimplePermissions.requestPermission(Permission.RecordAudio);
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  // runApp(CameraApp());
}
