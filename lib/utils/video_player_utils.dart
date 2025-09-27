/// 视频播放器工具类
class VideoPlayerUtils {
  /// 检查是否为支持的视频格式
  static bool isSupportedVideoFormat(String path) {
    final supportedExtensions = [
      '.mp4',
      '.avi',
      '.mkv',
      '.mov',
      '.wmv',
      '.flv',
      '.webm',
      '.m4v',
      '.3gp',
      '.ts',
      '.m3u8',
    ];
    final lowerPath = path.toLowerCase();
    return supportedExtensions.any((ext) => lowerPath.endsWith(ext));
  }

  static String trackNameTranslation(String id, String title, String language) {
    switch (id) {
      case 'auto':
        return '自动选择';
      case 'no':
        return '禁用';
    }
    var res = '';
    switch (language) {
      case 'chi':
        res = '中文';
        break;
      case 'eng':
        res = '英文';
        break;
      case 'jpn':
        res = '日文';
        break;
      case 'ara':
        res = '阿拉伯语';
        break;
      case 'ger':
        res = '德语';
        break;
      case 'spa':
        res = '西班牙语';
        break;
      case 'fre':
        res = '法语';
        break;
      case 'hin':
        res = '印地语';
        break;
      case 'ind':
        res = '印尼语';
        break;
      case 'ita':
        res = '意大利语';
        break;
      case 'kor':
        res = '韩语';
        break;
      case 'may':
        res = '马来语';
        break;
      case 'dut':
        res = '荷兰语';
        break;
      case 'pol':
        res = '波兰语';
        break;
      default:
        res = language;
    }
    if (title.isNotEmpty) {
      switch (title) {
        case 'Simplified':
          res += '(简体)';
          break;
        case 'Traditional':
          res += '(繁体)';
          break;
        default:
          res += '($title)';
      }
    }
    return res;
  }
}
