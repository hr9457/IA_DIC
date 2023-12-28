import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Perro o Gato',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _loading = true;
  File? image;
  List? output;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    loadModel().then((value) {
      setState(() {});
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    _controller.startImageStream((CameraImage img) {
      _processCameraImage(img);
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model3.tflite', labels: 'assets/labels.txt');
  }

  void _processCameraImage(CameraImage img) async {
    if (_loading) {
      return;
    }
    
    // Convertir el frame de la cámara a un formato compatible con TFLite
    Tflite.runModelOnFrame(
      bytesList: img.planes.map((plane) => plane.bytes).toList(),
      imageHeight: img.height,
      imageWidth: img.width,
      numResults: 2, // Número de resultados esperados
    ).then((List<dynamic>? resultados) {
      setState(() {
        output = resultados;
        print(output);
      });
    }).catchError((e) {
      print("Error al realizar la inferencia: $e");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 32, 50, 56),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 85,
            ),
            const Text(
              '201314296 - Hector Orozco',
              style: TextStyle(color: Color.fromARGB(255, 189, 119, 16), fontSize: 15),
            ),
            const Text(
              '201212535 - Mike Molina',
              style: TextStyle(color: Color.fromARGB(255, 189, 119, 16), fontSize: 15),
            ),
            const SizedBox(
              height: 6,
            ),
            const Text(
              'DETECTOR DE PERROS Y GATOS - TFLITE',
              style: TextStyle(
                color: Color(0XFFE99600),
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            Center(
              child: SizedBox(
                child: Column(children: [
                  SizedBox(
                    height: 250,
                    child: _loading
                        ? CircularProgressIndicator()
                        : CameraPreview(_controller),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  output != null
                      ? Text(
                          '${output![0]['label']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 50,
                  ),
                ]),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _loading = false;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 150,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 17,
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 233, 66, 0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Iniciar Captura',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _loading = true;
                      output = null;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 150,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 17,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE99600),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Detener Captura',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}




// class _MyHomePageState extends State<MyHomePage> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   bool _loading = true;
//   File? image;
//   List? output;

//   @override
//   void initState() {
//     super.initState();
//     _initializeControllerFuture = _initializeCamera();
//     loadModel().then((value) {
//       setState(() {});
//     });
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     _controller = CameraController(cameras[0], ResolutionPreset.medium);
//     await _controller.initialize();
//     _controller.startImageStream((CameraImage img) {
//       _processCameraImage(img);
//     });
//   }

//   void _processCameraImage(CameraImage img) async {
//     if (_loading) {
//       return;
//     }
    
//     // Resto del código...
//   }

//   // Resto del código...
// }
