import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nowser/data/download_log_db.dart';
import 'package:path_provider/path_provider.dart';
import 'package:background_downloader/background_downloader.dart';

import '../data/download_log.dart';

class DownloadProvider extends ChangeNotifier {
  FileDownloader fileDownloader = FileDownloader();

  List<DownloadLog> currentDownloadLogs = [];

  Map<String, DownloadTask> taskMap = {};

  // Future<void> init() async {
  //   await _reloadData();
  // }

  // Future<void> _reloadData() async {
  //   // _downloadLogs = await BookmarkDB.all();
  // }

  // Future<void> reload() async {
  //   await _reloadData();
  //   notifyListeners();
  // }

  void pauseDownload(String taskId) {
    fileDownloader.database.allRecords();
    var downloadTask = taskMap[taskId];
    if (downloadTask != null) {
      fileDownloader.pause(downloadTask);
    }
  }

  void resumeDownload(String taskId) {
    var downloadTask = taskMap[taskId];
    if (downloadTask != null) {
      fileDownloader.resume(downloadTask);
    }
  }

  Future<void> startDownload(String url, String fileName) async {
    var downloadDir = await getApplicationDocumentsDirectory();

    var downloadDirPath = downloadDir.absolute.path;

    print("url $url fileName $fileName downloadDirPath $downloadDirPath");

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

    var downloadLog = DownloadLog(
      url: url,
      filePath:
          "$downloadDirPath${Platform.pathSeparator}downloads${Platform.pathSeparator}$fileName",
      fileName: fileName,
      taskId: task.taskId,
      progress: 0,
    );

    currentDownloadLogs.add(downloadLog);
    taskMap[task.taskId] = task;

    // Start download, and wait for result. Show progress and status changes
    // while downloading
    var downloadResult = await fileDownloader.download(
      task,
      onProgress: (progress) {
        print('Progress: ${progress * 100}%');
        downloadLog.progress = progress;
        notifyListeners();
      },
      onStatus: (status) {
        print('Status: $status');
      },
    );

    if (downloadResult.status == TaskStatus.complete) {
      var file = File(downloadLog.filePath!);
      downloadLog.fileSize = file.lengthSync();
      downloadLog.createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      DownloadLogDB.insert(downloadLog);
    }

    currentDownloadLogs.remove(downloadLog);
    notifyListeners();
  }
}
