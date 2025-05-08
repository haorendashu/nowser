class FileSizeUtil {
  static String getFileSize(int fileSize) {
    if (fileSize > 1024 * 1024 * 1024) {
      return "${fileSize ~/ (1024 * 1024 * 1024)} GB";
    } else if (fileSize > 1024 * 1024) {
      return "${fileSize ~/ (1024 * 1024)} MB";
    } else if (fileSize > 1024) {
      return "${fileSize ~/ 1024} KB";
    }
    return "$fileSize B";
  }
}
