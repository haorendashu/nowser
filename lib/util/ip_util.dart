import 'dart:io';

class IpUtil {
  static Future<String?> getIp() async {
    var ips = await NetworkInterface.list();
    for (var interface in ips) {
      print('== Interface: ${interface.name} ==');
      if ((interface.name.toLowerCase()).contains("wlan")) {
        for (var addr in interface.addresses) {
          print(
              '${addr.address} ${addr.host} ${addr.isLoopback} ${addr.rawAddress} ${addr.type.name}');
          return addr.address;
        }
      }
    }

    return ips.first.addresses.first.address;
  }
}
