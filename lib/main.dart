import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ia_proyecto/routes/routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Perro o Gato',
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.getAppRoutes(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      // home: MyHomePage(),

    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  bool _loading = true;
  final ImagePicker picker = ImagePicker();
  File? image;
  List? output;

  chooseImage() async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        image = File(file.path);
      });
    }
    if (image != null) {
      classifyImage(image!);
    }
  }

  captureImage() async {
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() {
        image = File(file.path);
      });
    }
    if (image != null) {
      classifyImage(image!);
    }
  }

  classifyImage(File img) async {
    var result = await Tflite.runModelOnImage(
        path: img.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      output = result;
      print(output);
      _loading = false;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model3.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
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
              'DECTECTOR DE PERROS Y GATOS - TFLITE ',
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
              child: _loading
                  ? SizedBox(
                      width: 280,
                      child: Column(children: [
                        Image.asset('assets/pngegg.png'),
                        const SizedBox(
                          height: 50,
                        ),
                      ]),
                    )
                  : SizedBox(
                      child: Column(children: [
                        SizedBox(
                          height: 250,
                          child: Image.file(image!),
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
                  onTap: captureImage,
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
                      'Tomar Fotografia',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: chooseImage,
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
                      'Galeria',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.pushNamed(context, 'camera');
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 150,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 17,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Tiempo real',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                )
              ]),
            )
          ],
        ),
      ),
    );
  }
}


