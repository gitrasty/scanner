import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scanner/result_screen.dart';

class text_recognition extends StatefulWidget {
  const text_recognition({super.key});

  @override
  State<text_recognition> createState() => _text_recognitionState();
}

class _text_recognitionState extends State<text_recognition>
    with WidgetsBindingObserver {
  bool _isPermissionGranted = false;

  late final Future<void> _future;
  CameraController? _cameraController;

  final textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Stack(
          children: [
            if (_isPermissionGranted)
              FutureBuilder<List<CameraDescription>>(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _initCameraController(snapshot.data!);

                    return Center(child: CameraPreview(_cameraController!));
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
            Scaffold(
                appBar: AppBar(
                  title: const Text('Text Scanner'),
                ),
                backgroundColor:
                    _isPermissionGranted ? Colors.transparent : null,
                body: _isPermissionGranted
                    ? Column(
                        children: [
                          Expanded(
                            child: Container(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: Container(
                              //     // padding: const EdgeInsets.only(bottom: 30.0),
                              //     width: 60,
                              //
                              //     decoration: BoxDecoration(
                              //         color: Colors.white,
                              //         borderRadius: BorderRadius.circular(10)),
                              //     child: Center(
                              //       child: MaterialButton(
                              //         onPressed: _scanImage,
                              //         child: Center(
                              //             child: Icon(
                              //           Icons.image,
                              //           size: 35,
                              //         )),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(
                              //   width: MediaQuery.of(context).size.width / 4.5,
                              // ),
                              Container(
                                padding: const EdgeInsets.only(bottom: 40.0),
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: _scanImageCamera,
                                    child: const Text('Scan text'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Center(
                        child: Container(
                          padding:
                              const EdgeInsets.only(left: 24.0, right: 24.0),
                          child: const Text(
                            'Camera permission denied',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                floatingActionButton: FloatingActionButton(
                    onPressed: _scanImage,
                    child: Icon(
                      Icons.image,
                      size: 35,
                    )),

            ),
          ],
        );
      },
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera.
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _scanImageCamera() async {
    if (_cameraController == null) return;

    final navigator = Navigator.of(context);

    try {
      final pictureFile = await _cameraController!.takePicture();

      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);

      await navigator.push(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              ResultScreen(text: recognizedText.text,
              image: file,barcode: false,),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) return;

    final navigator = Navigator.of(context);

    try {
      final ImagePicker picker = ImagePicker();
// Pick an image.
      final pictureFile = await picker.pickImage(source: ImageSource.gallery);

      final file = File(pictureFile!.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);

      await navigator.push(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              ResultScreen(text: recognizedText.text,
                image: file,barcode: false,),
        ),
      );
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('An error occurred when scanning text'),
      //   ),
      // );
    }
  }
}
