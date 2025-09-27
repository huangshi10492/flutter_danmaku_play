enum CollectionType { tvshows, movies, none }

enum MediaType {
  movie('Movie'),
  series('Series'),
  none('none');

  final String name;
  const MediaType(this.name);
}

class CollectionItem {
  final String name;
  final CollectionType type;
  final String id;
  CollectionItem({
    required this.name,
    required this.id,
    this.type = CollectionType.none,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      name: json['Name'],
      id: json['Id'],
      type: CollectionType.values.firstWhere(
        (e) => e.name == json['CollectionType'],
        orElse: () => CollectionType.none,
      ),
    );
  }
}

class MediaItem {
  final String name;
  final String id;
  final MediaType type;
  MediaItem({required this.name, required this.id, this.type = MediaType.none});

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      name: json['Name'],
      id: json['Id'],
      type: MediaType.values.firstWhere(
        (e) => e.name == json['Type'],
        orElse: () => MediaType.none,
      ),
    );
  }
}

class MediaDetail {
  final String id;
  final String name;
  final String? overview;
  final List<String> genres;
  final int? productionYear;
  final int? runTimeTicks;
  final MediaType type;
  final double rating;
  final List<ExternalUrl> externalUrls;
  final List<String> tags;
  List<SeasonInfo> seasons = [];

  MediaDetail({
    required this.id,
    required this.name,
    this.overview,
    this.genres = const [],
    this.productionYear,
    this.runTimeTicks,
    this.type = MediaType.none,
    this.rating = 0,
    this.externalUrls = const [],
    this.tags = const [],
  });

  factory MediaDetail.fromJson(Map<String, dynamic> json) {
    double priceAsDouble(dynamic value) {
      if (value is int) {
        return (value).toDouble();
      }
      return value as double;
    }

    return MediaDetail(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
      overview: json['Overview'],
      genres: (json['Genres'] as List?)?.cast<String>() ?? [],
      productionYear: json['ProductionYear'],
      runTimeTicks: json['RunTimeTicks'],
      type: MediaType.values.firstWhere(
        (e) => e.name == json['Type'],
        orElse: () => MediaType.none,
      ),
      rating: priceAsDouble(json['CommunityRating'] ?? 0.0),
      externalUrls: List<ExternalUrl>.from(
        json['ExternalUrls'].map((x) => ExternalUrl.fromJson(x)),
      ),
      tags: List<String>.from(json["Tags"].map((x) => x)),
    );
  }

  String? get formattedRuntime {
    if (runTimeTicks == null) return null;
    final minutes = (runTimeTicks! / 10000000 / 60).round();
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) {
      return '$hours小时$remainingMinutes分钟';
    }
    return '$remainingMinutes分钟';
  }
}

class ExternalUrl {
  String name;
  String url;

  ExternalUrl({required this.name, required this.url});

  factory ExternalUrl.fromJson(Map<String, dynamic> json) =>
      ExternalUrl(name: json["Name"], url: json["Url"]);
}

class SeasonInfo {
  final String id;
  final String name;
  final int? indexNumber;
  final List<EpisodeInfo> episodes;

  SeasonInfo({
    required this.id,
    required this.name,
    this.indexNumber,
    this.episodes = const [],
  });

  factory SeasonInfo.fromJson(Map<String, dynamic> json) {
    return SeasonInfo(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
      indexNumber: json['IndexNumber'],
    );
  }
}

class EpisodeInfo {
  final String id;
  final String name;
  final int? indexNumber;
  final String? seriesName;
  final String? overview;
  final int? runTimeTicks;

  EpisodeInfo({
    required this.id,
    required this.name,
    this.indexNumber,
    this.seriesName,
    this.overview,
    this.runTimeTicks,
  });

  factory EpisodeInfo.fromJson(Map<String, dynamic> json) {
    return EpisodeInfo(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
      indexNumber: json['IndexNumber'],
      seriesName: json['SeriesName'],
      overview: json['Overview'],
      runTimeTicks: json['RunTimeTicks'],
    );
  }

  String? get formattedRuntime {
    if (runTimeTicks == null) return null;
    final minutes = (runTimeTicks! / 10000000 / 60).round();
    return '$minutes分钟';
  }
}
