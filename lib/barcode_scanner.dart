import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:scanner/result_screen.dart';

 class barcodeScanner extends StatefulWidget {
  const barcodeScanner({super.key});

  @override
  State<barcodeScanner> createState() => _barcodeScannerState();
}

class _barcodeScannerState extends State<barcodeScanner> {
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool isScanCompleted = false;
  MobileScannerController cameraController = MobileScannerController();

  void closeScreen() {
    isScanCompleted = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        // actions: [
        //   IconButton(
        //     onPressed: (){
        //       setState(() {
        //         isFlashOn = !isFlashOn;
        //       });
        //       cameraController.toggleTorch();
        //     },
        //     icon: Icon(
        //       Icons.flash_on,
        //       color:
        //       // isFlashOn ? Colors.white
        //       //     :
        //       Colors.black,
        //     ),
        //   ),
        //   IconButton(
        //       onPressed: (){
        //         setState(() {
        //           isFrontCamera = !isFrontCamera;
        //         });
        //         cameraController.switchCamera();
        //       },
        //       icon: Icon(
        //         Icons.flip_camera_android,
        //         color: isFrontCamera ? Colors.white
        //             : Colors.black,
        //       )
        //   ),
        // ],
      ),
      body: Container(
        width: double.infinity,
        // padding: EdgeInsets.all(20),
        child: Column(
          children: [

            Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      allowDuplicates: true,
                      onDetect: (barcode, args) {
                        if (!isScanCompleted) {
                          isScanCompleted = true;
                          String code = barcode.rawValue ?? "---";
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) {
                                  return ResultScreen(text: code,barcode: true,);
                                  // return QRResult(
                                  //   code: code,
                                  //   closeScreen: closeScreen,
                                  // );
                                }
                            ),
                          );
                        }
                      },
                    ),
                    QRScannerOverlay(
                      overlayColor: Colors.black26,
                      borderColor: Colors.amber.shade900,
                      borderRadius: 20,
                      borderStrokeWidth: 10,
                      scanAreaWidth: 250,
                      scanAreaHeight: 250,
                    )
                  ],
                )
            ),

          ],
        ),
      ),
    );
  }
}