import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';



class VideoCard extends StatefulWidget {
  const VideoCard({Key? key}) : super(key: key);

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _mostrarCamara = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text("VIDEOS"),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _mostrarDialogo(context);
            },
            child: Text("Abrir Cámara"),
          ),
          SizedBox(height: 16),
          _mostrarCamara
              ? Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 400,
                      child: CameraPreview(_controller),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _apagarCamara();
                      },
                      child: Text("Apagar Cámara"),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  void _mostrarDialogo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text("Cerrar"),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _mostrarCamara = false;
                    });
                  },
                )
              ],
            ),
          ),
        );
      },
    ).then((_) {
      _cargarModelo().then((_) {
        setState(() {
          _mostrarCamara = true;
          _iniciarVistaPreviaCamara();
        });
      });
    });
  }

  Future<void> _cargarModelo() async {
    try {
      await Tflite.loadModel(
        model: 'assets/model.tflite',
      );
      print("Modelo cargado con éxito");
    } catch (e) {
      print("Error al cargar el modelo: $e");
    }
  }

  void _iniciarVistaPreviaCamara() async {
    try {
      await _initializeControllerFuture;
      _controller.startImageStream((CameraImage img) {
        // Convertir el frame de la cámara a un formato compatible con TFLite
        Tflite.runModelOnFrame(
          bytesList: img.planes.map((plane) => plane.bytes).toList(),
          imageHeight: img.height,
          imageWidth: img.width,
          numResults: 2, // Número de resultados esperados
        ).then((List<dynamic>? resultados) {
          // Aquí puedes manejar los resultados de la inferencia
          // print(resultados);
          print("MODELO FUNCIONANDO");
        }).catchError((e) {
          print("Error al realizar la inferencia: $e");
        });
      });
    } catch (e) {
      print("Error al iniciar la vista previa de la cámara: $e");
    }
  }

  void _apagarCamara() {
    setState(() {
      _mostrarCamara = false;
    });
    _controller.stopImageStream();
  }
}




// class VideoCard extends StatefulWidget {
//   const VideoCard({Key? key}) : super(key: key);

//   @override
//   _VideoCardState createState() => _VideoCardState();
// }

// class _VideoCardState extends State<VideoCard> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   bool _mostrarCamara = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     _controller = CameraController(cameras[0], ResolutionPreset.medium);
//     _initializeControllerFuture = _controller.initialize();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         children: [
//           Text("VIDEOS"),
//           SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () {
//               _mostrarDialogo(context);
//             },
//             child: Text("Abrir Cámara"),
//           ),
//           SizedBox(height: 16),
//           _mostrarCamara
//               ? Column(
//                   children: [
//                     Container(
//                       width: double.infinity,
//                       height: 400,
//                       child: CameraPreview(_controller),
//                     ),
//                     SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         _apagarCamara();
//                       },
//                       child: Text("Apagar Cámara"),
//                     ),
//                   ],
//                 )
//               : Container(),
//         ],
//       ),
//     );
//   }

//   void _mostrarDialogo(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 GestureDetector(
//                   child: Text("Cerrar"),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     setState(() {
//                       _mostrarCamara = false;
//                     });
//                   },
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     ).then((_) {
//       setState(() {
//         _mostrarCamara = true;
//         _iniciarVistaPreviaCamara();
//       });
//     });
//   }

//   void _iniciarVistaPreviaCamara() async {
//     try {
//       await _initializeControllerFuture;
//       _controller.startImageStream((CameraImage img) {
//         // Aquí puedes realizar operaciones con cada frame de la cámara
//       });
//     } catch (e) {
//       print("Error al iniciar la vista previa de la cámara: $e");
//     }
//   }

//   void _apagarCamara() {
//     setState(() {
//       _mostrarCamara = false;
//     });
//     _controller.stopImageStream();
//   }
// }


// class VideoCard extends StatefulWidget {
//   const VideoCard({Key? key}) : super(key: key);

//   @override
//   _VideoCardState createState() => _VideoCardState();
// }

// class _VideoCardState extends State<VideoCard> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   bool _mostrarCamara = false;

//   @override
//     void initState() {
//       super.initState();
//       _initializeCamera();
//       _cargarModelo();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     _controller = CameraController(cameras[0], ResolutionPreset.medium);
//     _initializeControllerFuture = _controller.initialize();
//   }

//   Future<void> _cargarModelo() async {
//     await Tflite.loadModel(
//       model: 'assets/model.tflite',
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     Tflite.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         children: [
//           Text("VIDEOS"),
//           SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () {
//               _mostrarDialogo(context);
//             },
//             child: Text("Tomar Foto"),
//           ),
//           SizedBox(height: 16),
//           _mostrarCamara
//               ? Container(
//                   width: 200, // Ajusta el tamaño según tus necesidades
//                   height: 200,
//                   child: CameraPreview(_controller),
//                 )
//               : Container(),
//         ],
//       ),
//     );
//   }

//   void _mostrarDialogo(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 GestureDetector(
//                   child: Text("Tomar fotografía"),
//                   onTap: () async {
//                     await _initializeControllerFuture;
//                     setState(() {
//                       _mostrarCamara = true;
//                     });
//                     _tomarFoto();
//                   },
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(8.0),
//                 ),
//                 GestureDetector(
//                   child: Text("Cerrar"),
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     setState(() {
//                       _mostrarCamara = false;
//                     });
//                   },
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }



//   void _tomarFoto() async {
//     try {
//       final XFile foto = await _controller.takePicture();
//       // Manejar la foto según tus necesidades

//       // Realizar inferencia en la foto con TensorFlow Lite
//       List<dynamic>? resultados = await Tflite.runModelOnImage(
//         path: foto.path,
//         imageMean: 0.0,
//         imageStd: 255.0,
//         threshold: 0.2,
//         numResults: 2,
//         asynch: true,
//       );

//       // Verificar si resultados no es nulo antes de utilizarlo
//       if (resultados != null) {
//         // Imprimir los resultados
//         print(resultados);
//       }

//       // Cerrar el diálogo después de tomar la foto
//       Navigator.of(context).pop();
//     } catch (e) {
//       print("Error al tomar la foto: $e");
//     }
//   }

// }

