import 'package:youtube_jamc/features/models/videos_youtube_response_model.dart';

class PlaylistItemListResponse {
  final String kind;
  final String etag;
  final List<PlaylistItem> items;
  final String nextPageToken;
  final PageInfo pageInfo;

  PlaylistItemListResponse({
    required this.kind,
    required this.etag,
    required this.items,
    required this.nextPageToken,
    required this.pageInfo,
  });

  factory PlaylistItemListResponse.fromJson(Map<String, dynamic> json) {
    return PlaylistItemListResponse(
      kind: json['kind'] ?? '',
      etag: json['etag'] ?? '',
      items: List<PlaylistItem>.from(json['items'].map((x) => PlaylistItem.fromJson(x))),
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

class PlaylistItem {
  final String kind;
  final String etag;
  final String id;
  final Snippet snippet;
  final ContentDetails contentDetails;
  final bool isPlaylist;

  PlaylistItem({
    required this.kind,
    required this.etag,
    required this.id,
    required this.snippet,
    required this.contentDetails,
    required this.isPlaylist,
  });

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
    bool isPlaylist = json['contentDetails'] != null && json['contentDetails']['videoId'] == null;
    return PlaylistItem(
      kind: json['kind'] ?? '',
      etag: json['etag'] ?? '',
      id: json['id'] ?? '',
      snippet: Snippet.fromJson(json['snippet'] ?? {}),
      contentDetails: ContentDetails.fromJson(json['contentDetails'] ?? {}),
      isPlaylist: isPlaylist,
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'etag': etag,
        'id': id,
        'snippet': snippet.toJson(),
        'contentDetails': contentDetails.toJson(),
      };
}

class ContentDetails {
  final String? videoId;
  final String? videoPublishedAt;

  ContentDetails({
    this.videoId,
    this.videoPublishedAt,
  });

  factory ContentDetails.fromJson(Map<String, dynamic> json) {
    return ContentDetails(
      videoId: json['videoId'],
      videoPublishedAt: json['videoPublishedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'videoPublishedAt': videoPublishedAt,
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
