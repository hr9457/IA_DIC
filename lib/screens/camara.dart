import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:ia_proyecto/main.dart';


class camaraScreen extends StatefulWidget {
  const camaraScreen({super.key});

  @override
  State<camaraScreen> createState() => _camaraScreenState();
}

class _camaraScreenState extends State<camaraScreen> {
  
  bool isWorking = false;
  String result = '';
  late CameraController cameraController;   
  late CameraImage imgCamera;


  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model3.tflite', labels: 'assets/labels.txt');
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    loadModel();

    startCamera();

  }


  startCamera(){
    cameraController = CameraController(cameras[0], ResolutionPreset.max);
  
    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController.startImageStream((imageFromStream) => {
              if (!isWorking)
                {
                  isWorking = true,
                  imgCamera = imageFromStream,
                  runModelOnStreamFrames(),
                }
            });
      });
    });
  }


  runModelOnStreamFrames() async {
    var recognitions = await Tflite.runModelOnFrame(
        bytesList: imgCamera.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: imgCamera.height,
        imageWidth: imgCamera.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true
      );

    recognitions?.forEach((response) {
      result = response["label"] + "<" + (response["confidence"] as double).toStringAsFixed(2) + ">\n\n";
      print(result);
    });

    setState(() {
      result;
    });
    isWorking = false;
  }

  @override
  void dispose() async{
    // TODO: implement dispose
    await Tflite.close();
    cameraController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Camera'),
      ),
      body: SingleChildScrollView( 
        physics: const BouncingScrollPhysics(),
        child: Container(
          child: Column(
            children: [
              Center(
                child: Container(
                  height: size.height * 0.6,
                  color: Colors.amber,
                  child: CameraPreview(cameraController),
                ),
              ),
              Container(
                height: size.height * 0.4,
                color: Colors.blue,
                child: Column(
                  children: [
                    Center(
                      child: Text(result),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
       ),
    );
  }


}