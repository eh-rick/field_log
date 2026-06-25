import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  Uint8List _getIV() => Uint8List(16);

  String encryptText(String text, String uuid) {
    final keyBytes = Uint8List.fromList(utf8.encode(uuid.replaceAll('-', '').substring(0, 32)));
    final cipher = CBCBlockCipher(AESEngine())
      ..init(true, ParametersWithIV(KeyParameter(keyBytes), _getIV()));
    
    final inputBytes = Uint8List.fromList(utf8.encode(text));
    final paddedBytes = _pad(inputBytes, 16);
    return base64.encode(cipher.process(paddedBytes));
  }

  String decryptText(String encryptedText, String uuid) {
    final keyBytes = Uint8List.fromList(utf8.encode(uuid.replaceAll('-', '').substring(0, 32)));
    final cipher = CBCBlockCipher(AESEngine())
      ..init(false, ParametersWithIV(KeyParameter(keyBytes), _getIV()));
    
    final inputBytes = base64.decode(encryptedText);
    final decryptedBytes = cipher.process(Uint8List.fromList(inputBytes));
    return utf8.decode(_unpad(decryptedBytes));
  }

  Uint8List _pad(Uint8List src, int blockSize) {
    final padLength = blockSize - (src.length % blockSize);
    final out = Uint8List(src.length + padLength);
    out.setAll(0, src);
    for (var i = src.length; i < out.length; i++) {
      out[i] = padLength;
    }
    return out;
  }

  Uint8List _unpad(Uint8List src) {
    final padLength = src.last;
    return Uint8List.view(src.buffer, 0, src.length - padLength);
  }
}