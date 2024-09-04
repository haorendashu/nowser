class App {
  int? id;

  String? pubkey;

  int? appType;

  String? code;

  String? name;

  String? image;

  int? connectType;

  String? alwaysAllow;

  String? alwaysReject;

  int? createdAt;

  int? updatedAt;

  App(
      {this.id,
      this.pubkey,
      this.appType,
      this.code,
      this.name,
      this.image,
      this.connectType,
      this.alwaysAllow,
      this.alwaysReject,
      this.createdAt,
      this.updatedAt});

  App.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pubkey = json['pubkey'];
    appType = json['app_type'];
    code = json['code'];
    name = json['name'];
    image = json['image'];
    connectType = json['connect_type'];
    alwaysAllow = json['always_allow'];
    alwaysReject = json['always_reject'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['pubkey'] = this.pubkey;
    data['app_type'] = this.appType;
    data['code'] = this.code;
    data['name'] = this.name;
    data['image'] = this.image;
    data['connect_type'] = this.connectType;
    data['always_allow'] = this.alwaysAllow;
    data['always_reject'] = this.alwaysReject;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
