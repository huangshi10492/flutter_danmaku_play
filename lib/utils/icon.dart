// .icon-jellyfin:before { content: "\e900"; }
// .icon-emby:before { content: "\e901"; }
// .icon-bilibili:before { content: "\e902"; }
// .icon-ftp:before { content: "\e903"; }
// .icon-smb:before { content: "\e904"; }
// .icon-bahamut:before { content: "\e905"; }
// .icon-dandanplay:before { content: "\e906"; }
import 'package:flutter/material.dart';

class MyIcon {
  static const String _family = 'IconFont';
  const MyIcon._();
  static const IconData jellyfin = IconData(0xe900, fontFamily: _family);
  static const IconData emby = IconData(0xe901, fontFamily: _family);
  static const IconData bilibili = IconData(0xe902, fontFamily: _family);
  static const IconData ftp = IconData(0xe903, fontFamily: _family);
  static const IconData smb = IconData(0xe904, fontFamily: _family);
  static const IconData bahamut = IconData(0xe905, fontFamily: _family);
  static const IconData dandanplay = IconData(0xe906, fontFamily: _family);
}
