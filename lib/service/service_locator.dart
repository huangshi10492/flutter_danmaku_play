import 'package:fldanplay/service/configure.dart';
import 'package:fldanplay/service/file_explorer.dart';
import 'package:fldanplay/service/history.dart';
import 'package:fldanplay/service/storage.dart';
import 'package:fldanplay/service/global.dart';
import 'package:fldanplay/service/stream_media_explorer.dart';
import 'package:fldanplay/service/webdav_sync.dart';
import 'package:fldanplay/service/logger.dart';

class ServiceLocator {
  static Future<void> initialize() async {
    ConfigureService cs = await ConfigureService.register();
    await LoggerService.register(cs);
    await StorageService.register();
    await GlobalService.register();
    FileExplorerService.register();
    StreamMediaExplorerService.register();
    HistoryService hs = await HistoryService.register();
    await WebDAVSyncService.register(cs, hs);
  }
}
