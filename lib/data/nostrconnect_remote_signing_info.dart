import 'package:nostr_sdk/utils/string_util.dart';
import 'package:nowser/data/remote_signing_info.dart';

class NostrconnectRemoteSigningInfo extends RemoteSigningInfo {
  String? perms;

  String? name;

  String? url;

  String? image;

  NostrconnectRemoteSigningInfo({
    super.id,
    super.appId,
    super.localPubkey,
    super.remotePubkey,
    super.remoteSignerKey,
    super.relays,
    super.secret,
    super.createdAt,
    super.updatedAt,
    this.perms,
    this.name,
    this.url,
    this.image,
  });

  NostrconnectRemoteSigningInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appId = json['app_id'];
    localPubkey = json['local_pubkey'];
    remotePubkey = json['remote_pubkey'];
    remoteSignerKey = json['remote_signer_key'];
    relays = json['relays'];
    secret = json['secret'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    perms = json['perms'];
    name = json['name'];
    url = json['url'];
    image = json['image'];
  }

  // don't implement toJson method and when saving data it only save the super.toJson data.
  // @override
  // Map<String, dynamic> toJson() {
  //   final data = super.toJson();
  //   data['perms'] = perms;
  //   data['name'] = name;
  //   data['url'] = url;
  //   data['image'] = image;
  //   return data;
  // }

  static NostrconnectRemoteSigningInfo? parseNostrConnectUrl(
      String nostrconnectUrlText) {
    var uri = Uri.parse(nostrconnectUrlText);
    var parsList = uri.queryParametersAll;
    var pars = uri.queryParameters;
    var localPubkey = uri.host;

    var relays = parsList['relay'];
    var secret = pars['secret'];
    var perms = pars['perms'];
    var name = pars['name'];
    var url = pars['url'];
    var image = pars['image'];
    if (relays == null || relays.isEmpty || StringUtil.isBlank(secret)) {
      return null;
    }

    return NostrconnectRemoteSigningInfo(
      localPubkey: localPubkey,
      relays: relays.join(","),
      secret: secret,
      perms: perms,
      name: name,
      url: url,
      image: image,
    );
  }
}
