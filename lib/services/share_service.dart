import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static final  ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  Future<void> shareFile(String filePath, {String? text, Rect? sharePositionOrigin}) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      text: text,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}