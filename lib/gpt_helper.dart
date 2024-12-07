import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

enum OutputType { story, song, summary }

class Gpthelper {
  static Future<void> apiHelper({
    required BuildContext context,
    String? text,
    XFile? image,
    required OutputType output,
  }) async {
    /// API call
    ///

    final response = 'API response';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Paste Text'),
          content: Text(response),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
