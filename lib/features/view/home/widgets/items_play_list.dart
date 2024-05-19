import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_jamc/features/controllers/home_controller.dart';
import 'package:youtube_jamc/features/models/play_list_model_response.dart';
import 'package:youtube_jamc/features/view/home/page/play_list.dart';

Widget buildVideoPlayListItem(PlaylistItem item, context) {
  var thumbnailUrl = item.snippet.thumbnails.high.url;
  final HomeController homeController = Get.put(HomeController());

  return GestureDetector(
    onTap: () {
      if (item.isPlaylist) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistPage(playlistId: item.id),
          ),
        );
      } else {
        if (homeController.videoIds.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            homeController.isPlayerMinimized.value = false;
            homeController.videoIds.value = [];
          });
          Future.delayed(const Duration(milliseconds: 300)).then((value) {
            Set<String> favoriteIds =
                homeController.playlistVideos.value.items.where((fav) => !fav.isPlaylist).map((fav) => fav.contentDetails.videoId!).toSet();
            favoriteIds.remove(item.contentDetails.videoId);
            List<String> favoriteIdsList = [item.contentDetails.videoId!];
            favoriteIdsList.addAll(favoriteIds);
            homeController.isPlayerFinish.value = false;
            homeController.onchangeVideosId(favoriteIdsList);
            homeController.isPlayListValue.value = true;
          });
          return;
        }
        Set<String> favoriteIds =
            homeController.playlistVideos.value.items.where((fav) => !fav.isPlaylist).map((fav) => fav.contentDetails.videoId!).toSet();
        favoriteIds.remove(item.contentDetails.videoId);
        List<String> favoriteIdsList = [item.contentDetails.videoId!];
        favoriteIdsList.addAll(favoriteIds);
        homeController.isPlayerFinish.value = false;
        homeController.onchangeVideosId(favoriteIdsList);
        homeController.isPlayListValue.value = true;
        Navigator.pop(context);
      }
    },
    child: Card(
      color: item.isPlaylist ? Colors.blueGrey[900] : Colors.grey[900],
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
              item.snippet.title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              item.snippet.description,
              style: TextStyle(color: Colors.grey[400]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.isPlaylist)
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
