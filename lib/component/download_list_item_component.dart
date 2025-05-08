import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:nowser/const/base.dart';
import 'package:nowser/data/download_log.dart';
import 'package:nowser/main.dart';
import 'package:nowser/util/file_size_util.dart';
import 'package:path/path.dart' as path;

class DownloadListItemComponent extends StatelessWidget {
  DownloadLog downloadLog;

  DownloadListItemComponent(this.downloadLog);

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);

    Widget fileIconWidget = const Icon(
      AntDesign.file1,
      size: 40,
    );
    if (downloadLog.fileName != null) {
      var mimeType = getFileType(downloadLog.fileName!);
      if (mimeType.contains("image")) {
        fileIconWidget = const Icon(
          Icons.image,
          size: 40,
        );
      } else if (mimeType.contains("markdown")) {
        fileIconWidget = const Icon(
          AntDesign.file_markdown,
          size: 40,
        );
      } else if (mimeType.contains("document")) {
        fileIconWidget = const Icon(
          AntDesign.filetext1,
          size: 40,
        );
      } else if (mimeType.contains("video")) {
        fileIconWidget = const Icon(
          Icons.movie,
          size: 40,
        );
      } else if (mimeType.contains("audio")) {
        fileIconWidget = const Icon(
          Icons.music_note,
          size: 40,
        );
      } else if (mimeType.contains("archive")) {
        fileIconWidget = const Icon(
          Icons.folder_zip,
          size: 40,
        );
      } else if (mimeType.contains("apk")) {
        fileIconWidget = const Icon(
          AntDesign.android,
          size: 40,
        );
      }
    }

    Widget rightIcon = GestureDetector(
      onTap: () {},
      child: const Icon(
        Icons.more_horiz,
      ),
    );
    if (downloadLog.progress != null) {
      rightIcon = GestureDetector(
        onTap: () {},
        child: const Icon(
          Icons.stop_circle_outlined,
        ),
      );
    }

    Widget fileStatusWidget = Container();
    if (downloadLog.progress != null) {
      fileStatusWidget = Text(
        "${(downloadLog.progress! * 100).toStringAsFixed(1)}%",
        style: TextStyle(
          fontSize: themeData.textTheme.bodySmall!.fontSize,
          color: themeData.hintColor,
        ),
      );
    } else if (downloadLog.fileSize != null) {
      fileStatusWidget = Text(
        FileSizeUtil.getFileSize(downloadLog.fileSize!),
        style: TextStyle(
          fontSize: themeData.textTheme.bodySmall!.fontSize,
          color: themeData.hintColor,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(
        left: Base.BASE_PADDING_HALF,
        right: Base.BASE_PADDING_HALF,
        top: 2,
        bottom: 2,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            child: fileIconWidget,
          ),
          Expanded(
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    downloadLog.fileName ?? "unknow_file",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  fileStatusWidget,
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            child: rightIcon,
          ),
        ],
      ),
    );
  }

  String getFileType(String filePath) {
    // 获取扩展名（含点，如 '.jpg'）
    String extension = path.extension(filePath).toLowerCase();

    // 处理无扩展名的情况
    if (extension.isEmpty) return 'other';

    // 去掉点并检查映射
    String cleanedExtension =
        extension.startsWith('.') ? extension.substring(1) : extension;

    return _fileExtensionToType[cleanedExtension] ?? 'other';
  }

  Map<String, String> _fileExtensionToType = {
    // 图片类型
    'jpg': 'image',
    'jpeg': 'image',
    'png': 'image',
    'gif': 'image',
    'webp': 'image',
    'bmp': 'image',
    'mp4': 'video',
    'mov': 'video',
    'avi': 'video',
    'mkv': 'video',
    'flv': 'video',
    'pdf': 'document',
    'doc': 'document',
    'docx': 'document',
    'xls': 'document',
    'xlsx': 'document',
    'ppt': 'document',
    'pptx': 'document',
    'txt': 'document',
    'md': 'markdown',
    'markdown': 'markdown',
    'mp3': 'audio',
    'wav': 'audio',
    'aac': 'audio',
    'ogg': 'audio',
    'zip': 'archive',
    'rar': 'archive',
    '7z': 'archive',
    'tar': 'archive',
    'gz': 'archive',
    'apk': 'apk',
  };
}
