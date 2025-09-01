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
    _allRecords.sort((task1, task2) {
      return task2.task.creationTime.millisecondsSinceEpoch -
          task1.task.creationTime.millisecondsSinceEpoch;
    });
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
    await fileDownloader.pause(downloadTask);
    await reloadData();
    notifyListeners();
  }

  Future<void> resumeDownload(DownloadTask downloadTask) async {
    await fileDownloader.resume(downloadTask);
    await reloadData();
    notifyListeners();
  }

  Future<void> startDownload(String url, String fileName) async {
    // var downloadDir = await getApplicationDocumentsDirectory();
    // var downloadDirPath = downloadDir.absolute.path;
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

    await fileDownloader.download(
      task,
      onProgress: (progress) {
        print('Progress: ${progress * 100}%');
        notifyListeners();
      },
      onStatus: (status) {
        print('Status: $status');
        reloadData();
        notifyListeners();
      },
    );
    notifyListeners();
  }
}
