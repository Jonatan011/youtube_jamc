import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_jamc/features/models/videos_youtube_response_model.dart';

class HomeController extends GetxController {
  var accessToken = ''.obs;
  var nextPageToken = ''.obs;
  RxBool isLoading = false.obs;
  var isSearching = false.obs;
  var searchQuery = ''.obs;
  RxBool saveload = false.obs;
  RxBool isPlayerMinimized = false.obs;
  RxBool isPlayerFinish = false.obs;
  RxList<String> videoIds = <String>[].obs;

  final Rx<DraggableScrollableController> controllerDraggable = DraggableScrollableController().obs;
  Rx<MediaListResponse> videos = MediaListResponse(
      kind: "",
      etag: "",
      items: [],
      nextPageToken: "",
      pageInfo: PageInfo(
        totalResults: 10,
        resultsPerPage: 0,
      )).obs;

  Rx<MediaListResponse> playList = MediaListResponse(
      kind: "",
      etag: "",
      items: [],
      nextPageToken: "",
      pageInfo: PageInfo(
        totalResults: 10,
        resultsPerPage: 0,
      )).obs;

  @override
  void onInit() {
    super.onInit();
    fetchYouTubeMusic();
  }

  @override
  void dispose() {
    controllerDraggable.value.dispose();
    super.dispose();
  }

  void toggleSearch() {
    if (isSearching.value) {
      clearSearch();
    }
    isSearching.value = !isSearching.value;
  }

  void isPlayerMinimizedOrMaximixed(bool value) {
    isPlayerMinimized.value = value;
    if (isPlayerMinimized.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controllerDraggable.value.animateTo(0.08, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controllerDraggable.value.animateTo(1.0, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      });
    }
  }

  onchangeVideosId(List<String> list) {
    videoIds.value = list;
    isPlayerMinimizedOrMaximixed(false);
  }

  void clearSearch() {
    searchQuery.value = '';
    videos.value = MediaListResponse(
        kind: "",
        etag: "",
        items: [],
        nextPageToken: "",
        pageInfo: PageInfo(
          totalResults: 10,
          resultsPerPage: 0,
        )); // Limpia los resultados previos
    nextPageToken.value = ''; // Reinicia el token de página
    searchQuery.value = '';
    fetchYouTubeMusic();
  }

  Future<void> searchYouTubeVideos(String query, {String pageToken = ''}) async {
    if (isLoading.value) {
      return; // Evita ejecuciones concurrentes
    }

    if (query.isEmpty) {
      clearSearch();
      return;
    }
    isLoading.value = true;
    searchQuery.value = query;

    final prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';

    if (accessToken.isEmpty) {
      await refreshToken();
      accessToken = prefs.getString('accessToken') ?? '';
      if (accessToken.isEmpty) {
        isLoading.value = false;
        return;
      }
    }

    // Intenta obtener datos del caché
    String cacheKey = 'search_$query';
    String? cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      var videoData = jsonDecode(cachedData);
      videos.value = MediaListResponse.fromJson(videoData);
      isLoading.value = false;
      return;
    }

    try {
      String baseURL = 'https://www.googleapis.com/youtube/v3/search';
      String videoQueryParams = 'part=snippet&maxResults=25&type=video&videoCategoryId=10&q=$query';
      String playlistQueryParams = 'part=snippet&maxResults=25&type=playlist&q=$query';
      if (pageToken.isNotEmpty) {
        videoQueryParams += '&pageToken=$pageToken';
        playlistQueryParams += '&pageToken=$pageToken';
      }

      final videoResponse = await http.get(
        Uri.parse('$baseURL?$videoQueryParams'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      final playlistResponse = await http.get(
        Uri.parse('$baseURL?$playlistQueryParams'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print('Video response status: ${videoResponse.statusCode}');
      print('Video response body: ${videoResponse.body}');
      print('Playlist response status: ${playlistResponse.statusCode}');
      print('Playlist response body: ${playlistResponse.body}');

      if (videoResponse.statusCode == 200 && playlistResponse.statusCode == 200) {
        var videoData = jsonDecode(videoResponse.body);
        var playlistData = jsonDecode(playlistResponse.body);

        List<MediaItem> videoItems = (videoData['items'] as List).map((i) => MediaItem.fromJson(i)).toList();
        List<MediaItem> playlistItems = (playlistData['items'] as List).map((i) => MediaItem.fromJson(i)).toList();

        // Intercalar videos y listas de reproducción
        List<MediaItem> combinedItems = [];
        int maxLength = videoItems.length > playlistItems.length ? videoItems.length : playlistItems.length;
        for (int i = 0; i < maxLength; i++) {
          if (i < videoItems.length) combinedItems.add(videoItems[i]);
          if (i < playlistItems.length) combinedItems.add(playlistItems[i]);
        }

        MediaListResponse newCombinedList = MediaListResponse(
          kind: videoData['kind'] ?? '',
          etag: videoData['etag'] ?? '',
          nextPageToken: videoData['nextPageToken'] ?? '',
          pageInfo: PageInfo.fromJson(videoData['pageInfo'] ?? {}),
          items: combinedItems,
        );

        // Guarda la respuesta en caché
        prefs.setString(cacheKey, jsonEncode(videoData));

        if (pageToken.isEmpty) {
          videos.value = newCombinedList;
        } else {
          videos.value.items.addAll(newCombinedList.items);
        }
        nextPageToken.value = videoData['nextPageToken'] ?? '';
        saveload.value = !saveload.value;
      } else if (videoResponse.statusCode == 401 || playlistResponse.statusCode == 401) {
        await refreshToken();
        return searchYouTubeVideos(query, pageToken: pageToken); // Intenta de nuevo con un token fresco
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (error) {
      print('Error: $error');
      Get.snackbar('Error', 'Failed to fetch YouTube videos and playlists: $error');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchYouTubeMusic({String pageToken = ''}) async {
    if (isLoading.value) {
      return; // Evita ejecuciones concurrentes
    }

    isLoading.value = true;

    final prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';

    if (accessToken.isEmpty) {
      await refreshToken();
      accessToken = prefs.getString('accessToken') ?? '';
      if (accessToken.isEmpty) {
        isLoading.value = false;
        return;
      }
    }

    // Intenta obtener datos del caché
    String cacheKey = 'music_videos';
    String? cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      var videoData = jsonDecode(cachedData);
      videos.value = MediaListResponse.fromJson(videoData);
      isLoading.value = false;
      return;
    }

    try {
      // Obtener videos de música recomendados
      String musicVideosURL = 'https://www.googleapis.com/youtube/v3/search';
      String videoQueryParams = 'part=snippet&maxResults=25&type=video&videoCategoryId=10&order=relevance';
      String playlistQueryParams = 'part=snippet&maxResults=25&type=playlist&order=relevance&q=music';
      if (pageToken.isNotEmpty) {
        videoQueryParams += '&pageToken=$pageToken';
        playlistQueryParams += '&pageToken=$pageToken';
      }

      final videoResponse = await http.get(
        Uri.parse('$musicVideosURL?$videoQueryParams'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      final playlistResponse = await http.get(
        Uri.parse('$musicVideosURL?$playlistQueryParams'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print('Music video response status: ${videoResponse.statusCode}');
      print('Music video response body: ${videoResponse.body}');
      print('Playlist response status: ${playlistResponse.statusCode}');
      print('Playlist response body: ${playlistResponse.body}');

      if (videoResponse.statusCode == 200 && playlistResponse.statusCode == 200) {
        var videoData = jsonDecode(videoResponse.body);
        var playlistData = jsonDecode(playlistResponse.body);

        List<MediaItem> videoItems = (videoData['items'] as List).map((i) => MediaItem.fromJson(i)).toList();
        List<MediaItem> playlistItems = (playlistData['items'] as List).map((i) => MediaItem.fromJson(i)).toList();

        // Intercalar videos y listas de reproducción
        List<MediaItem> combinedItems = [];
        int maxLength = videoItems.length > playlistItems.length ? videoItems.length : playlistItems.length;
        for (int i = 0; i < maxLength; i++) {
          if (i < videoItems.length) combinedItems.add(videoItems[i]);
          if (i < playlistItems.length) combinedItems.add(playlistItems[i]);
        }

        MediaListResponse newCombinedList = MediaListResponse(
          kind: videoData['kind'] ?? '',
          etag: videoData['etag'] ?? '',
          nextPageToken: videoData['nextPageToken'] ?? '',
          pageInfo: PageInfo.fromJson(videoData['pageInfo'] ?? {}),
          items: combinedItems,
        );

        // Guarda la respuesta en caché
        prefs.setString(cacheKey, jsonEncode(videoData));

        if (pageToken.isEmpty) {
          videos.value = newCombinedList;
        } else {
          videos.value.items.addAll(newCombinedList.items);
        }
        nextPageToken.value = videoData['nextPageToken'] ?? '';
        saveload.value = !saveload.value;
      } else if (videoResponse.statusCode == 401 || playlistResponse.statusCode == 401) {
        await refreshToken();
        return fetchYouTubeMusic(pageToken: pageToken); // Intenta de nuevo con un token fresco
      } else {
        throw Exception('Failed to load music videos and playlists');
      }
    } catch (error) {
      print('Error: $error');
      Get.snackbar('Error', 'Failed to fetch YouTube music videos and playlists: $error');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPlaylistItems(String playlistId, {String pageToken = ''}) async {
    videos.value = MediaListResponse(
        kind: "",
        etag: "",
        items: [],
        nextPageToken: "",
        pageInfo: PageInfo(
          totalResults: 10,
          resultsPerPage: 0,
        ));
    videoIds.value = [];
    if (isLoading.value) {
      return; // Evita ejecuciones concurrentes
    }

    isLoading.value = true;

    final prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';

    if (accessToken.isEmpty) {
      await refreshToken();
      accessToken = prefs.getString('accessToken') ?? '';
      if (accessToken.isEmpty) {
        isLoading.value = false;
        return;
      }
    }

    try {
      String playlistItemsURL = 'https://www.googleapis.com/youtube/v3/playlistItems';
      String queryParams = 'part=snippet&maxResults=25&playlistId=$playlistId';
      if (pageToken.isNotEmpty) {
        queryParams += '&pageToken=$pageToken';
      }

      final response = await http.get(
        Uri.parse('$playlistItemsURL?$queryParams'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        MediaListResponse playlistItems = MediaListResponse.fromJson(data);

        if (pageToken.isEmpty) {
          videos.value = playlistItems;
        } else {
          videos.value.items.addAll(playlistItems.items);
        }
        nextPageToken.value = data['nextPageToken'] ?? '';
        saveload.value = !saveload.value;
      } else if (response.statusCode == 401) {
        await refreshToken();
        return fetchPlaylistItems(playlistId, pageToken: nextPageToken.value); // Intenta de nuevo con un token fresco
      } else {
        throw Exception('Failed to load playlist items');
      }
    } catch (error) {
      Get.snackbar('Error', 'Failed to fetch YouTube playlist items: $error');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> loadConfig() async {
    final file = File('config.json');
    final jsonString = await file.readAsString();
    return json.decode(jsonString);
  }

  Future<void> refreshToken() async {
    final jsonString = await rootBundle.loadString('config.json');
    final config = json.decode(jsonString);
    String clientId = config['web']['client_id'];
    String clientSecret = config['web']['client_secret'];
    String tokenUri = 'https://oauth2.googleapis.com/token';
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');
    if (refreshToken != null) {
      try {
        final response = await http.post(
          Uri.parse(tokenUri),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'client_id': clientId,
            'client_secret': clientSecret,
            'refresh_token': refreshToken,
            'grant_type': 'refresh_token',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final accessToken = data['access_token'];

          await prefs.setString('accessToken', accessToken);
        } else {
          print("Failed to refresh token: ${response.body}");
          throw Exception('Failed to refresh token');
        }
      } catch (e) {
        print("Error: $e");
        Get.snackbar('Token Error', 'Failed to refresh token: $e');
      }
    }
  }
}
