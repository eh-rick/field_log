import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  encrypt.Key _deriveKey(String uuid) {
    final normalized = uuid.replaceAll('-', '').toLowerCase();
    final padded = normalized.padRight(32, '0').substring(0, 32);
    return encrypt.Key.fromUtf8(padded);
  }

  encrypt.IV _getIV() => encrypt.IV(Uint8List(16));

  String encryptText(String text, String uuid) {
    if (text.isEmpty) return '';
    final key = _deriveKey(uuid);
    final iv = _getIV();
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    
    return encrypter.encrypt(text, iv: iv).base64;
  }

  String decryptText(String encryptedText, String uuid) {
    if (encryptedText.isEmpty) return '';
    try {
      final key = _deriveKey(uuid);
      final iv = _getIV();
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      
      return encrypter.decrypt64(encryptedText, iv: iv);
    } catch (_) {
      return encryptedText;
    }
  }
}