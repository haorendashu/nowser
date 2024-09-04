class ZapLog {
  int? id;

  int? appId;

  int? zapType;

  int? num;

  int? createdAt;

  ZapLog({
    this.id,
    this.appId,
    this.zapType,
    this.num,
    this.createdAt,
  });

  ZapLog.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appId = json['app_id'];
    zapType = json['zap_type'];
    num = json['num'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['app_id'] = this.appId;
    data['zap_type'] = this.zapType;
    data['num'] = this.num;
    data['created_at'] = this.createdAt;
    return data;
  }
}
