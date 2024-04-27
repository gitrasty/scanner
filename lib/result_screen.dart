import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String text;
  final  image;
  final bool barcode;


  const ResultScreen({super.key, required this.text,this.image,required this.barcode});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          // title: const Text('Result'),
        ),
        body: Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
             children: [
            barcode==true?Container():  Container(width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/2,
              decoration: BoxDecoration(
                image: DecorationImage(image: FileImage(image))
              ),
              ),

              Center(
                child: SelectableText(
                  text,
                  showCursor: true,
                  toolbarOptions: ToolbarOptions(
                      copy: true, selectAll: true, cut: false, paste: false),
                ),
              ),
            ],
          ),
        ),
      );
}
