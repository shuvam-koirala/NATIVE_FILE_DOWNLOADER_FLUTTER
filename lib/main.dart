import 'dart:async';
import 'package:native_flutter_downloader/native_flutter_downloader.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController urlController = TextEditingController(
      text: "https://www.princexml.com/samples/invoice/invoicesample.pdf");
  int progress = 0;
  late StreamSubscription progressStream;

  @override
  void initState() {
    NativeFlutterDownloader.initialize();
    progressStream = NativeFlutterDownloader.progressStream.listen((event) {
      if (event.status == DownloadStatus.successful) {
        setState(() {
          progress = event.progress;
        });
      } else if (event.status == DownloadStatus.running) {
        debugPrint('event.progress: ${event.progress}');
        setState(() {
          progress = event.progress;
        });
      } else if (event.status == DownloadStatus.failed) {
        debugPrint('event: ${event.statusReason?.message}');
        debugPrint('Download failed');
      } else if (event.status == DownloadStatus.paused) {
        debugPrint('Download paused');
        Future.delayed(
          const Duration(milliseconds: 250),
          () =>
              NativeFlutterDownloader.attachDownloadProgress(event.downloadId),
        );
      } else if (event.status == DownloadStatus.pending) {
        debugPrint('event.progress: ${event.progress}');
        debugPrint('Download pending');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    progressStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Flutter Downloader'),
        ),
        body: Column(
          children: [
            if (progress > 0 && progress < 100)
              LinearProgressIndicator(
                value: progress / 100,
                color: Colors.orange,
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: urlController,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.file_download),
          onPressed: () async {
            final permission =
                await NativeFlutterDownloader.requestPermission();
            if (permission == StoragePermissionStatus.granted) {
              debugPrint('Permission granted =)');
              await NativeFlutterDownloader.download(
                urlController.text,
                fileName: urlController.text.split("/").last,
                savedFilePath: '/storage/emulated/0/Download/PrinceXml',
              );
            } else {
              debugPrint('Permission denied =(');
            }
          },
        ),
      ),
    );
  }
}
