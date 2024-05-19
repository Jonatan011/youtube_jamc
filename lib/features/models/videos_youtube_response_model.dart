class MediaListResponse {
  final String kind;
  final String etag;
  final List<MediaItem> items;
  final String nextPageToken;
  final PageInfo pageInfo;

  MediaListResponse({
    required this.kind,
    required this.etag,
    required this.items,
    required this.nextPageToken,
    required this.pageInfo,
  });

  factory MediaListResponse.fromJson(Map<String, dynamic> json) {
    return MediaListResponse(
      kind: json['kind'] ?? '',
      etag: json['etag'] ?? '',
      items: List<MediaItem>.from(json['items'].map((x) => MediaItem.fromJson(x))),
      nextPageToken: json['nextPageToken'] ?? '',
      pageInfo: PageInfo.fromJson(json['pageInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'etag': etag,
        'items': List<dynamic>.from(items.map((x) => x.toJson())),
        'nextPageToken': nextPageToken,
        'pageInfo': pageInfo.toJson(),
      };
}

class MediaItem {
  final String kind;
  final String etag;
  final String id;
  final Snippet snippet;
  final bool isPlaylist;

  MediaItem({
    required this.kind,
    required this.etag,
    required this.id,
    required this.snippet,
    required this.isPlaylist,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    // Determinar si es un video o una lista de reproducción y extraer el ID apropiadamente
    String mediaId = json['id'] is Map ? json['id']['videoId'] ?? json['id']['playlistId'] ?? json['id'] : json['id'];
    bool isPlaylist = json['id'] is Map && json['id'].containsKey('playlistId');
    return MediaItem(
      kind: json['kind'] ?? '',
      etag: json['etag'] ?? '',
      id: mediaId,
      snippet: Snippet.fromJson(json['snippet'] ?? {}),
      isPlaylist: isPlaylist,
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'etag': etag,
        'id': id,
        'snippet': snippet.toJson(),
      };
}

class Snippet {
  final String publishedAt;
  final String channelId;
  final String title;
  final String description;
  final Thumbnails thumbnails;
  final String channelTitle;
  final List<String> tags;
  final String categoryId;
  final String liveBroadcastContent;
  final Localized localized;

  Snippet({
    required this.publishedAt,
    required this.channelId,
    required this.title,
    required this.description,
    required this.thumbnails,
    required this.channelTitle,
    required this.tags,
    required this.categoryId,
    required this.liveBroadcastContent,
    required this.localized,
  });

  factory Snippet.fromJson(Map<String, dynamic> json) => Snippet(
        publishedAt: json['publishedAt'] ?? '',
        channelId: json['channelId'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        thumbnails: Thumbnails.fromJson(json['thumbnails'] ?? {}),
        channelTitle: json['channelTitle'] ?? '',
        tags: json['tags'] != null ? List<String>.from(json['tags'].map((x) => x)) : [],
        categoryId: json['categoryId'] ?? '',
        liveBroadcastContent: json['liveBroadcastContent'] ?? '',
        localized: json['localized'] != null ? Localized.fromJson(json['localized']) : Localized(title: '', description: ''),
      );

  Map<String, dynamic> toJson() => {
        'publishedAt': publishedAt,
        'channelId': channelId,
        'title': title,
        'description': description,
        'thumbnails': thumbnails.toJson(),
        'channelTitle': channelTitle,
        'tags': List<dynamic>.from(tags.map((x) => x)),
        'categoryId': categoryId,
        'liveBroadcastContent': liveBroadcastContent,
        'localized': localized.toJson(),
      };
}

class Thumbnails {
  final Thumbnail defaultThumbnail;
  final Thumbnail medium;
  final Thumbnail high;
  final Thumbnail? standard;
  final Thumbnail? maxres;

  Thumbnails({
    required this.defaultThumbnail,
    required this.medium,
    required this.high,
    this.standard,
    this.maxres,
  });

  factory Thumbnails.fromJson(Map<String, dynamic> json) => Thumbnails(
        defaultThumbnail: Thumbnail.fromJson(json['default'] ?? {}),
        medium: Thumbnail.fromJson(json['medium'] ?? {}),
        high: Thumbnail.fromJson(json['high'] ?? {}),
        standard: json['standard'] != null ? Thumbnail.fromJson(json['standard']) : null,
        maxres: json['maxres'] != null ? Thumbnail.fromJson(json['maxres']) : null,
      );

  Map<String, dynamic> toJson() => {
        'default': defaultThumbnail.toJson(),
        'medium': medium.toJson(),
        'high': high.toJson(),
        'standard': standard?.toJson(),
        'maxres': maxres?.toJson(),
      };
}

class Thumbnail {
  final String url;
  final int width;
  final int height;

  Thumbnail({
    required this.url,
    required this.width,
    required this.height,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) => Thumbnail(
        url: json['url'] ?? 'https://via.placeholder.com/150',
        width: json['width'] ?? 0,
        height: json['height'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'width': width,
        'height': height,
      };
}

class Localized {
  final String title;
  final String description;

  Localized({
    required this.title,
    required this.description,
  });

  factory Localized.fromJson(Map<String, dynamic> json) => Localized(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
      };
}

class PageInfo {
  final int totalResults;
  final int resultsPerPage;

  PageInfo({
    required this.totalResults,
    required this.resultsPerPage,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) => PageInfo(
        totalResults: json['totalResults'] ?? 0,
        resultsPerPage: json['resultsPerPage'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'totalResults': totalResults,
        'resultsPerPage': resultsPerPage,
      };
}
