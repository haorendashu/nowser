import 'package:flutter/material.dart';

class AuthType {
  static const GET_PUBLIC_KEY = 1;

  static const SIGN_EVENT = 2;

  static const GET_RELAYS = 3;

  static const NIP04_ENCRYPT = 4;

  static const NIP04_DECRYPT = 5;

  static const NIP44_ENCRYPT = 6;

  static const NIP44_DECRYPT = 7;

  static String getAuthName(BuildContext context, int authType) {
    if (authType == GET_PUBLIC_KEY) {
      return "Get Public Key";
    } else if (authType == SIGN_EVENT) {
      return "Sign Event";
    } else if (authType == GET_RELAYS) {
      return "Get Relays";
    } else if (authType == NIP04_ENCRYPT) {
      return "Encrypt (NIP-04)";
    } else if (authType == NIP04_DECRYPT) {
      return "Decrypt (NIP-04)";
    } else if (authType == NIP44_ENCRYPT) {
      return "Encrypt (NIP-44)";
    } else if (authType == NIP44_DECRYPT) {
      return "Decrypt (NIP-44)";
    }

    return "Unknow";
  }
}
