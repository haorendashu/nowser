class App {
  int id;

  String pubkey;

  int appType;

  String code;

  String name;

  String? image;

  String? permissions;

  App({
    required this.id,
    required this.pubkey,
    required this.appType,
    required this.code,
    required this.name,
    this.image,
    this.permissions,
  });
}
