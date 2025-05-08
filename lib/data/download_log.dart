class DownloadLog {
  int? id;

  String? url;

  String? filePath;

  String? fileName;

  int? fileSize;

  int? createdAt;

  String? taskId;

  double? progress;

  DownloadLog({
    this.id,
    this.url,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.createdAt,
    this.taskId,
    this.progress,
  });

  DownloadLog.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    filePath = json['file_path'];
    fileName = json['file_name'];
    fileSize = json['file_size'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['url'] = url;
    data['file_path'] = filePath;
    data['file_name'] = fileName;
    data['file_size'] = fileSize;
    data['created_at'] = createdAt;
    return data;
  }
}
