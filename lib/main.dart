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
            TextButton.icon(
                icon: const Icon(Icons.camera),
                label: const Text('Take Picture'),
                onPressed: openCamera),
            TextButton.icon(
              icon: const Icon(Icons.paste),
              label: const Text('Paste Text'),
              onPressed: openTextDialog,
            ),
            TextButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('Upload Document'),
              onPressed: uploadDocument,
            ),
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
                outputDialog(text: controller.text);
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
            Expanded(child: CameraPreview(camController)),
            Align(
                alignment: Alignment.bottomCenter,
                child: IconButton(
                    onPressed: takePicture,
                    icon: const Icon(Icons.camera),
                    iconSize: 60,
                    color: Colors.orange)),
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
    Navigator.of(context).pop();
    outputDialog(image: file);
  }

  void outputDialog({String? text, XFile? image}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Output Options'),
          content: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton.icon(
                    icon: const Icon(Icons.book),
                    label: const Text('Story'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await Gpthelper.apiHelper(
                          context: context, text: text, image: image, output: OutputType.story);
                    }),
                TextButton.icon(
                    icon: const Icon(Icons.mic_external_on_sharp),
                    label: const Text('Song'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await Gpthelper.apiHelper(
                          context: context, text: text, image: image, output: OutputType.song);
                    }),
                TextButton.icon(
                    icon: const Icon(Icons.summarize),
                    label: const Text('Summary'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await Gpthelper.apiHelper(
                          context: context, text: text, image: image, output: OutputType.summary);
                    }),
              ],
            ),
          ),
        );
      },
    );
  }
}
