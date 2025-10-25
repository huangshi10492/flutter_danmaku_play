import 'package:dio/dio.dart';
import 'package:fldanplay/model/history.dart';
import 'package:fldanplay/model/storage.dart';
import 'package:fldanplay/model/stream_media.dart';
import 'package:fldanplay/model/video_info.dart';
import 'package:fldanplay/service/global.dart';
import 'package:fldanplay/utils/log.dart';
import 'package:get_it/get_it.dart';
import 'package:signals_flutter/signals_flutter.dart';

abstract class StreamMediaExplorerProvider {
  Dio getDio(String url, {UserInfo? userInfo});
  Future<UserInfo> login(Dio dio, String username, String password);
  Future<List<CollectionItem>> getUserViews();
  Future<List<MediaItem>> getItems(String parentId, {required Filter filter});
  Future<MediaDetail> getMediaDetail(String itemId);
  Map<String, String> get headers;
  String getImageUrl(String itemId, {String tag = 'Primary'});
  String getStreamUrl(String itemId);
  Future<bool> downloadVideo(
    String itemId,
    String localPath, {
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  });
  void dispose();
}

class Filter {
  String searchTerm = '';
  String years = '';
  String seriesStatus = '';
  String sortBy = 'SortName';
  // true: 升序，false: 降序
  bool sortOrder = true;
  Filter();

  bool isFiltered() {
    return searchTerm.isNotEmpty ||
        years.isNotEmpty ||
        seriesStatus.isNotEmpty ||
        sortBy != 'SortName' ||
        sortOrder != true;
  }
}

class StreamMediaExplorerService {
  late StreamMediaExplorerProvider provider;
  late String libraryId;
  Storage? storage;
  List<EpisodeInfo> episodeList = [];
  final _logger = Logger('StreamMediaExplorerService');
  final Signal<Filter> filter = signal(Filter());

  late FutureSignal<List<MediaItem>> items = futureSignal(() async {
    try {
      return await provider.getItems(libraryId, filter: filter.value);
    } catch (e) {
      throw Exception(e);
    }
  }, dependencies: [filter]);

  static void register() {
    final service = StreamMediaExplorerService();
    GetIt.I.registerSingleton<StreamMediaExplorerService>(service);
  }

  void setProvider(StreamMediaExplorerProvider newProvider, Storage storage) {
    filter.value = Filter();
    this.storage = storage;
    provider = newProvider;
    libraryId = storage.mediaLibraryId!;
    items.refresh();
    _logger.info('setProvider', '设置新的媒体库提供者');
  }

  void setVideoList(SeasonInfo seasonInfo) {
    episodeList = seasonInfo.episodes;
  }

  VideoInfo getVideoInfo(int index) {
    final episode = episodeList[index];
    final playbackUrl = getPlaybackUrl(episode.id);
    return VideoInfo(
      currentVideoPath: playbackUrl,
      virtualVideoPath: episode.id,
      historiesType: HistoriesType.streamMediaStorage,
      storageKey: storage!.uniqueKey,
      name: episode.name,
      videoName: '${episode.seriesName} ${episode.indexNumber}',
      subtitle: '${episode.seriesName} ${episode.indexNumber}',
      listLength: episodeList.length,
      videoIndex: index,
      canSwitch: true,
    );
  }

  VideoInfo getVideoInfoFromHistory(History history) {
    final playbackUrl = getPlaybackUrl(history.url!);
    return VideoInfo(
      currentVideoPath: playbackUrl,
      virtualVideoPath: history.url!,
      historiesType: HistoriesType.streamMediaStorage,
      storageKey: storage!.uniqueKey,
      name: history.name,
      videoName: history.name,
      subtitle: history.subtitle,
    );
  }

  String getImageUrl(String itemId, {String tag = 'Primary'}) {
    return provider.getImageUrl(itemId, tag: tag);
  }

  String getPlaybackUrl(String itemId) {
    return provider.getStreamUrl(itemId);
  }

  Future<MediaDetail> getMediaDetail(String itemId) async {
    return provider.getMediaDetail(itemId);
  }
}

class JellyfinStreamMediaExplorerProvider
    implements StreamMediaExplorerProvider {
  final String url;
  final UserInfo userInfo;
  late String auth;
  late Dio dio;
  late final Logger _logger = Logger('JellyfinStreamMediaExplorerProvider');

  JellyfinStreamMediaExplorerProvider(this.url, this.userInfo) {
    final globalService = GetIt.I.get<GlobalService>();
    auth =
        'MediaBrowser Client="fldanplay", Device="${globalService.device}", DeviceId="${globalService.deviceId}", Version="0.0.1", Token="${userInfo.token}"';
    dio = getDio(url, userInfo: userInfo);
  }

  @override
  Map<String, String> get headers => {'Authorization': auth};

  @override
  Future<List<MediaItem>> getItems(
    String parentId, {
    required Filter filter,
  }) async {
    try {
      final params = <String, dynamic>{
        'parentId': parentId,
        'limit': 300,
        'recursive': true,
        'searchTerm': filter.searchTerm,
        'includeItemTypes': 'Movie,Series',
        'sortBy': filter.sortBy,
        'years': filter.years,
        'sortOrder': filter.sortOrder ? 'Ascending' : 'Descending',
        'seriesStatus': filter.seriesStatus,
        'imageTypeLimit': '1',
        'enableImageTypes': 'Primary',
      };
      final response = await dio.get('/Items', queryParameters: params);
      List<MediaItem> res = [];
      for (var item in response.data['Items']) {
        res.add(MediaItem.fromJson(item));
      }
      return res;
    } on DioException catch (e) {
      _logger.error('getItems', '获取失败', error: e);
      throw Exception('获取失败: ${e.message}');
    } catch (e) {
      _logger.error('getItems', '获取失败', error: e);
      throw Exception('获取失败: ${e.toString()}');
    }
  }

  @override
  String getImageUrl(String itemId, {String tag = 'Primary'}) {
    return '$url/Items/$itemId/Images/$tag';
  }

  @override
  String getStreamUrl(String itemId) {
    return '$url/Videos/$itemId/stream?static=true';
  }

  @override
  Future<MediaDetail> getMediaDetail(String itemId) async {
    try {
      final response = await dio.get('/Items/$itemId');
      final detail = MediaDetail.fromJson(response.data);

      // 如果是系列，获取季度信息
      if (detail.type == MediaType.series) {
        detail.seasons = await getSeasons(dio, itemId);
      }
      if (detail.type == MediaType.movie) {
        detail.seasons = [
          SeasonInfo(
            id: detail.id,
            name: detail.name,
            episodes: [
              EpisodeInfo(
                id: detail.id,
                name: detail.name,
                indexNumber: 0,
                seriesName: detail.name,
                runTimeTicks: detail.runTimeTicks,
              ),
            ],
          ),
        ];
      }

      return detail;
    } on DioException catch (e) {
      _logger.error('getMediaDetail', '获取失败', error: e);
      throw Exception('获取媒体详情失败: ${e.message}');
    } catch (e) {
      _logger.error('getMediaDetail', '获取失败', error: e);
      throw Exception('获取媒体详情失败: ${e.toString()}');
    }
  }

  @override
  Dio getDio(String url, {UserInfo? userInfo}) {
    final globalService = GetIt.I.get<GlobalService>();
    String auth =
        'MediaBrowser Client="fldanplay", Device="${globalService.device}", DeviceId="${globalService.deviceId}", Version="0.0.1"';
    if (userInfo != null) {
      auth += ', Token="${userInfo.token}"';
    }
    return Dio(BaseOptions(baseUrl: url, headers: {'Authorization': auth}));
  }

  @override
  Future<UserInfo> login(Dio dio, String username, String password) async {
    try {
      final response = await dio.post(
        '/Users/AuthenticateByName',
        data: {'Username': username, 'Pw': password},
      );
      return UserInfo.fromJson(response.data);
    } on DioException catch (e) {
      _logger.error('login', '登录失败', error: e);
      throw Exception('登录失败: ${e.message}');
    } catch (e) {
      _logger.error('login', '登录失败', error: e);
      throw Exception('登录失败: ${e.toString()}');
    }
  }

  @override
  Future<List<CollectionItem>> getUserViews() async {
    try {
      final response = await dio.get('/UserViews');
      List<CollectionItem> res = [];
      for (var item in response.data['Items']) {
        res.add(CollectionItem.fromJson(item));
      }
      return res;
    } on DioException catch (e) {
      _logger.error('getUserViews', '获取用户视图失败', error: e);
      throw Exception('获取用户视图失败: ${e.message}');
    } catch (e) {
      _logger.error('getUserViews', '获取用户视图失败', error: e);
      throw Exception('获取用户视图失败: ${e.toString()}');
    }
  }

  Future<List<SeasonInfo>> getSeasons(Dio dio, String seriesId) async {
    try {
      final response = await dio.get(
        '/Items',
        queryParameters: {'parentId': seriesId},
      );

      List<SeasonInfo> seasons = [];
      for (var item in response.data['Items']) {
        final season = SeasonInfo.fromJson(item);
        final episodes = await getEpisodes(dio, season.id);
        seasons.add(
          SeasonInfo(
            id: season.id,
            name: season.name,
            indexNumber: season.indexNumber,
            episodes: episodes,
          ),
        );
      }

      // 按季度编号排序
      seasons.sort(
        (a, b) => (a.indexNumber ?? 0).compareTo(b.indexNumber ?? 0),
      );
      return seasons;
    } on DioException catch (e) {
      _logger.error('getSeasons', '获取季度信息失败', error: e);
      throw Exception('获取季度信息失败: ${e.message}');
    } catch (e) {
      _logger.error('getSeasons', '获取季度信息失败', error: e);
      throw Exception('获取季度信息失败: ${e.toString()}');
    }
  }

  Future<List<EpisodeInfo>> getEpisodes(Dio dio, String seasonId) async {
    try {
      final response = await dio.get(
        '/Items',
        queryParameters: {'parentId': seasonId},
      );

      List<EpisodeInfo> episodes = [];
      for (var item in response.data['Items']) {
        episodes.add(EpisodeInfo.fromJson(item));
      }

      // 按集数编号排序
      episodes.sort(
        (a, b) => (a.indexNumber ?? 0).compareTo(b.indexNumber ?? 0),
      );
      return episodes;
    } on DioException catch (e) {
      _logger.error('getEpisodes', '获取集数信息失败', error: e);
      throw Exception('获取集数信息失败: ${e.message}');
    } catch (e) {
      _logger.error('getEpisodes', '获取集数信息失败', error: e);
      throw Exception('获取集数信息失败: ${e.toString()}');
    }
  }

  @override
  Future<bool> downloadVideo(
    String itemId,
    String localPath, {
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final streamUrl = getStreamUrl(itemId);
      await dio.download(
        streamUrl,
        localPath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
      );
      _logger.info('downloadVideo', 'Jellyfin下载完成: $itemId -> $localPath');
      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return false;
      }
      _logger.error('downloadVideo', 'Jellyfin下载失败: $e');
      rethrow;
    } catch (e) {
      _logger.error('downloadVideo', 'Jellyfin下载失败: $e');
      rethrow;
    }
  }

  @override
  void dispose() {}
}

class EmbyStreamMediaExplorerProvider implements StreamMediaExplorerProvider {
  final String url;
  final UserInfo userInfo;
  late String auth;
  late Dio dio;
  late final Logger _logger = Logger('EmbyStreamMediaExplorerProvider');

  EmbyStreamMediaExplorerProvider(this.url, this.userInfo) {
    final globalService = GetIt.I.get<GlobalService>();
    auth =
        'Emby Client="fldanplay", Device="${globalService.device}", DeviceId="${globalService.deviceId}", Version="0.0.1", Token="${userInfo.token}"';
    dio = getDio(url, userInfo: userInfo);
  }

  @override
  Map<String, String> get headers => {'X-Emby-Authorization': auth};

  @override
  Future<List<MediaItem>> getItems(
    String parentId, {
    required Filter filter,
  }) async {
    try {
      final params = <String, dynamic>{
        'parentId': parentId,
        'limit': 300,
        'recursive': true,
        'searchTerm': filter.searchTerm,
        'includeItemTypes': 'Movie,Series',
        'sortBy': filter.sortBy,
        'years': filter.years,
        'sortOrder': filter.sortOrder ? 'Ascending' : 'Descending',
        'seriesStatus': filter.seriesStatus,
        'imageTypeLimit': '1',
        'enableImageTypes': 'Primary',
      };
      final response = await dio.get('/Items', queryParameters: params);
      List<MediaItem> res = [];
      for (var item in response.data['Items']) {
        res.add(MediaItem.fromJson(item));
      }
      return res;
    } on DioException catch (e) {
      _logger.error('getItems', '获取失败', error: e);
      throw Exception('获取失败: ${e.message}');
    } catch (e) {
      _logger.error('getItems', '获取失败', error: e);
      throw Exception('获取失败: ${e.toString()}');
    }
  }

  @override
  String getImageUrl(String itemId, {String tag = 'Primary'}) {
    return '$url/Items/$itemId/Images/$tag';
  }

  @override
  String getStreamUrl(String itemId) {
    return '$url/Videos/$itemId/stream?static=true&api_key=${userInfo.token}';
  }

  @override
  Future<MediaDetail> getMediaDetail(String itemId) async {
    try {
      final response = await dio.get('/Users/${userInfo.userId}/Items/$itemId');
      final detail = MediaDetail.fromJson(response.data);

      // 如果是系列，获取季度信息
      if (detail.type == MediaType.series) {
        detail.seasons = await getSeasons(dio, itemId);
      }
      if (detail.type == MediaType.movie) {
        detail.seasons = [
          SeasonInfo(
            id: detail.id,
            name: detail.name,
            episodes: [
              EpisodeInfo(
                id: detail.id,
                name: detail.name,
                indexNumber: 0,
                seriesName: detail.name,
                runTimeTicks: detail.runTimeTicks,
              ),
            ],
          ),
        ];
      }

      return detail;
    } on DioException catch (e) {
      _logger.error('getMediaDetail', '获取失败', error: e);
      throw Exception('获取媒体详情失败: ${e.message}');
    } catch (e) {
      _logger.error('getMediaDetail', '获取失败', error: e);
      throw Exception('获取媒体详情失败: ${e.toString()}');
    }
  }

  @override
  Dio getDio(String url, {UserInfo? userInfo}) {
    final globalService = GetIt.I.get<GlobalService>();
    String auth =
        'Emby Client="fldanplay", Device="${globalService.device}", DeviceId="${globalService.deviceId}", Version="0.0.1"';
    if (userInfo != null) {
      auth += ', Token="${userInfo.token}"';
    }
    return Dio(
      BaseOptions(baseUrl: url, headers: {'X-Emby-Authorization': auth}),
    );
  }

  @override
  Future<UserInfo> login(Dio dio, String username, String password) async {
    try {
      final response = await dio.post(
        '/Users/AuthenticateByName',
        data: {'Username': username, 'Pw': password},
      );
      return UserInfo.fromJson(response.data);
    } on DioException catch (e) {
      _logger.error('login', '登录失败', error: e);
      throw Exception('登录失败: ${e.message}');
    } catch (e) {
      _logger.error('login', '登录失败', error: e);
      throw Exception('登录失败: ${e.toString()}');
    }
  }

  @override
  Future<List<CollectionItem>> getUserViews() async {
    try {
      final response = await dio.get('/Users/${userInfo.userId}/Views');
      List<CollectionItem> res = [];
      for (var item in response.data['Items']) {
        res.add(CollectionItem.fromJson(item));
      }
      return res;
    } on DioException catch (e) {
      _logger.error('getUserViews', '获取用户视图失败', error: e);
      throw Exception('获取用户视图失败: ${e.message}');
    } catch (e) {
      _logger.error('getUserViews', '获取用户视图失败', error: e);
      throw Exception('获取用户视图失败: ${e.toString()}');
    }
  }

  Future<List<SeasonInfo>> getSeasons(Dio dio, String seriesId) async {
    try {
      final response = await dio.get(
        '/Items',
        queryParameters: {'parentId': seriesId},
      );

      List<SeasonInfo> seasons = [];
      for (var item in response.data['Items']) {
        final season = SeasonInfo.fromJson(item);
        final episodes = await getEpisodes(dio, season.id);
        seasons.add(
          SeasonInfo(
            id: season.id,
            name: season.name,
            indexNumber: season.indexNumber,
            episodes: episodes,
          ),
        );
      }

      // 按季度编号排序
      seasons.sort(
        (a, b) => (a.indexNumber ?? 0).compareTo(b.indexNumber ?? 0),
      );
      return seasons;
    } on DioException catch (e) {
      _logger.error('getSeasons', '获取季度信息失败', error: e);
      throw Exception('获取季度信息失败: ${e.message}');
    } catch (e) {
      _logger.error('getSeasons', '获取季度信息失败', error: e);
      throw Exception('获取季度信息失败: ${e.toString()}');
    }
  }

  Future<List<EpisodeInfo>> getEpisodes(Dio dio, String seasonId) async {
    try {
      final response = await dio.get(
        '/Items',
        queryParameters: {'parentId': seasonId},
      );

      List<EpisodeInfo> episodes = [];
      for (var item in response.data['Items']) {
        episodes.add(EpisodeInfo.fromJson(item));
      }

      // 按集数编号排序
      episodes.sort(
        (a, b) => (a.indexNumber ?? 0).compareTo(b.indexNumber ?? 0),
      );
      return episodes;
    } on DioException catch (e) {
      _logger.error('getEpisodes', '获取集数信息失败', error: e);
      throw Exception('获取集数信息失败: ${e.message}');
    } catch (e) {
      _logger.error('getEpisodes', '获取集数信息失败', error: e);
      throw Exception('获取集数信息失败: ${e.toString()}');
    }
  }

  @override
  Future<bool> downloadVideo(
    String itemId,
    String localPath, {
    int startFrom = 0,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final streamUrl = getStreamUrl(itemId);
      await dio.download(
        streamUrl,
        localPath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
      );
      _logger.info('downloadVideo', 'Emby下载完成: $itemId -> $localPath');
      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return false;
      }
      _logger.error('downloadVideo', 'Emby下载失败: $e');
      rethrow;
    } catch (e) {
      _logger.error('downloadVideo', 'Emby下载失败: $e');
      rethrow;
    }
  }

  @override
  void dispose() {}
}
