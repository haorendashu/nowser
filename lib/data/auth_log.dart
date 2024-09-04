class AuthLog {
  int? id;

  int? appId;

  int? authType;

  int? eventKind;

  String? title;

  String? content;

  int? authResult;

  int? createdAt;

  AuthLog(
      {this.id,
      this.appId,
      this.authType,
      this.eventKind,
      this.title,
      this.content,
      this.authResult,
      this.createdAt});

  AuthLog.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appId = json['app_id'];
    authType = json['auth_type'];
    eventKind = json['event_kind'];
    title = json['title'];
    content = json['content'];
    authResult = json['auth_result'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['app_id'] = this.appId;
    data['auth_type'] = this.authType;
    data['event_kind'] = this.eventKind;
    data['title'] = this.title;
    data['content'] = this.content;
    data['auth_result'] = this.authResult;
    data['created_at'] = this.createdAt;
    return data;
  }
}
