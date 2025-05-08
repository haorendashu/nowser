import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:background_downloader/background_downloader.dart';

class DownloadProvider extends ChangeNotifier {
  FileDownloader fileDownloader = FileDownloader();

  List<TaskRecord> _allRecords = [];

  List<TaskRecord> get allRecords => _allRecords;

  Future<void> reloadData() async {
    _allRecords = await fileDownloader.database.allRecords();
  }

  Future<void> init() async {
    await fileDownloader.start();
    await reloadData();
  }

  Future<void> deleteTasks(List<String> taskIds) async {
    await fileDownloader.database.deleteRecordsWithIds(taskIds);
    await reloadData();
    notifyListeners();
  }

  Future<void> pauseDownload(DownloadTask downloadTask) async {
    fileDownloader.pause(downloadTask);
    await reloadData();
    notifyListeners();
  }

  Future<void> resumeDownload(DownloadTask downloadTask) async {
    fileDownloader.resume(downloadTask);
    await reloadData();
    notifyListeners();
  }

  Future<void> startDownload(String url, String fileName) async {
    var downloadDir = await getApplicationDocumentsDirectory();

    var downloadDirPath = downloadDir.absolute.path;

    // print("url $url fileName $fileName downloadDirPath $downloadDirPath");

    final task = DownloadTask(
      url: url,
      filename: fileName,
      baseDirectory: BaseDirectory.applicationDocuments,
      directory: 'downloads',
      updates: Updates.statusAndProgress, // request status and progress updates
      requiresWiFi: false,
      retries: 5,
      allowPause: true,
    );

    fileDownloader.download(
      task,
      onProgress: (progress) {
        print('Progress: ${progress * 100}%');
        notifyListeners();
      },
      onStatus: (status) {
        print('Status: $status');
        if (status == TaskStatus.running) {
          reloadData();
        }
        notifyListeners();
      },
    );
    notifyListeners();
  }
}
