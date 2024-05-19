import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_jamc/features/controllers/home_controller.dart';
import 'package:youtube_jamc/features/models/videos_youtube_response_model.dart';

class PlaylistPage extends StatelessWidget {
  final String playlistId;
  final HomeController homeController = Get.put(HomeController());

  PlaylistPage({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.fetchPlaylistItems(playlistId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlist Videos'),
        backgroundColor: Colors.red[800],
      ),
      body: Obx(() {
        if (homeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.red));
        }

        return ListView.builder(
          itemCount: homeController.videos.value.items.length,
          itemBuilder: (context, index) {
            MediaItem video = homeController.videos.value.items[index];
            return buildVideoListItem(video, context);
          },
        );
      }),
    );
  }

  Widget buildVideoListItem(MediaItem video, BuildContext context) {
    var thumbnailUrl = video.snippet.thumbnails.high.url;
    bool isPlaylist = video.isPlaylist;

    return GestureDetector(
      onTap: () {
        if (isPlaylist) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistPage(playlistId: video.id),
            ),
          );
        } else {
          Set<String> favoriteIds = homeController.videos.value.items.map((fav) => fav.id).toSet();
          favoriteIds.remove(video.id);
          List<String> favoriteIdsList = [video.id];
          favoriteIdsList.addAll(favoriteIds);
          homeController.isPlayerFinish.value = false;
          homeController.onchangeVideosId(favoriteIdsList);
          Navigator.pop(context);
        }
      },
      child: Card(
        color: isPlaylist ? Colors.blueGrey[900] : Colors.grey[900],
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/image/placeholder.png', fit: BoxFit.cover);
                },
              ),
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
            if (isPlaylist)
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
