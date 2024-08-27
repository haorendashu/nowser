class AuthLog {
  int id;

  int appId;

  int authType;

  int? eventKind;

  String? title;

  String? content;

  int authResult;

  int createdAt;

  AuthLog({
    required this.id,
    required this.appId,
    required this.authType,
    this.eventKind,
    this.title,
    this.content,
    required this.authResult,
    required this.createdAt,
  });
}
