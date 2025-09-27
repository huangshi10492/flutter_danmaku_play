import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:fldanplay/utils/log.dart';
import 'package:fldanplay/model/danmaku.dart';

/// 弹弹play API工具类
class DanmakuApiUtils {
  final String baseUrl;
  DanmakuApiUtils(this.baseUrl);

  Dio get _dio {
    final log = Logger('DanmakuApiUtils');
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: (message) => log.info('DioRetryInterceptor', message),
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );
    return dio;
  }

  /// 文件识别 - 根据文件信息匹配节目
  Future<List<Episode>> matchVideo({
    required String fileName,
    String fileHash = '',
    bool hash = false,
  }) async {
    const path = '/api/v2/match';
    try {
      final response = await _dio.post(
        path,
        data:
            hash
                ? {
                  'fileHash': fileHash,
                  'fileName': fileName,
                  'matchModel': 'hashAndFileName',
                }
                : {'fileName': fileName, 'matchModel': 'fileNameOnly'},
      );
      final matches = response.data['matches'] as List;
      return matches.map((match) => Episode.fromJson(match)).toList();
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    }
  }

  /// 搜索节目
  Future<List<Episode>> searchAnime(String keyword) async {
    const path = '/api/v2/search/episodes';
    try {
      final response = await _dio.get(
        path,
        queryParameters: {'anime': keyword},
      );
      final animes = response.data['animes'] as List;
      final episodes = <Episode>[];
      for (final anime in animes) {
        final episodeList = anime['episodes'] as List;
        episodes.addAll(
          episodeList.map(
            (ep) =>
                Episode.fromJson({...ep, 'animeTitle': anime['animeTitle']}),
          ),
        );
      }
      return episodes;
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    }
  }

  /// 搜索番剧集数
  Future<List<Anime>> searchEpisodes(String name) async {
    const path = '/api/v2/search/episodes';
    try {
      final queryParameters = <String, dynamic>{'anime': name};
      final response = await _dio.get(path, queryParameters: queryParameters);
      final animes = <Anime>[];
      // 遍历所有番剧，收集所有集数
      for (final anime in response.data['animes'] as List) {
        animes.add(Anime.fromJson(anime));
      }
      return animes;
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    }
  }

  /// 获取弹幕
  Future<List<DanmakuComment>> getComments(
    int episodeId, {
    bool withRelated = true,
    int sc = 1, // 中文简繁转换。0-不转换，1-转换为简体，2-转换为繁体。
  }) async {
    final path = '/api/v2/comment/$episodeId';
    try {
      final response = await _dio.get(
        path,
        queryParameters: {
          if (withRelated) 'withRelated': 'true',
          'chConvert': sc,
        },
      );
      final comments = response.data['comments'] as List;
      return comments
          .map((comment) => DanmakuComment.fromJson(comment))
          .toList();
    } on DioException catch (e) {
      throw Exception('网络请求失败: ${e.message}');
    }
  }
}
