import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:youtube_jamc/features/controllers/home_controller.dart';
import 'package:youtube_jamc/features/models/play_list_model_response.dart';
import 'package:youtube_jamc/features/models/videos_youtube_response_model.dart';
import 'package:youtube_jamc/features/view/home/page/play_list.dart';
import 'package:youtube_jamc/features/view/home/widgets/items_play_list.dart';
import 'package:youtube_jamc/features/view/video_player/video_player_page.dart';
import 'package:youtube_jamc/util/bottom_navigator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Añadir el controlador de scroll a tu clase de controlador
  ScrollController scrollController = ScrollController();
  final HomeController homeController = Get.put(HomeController());
  final TextEditingController searchController = TextEditingController();
  void setUpScrollController() {
    scrollController.addListener(() {
      // Verifica si estamos cerca del final de la página
      if (scrollController.position.maxScrollExtent - scrollController.offset <= 200) {
        String nextPageToken = homeController.nextPageToken.value;
        if (nextPageToken.isNotEmpty && !homeController.isLoading.value) {
          if (homeController.isSearching.value && homeController.searchQuery.isNotEmpty) {
            homeController.searchYouTubeVideos(homeController.searchQuery.value, pageToken: nextPageToken);
          } else {
            homeController.fetchYouTubeMusic(pageToken: nextPageToken);
          }
        }
      }
    });
  }

  void removeFloatingVideoPlayer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.isPlayerMinimized.value = false;
      homeController.videoIds.value = [];
      homeController.isPlayListValue.value = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setUpScrollController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.red[800],
                  floating: true,
                  expandedHeight: 100.0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    title: Obx(() => homeController.isSearching.value
                        ? TextField(
                            controller: searchController,
                            autofocus: false,
                            decoration: const InputDecoration(
                              hintText: "Search videos...",
                              hintStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: homeController.searchYouTubeVideos,
                          )
                        : Row(
                            children: [
                              Image.asset(
                                'assets/image/youtube_logo.png',
                                height: 40.0,
                              ),
                              const SizedBox(width: 10.0),
                              const Text(
                                'YouTubeJAMC',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                  ),
                  actions: [
                    IconButton(icon: const Icon(Icons.tv), onPressed: () {}),
                    IconButton(icon: const Icon(FontAwesomeIcons.bell), onPressed: () {}),
                    IconButton(
                        icon: Obx(() => Icon(homeController.isSearching.value ? Icons.close : FontAwesomeIcons.magnifyingGlass)),
                        onPressed: () {
                          homeController.toggleSearch();
                          if (!homeController.isSearching.value) {
                            searchController.clear();
                          }
                        }),
                    const SizedBox(width: 10.0),
                  ],
                ),
                buildVideoList(),
              ],
            ),
            Obx(
              () {
                if (homeController.isPlayerFinish.value) {
                  removeFloatingVideoPlayer();
                }
                if (homeController.videoIds.isEmpty) {
                  return const SizedBox();
                }
                return Positioned.fill(
                  child: DraggableScrollableSheet(
                    controller: homeController.controllerDraggable.value,
                    initialChildSize: 0.08,
                    minChildSize: 0.08,
                    maxChildSize: 1.0,
                    builder: (context, scrollController) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        child: Container(
                          color: Colors.black,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            children: [
                              Listener(
                                onPointerUp: (details) {
                                  double dragDistance = details.position.dy;
                                  double screenHeight = MediaQuery.of(context).size.height;
                                  if (dragDistance < screenHeight / 1.7) {
                                    homeController.controllerDraggable.value
                                        .animateTo(1.0, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
                                    homeController.isPlayerMinimized.value = false;
                                  } else {
                                    homeController.controllerDraggable.value
                                        .animateTo(0.08, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
                                    homeController.isPlayerMinimized.value = true;
                                  }
                                },
                                child: Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.purple,
                                  child: VideoPlayerScreen(ids: homeController.videoIds),
                                ),
                              ),
                              Expanded(
                                child: buildVideoList1(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: Obx(() => homeController.isPlayerMinimized.value ? const BotomMenuYoutube() : const SizedBox()),
      ),
    );
  }

  Widget buildVideoList1() {
    return Obx(
      () => ListView.builder(
        shrinkWrap: true,
        itemCount: !homeController.isPlayListValue.value
            ? homeController.videos.value.items.length
            : homeController.playlistVideos.value.items.length + (homeController.isLoading.value ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          homeController.saveload.value;
          if (index >= homeController.videos.value.items.length) {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: const CircularProgressIndicator(color: Colors.red),
            );
          }
          if (homeController.isPlayListValue.value) {
            PlaylistItem item = homeController.playlistVideos.value.items[index];
            return buildVideoPlayListItem(item, context);
          }
          MediaItem video = homeController.videos.value.items[index];
          return buildVideoListItem(video);
        },
      ),
    );
  }

  Widget buildVideoList() {
    return Obx(() => SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              homeController.saveload.value;
              if (index >= homeController.videos.value.items.length) {
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  child: const CircularProgressIndicator(color: Colors.red),
                );
              }
              MediaItem video = homeController.videos.value.items[index];

              return buildVideoListItem(video);
            },
            childCount: homeController.videos.value.items.length + (homeController.isLoading.value ? 1 : 0),
          ),
        ));
  }

  Widget buildVideoListItem(MediaItem video) {
    var thumbnailUrl = video.snippet.thumbnails.high.url;

    return GestureDetector(
      onTap: () {
        homeController.isPlayListValue.value = false;
        if (video.isPlaylist) {
          removeFloatingVideoPlayer();
          // Si es una lista de reproducción, navega a la página de la lista de reproducción
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistPage(playlistId: video.id),
            ),
          );
          return;
        }
        if (homeController.videoIds.isNotEmpty) {
          removeFloatingVideoPlayer();
          Future.delayed(const Duration(milliseconds: 200)).then((value) {
            Set<String> favoriteIds = homeController.videos.value.items.map((fav) => fav.id).toSet();
            favoriteIds.remove(video.id);
            List<String> favoriteIdsList = [video.id];
            favoriteIdsList.addAll(favoriteIds);
            homeController.isPlayerFinish.value = false;
            homeController.onchangeVideosId(favoriteIdsList);
          });
          return;
        }

        Set<String> favoriteIds = homeController.videos.value.items.map((fav) => fav.id).toSet();
        favoriteIds.remove(video.id);
        List<String> favoriteIdsList = [video.id];
        favoriteIdsList.addAll(favoriteIds);
        homeController.isPlayerFinish.value = false;
        homeController.onchangeVideosId(favoriteIdsList);
      },
      child: Card(
        color: video.isPlaylist ? Colors.blueGrey[900] : Colors.grey[900],
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(thumbnailUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                video.snippet.title,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                video.snippet.description,
                style: TextStyle(color: Colors.grey[400]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (video.isPlaylist)
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Playlist',
                  style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
