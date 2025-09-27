import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoUtils {
  static String generateVideoUniqueKey(String input) {
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
}
