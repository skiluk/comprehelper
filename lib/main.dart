import 'package:camera/camera.dart';
import 'package:comprehelper/gpt_helper.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> cameras;

void main() async {
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CompreHelper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CompreHelper'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController camController;

  @override
  void initState() {
    super.initState();
    camController = CameraController(cameras[0], ResolutionPreset.max);
  }

  @override
  void dispose() {
    // camController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(onPressed: openTextDialog, child: const Text('Paste Text')),
            TextButton(onPressed: uploadDocument, child: const Text('Upload Document')),
            TextButton(onPressed: openCamera, child: const Text('Take Picture'))
          ],
        ),
      ),
    );
  }

  void openTextDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Paste Text'),
          content: TextField(
            controller: controller,
            minLines: 3,
            decoration: const InputDecoration(hintText: 'Paste here'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Gpthelper.apiHelper(text: controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void uploadDocument() {}

  void openCamera() async {
    camController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Stack(children: [
            CameraPreview(camController),
            IconButton(onPressed: takePicture, icon: const Icon(Icons.camera)),
          ]);
        },
      );
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  void takePicture() async {
    final XFile file = await camController.takePicture();
    Gpthelper.apiHelper(image: file);
  }
}
