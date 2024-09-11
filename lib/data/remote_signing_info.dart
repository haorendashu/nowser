class RemoteSigningInfo {
  int? id;
  int? appId;
  String? localPubkey;
  String? remotePubkey;
  String? remoteSignerKey;
  String? relays;
  String? secret;
  int? createdAt;
  int? updatedAt;

  RemoteSigningInfo(
      {this.id,
      this.appId,
      this.localPubkey,
      this.remotePubkey,
      this.remoteSignerKey,
      this.relays,
      this.secret,
      this.createdAt,
      this.updatedAt});

  RemoteSigningInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appId = json['app_id'];
    localPubkey = json['local_pubkey'];
    remotePubkey = json['remote_pubkey'];
    remoteSignerKey = json['remote_signer_key'];
    relays = json['relays'];
    secret = json['secret'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['app_id'] = this.appId;
    data['local_pubkey'] = this.localPubkey;
    data['remote_pubkey'] = this.remotePubkey;
    data['remote_signer_key'] = this.remoteSignerKey;
    data['relays'] = this.relays;
    data['secret'] = this.secret;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }

  static RemoteSigningInfo? parseNostrConnectUrl(String nostrconnectUrlText) {
    var uri = Uri.parse(nostrconnectUrlText);
    var pars = uri.queryParametersAll;
    var localPubkey = uri.host;

    var relays = pars["relay"];
    if (relays == null || relays.isEmpty) {
      return null;
    }

    return RemoteSigningInfo(
      localPubkey: localPubkey,
      relays: relays.join(","),
    );
  }
}
