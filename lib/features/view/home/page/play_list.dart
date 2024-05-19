import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_jamc/features/controllers/home_controller.dart';
import 'package:youtube_jamc/features/models/play_list_model_response.dart';

import '../widgets/items_play_list.dart';

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Playlist Videos'),
        backgroundColor: Colors.red[800],
      ),
      body: Obx(() {
        if (homeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.red));
        }

        return ListView.builder(
          itemCount: homeController.playlistVideos.value.items.length,
          itemBuilder: (context, index) {
            PlaylistItem item = homeController.playlistVideos.value.items[index];
            return buildVideoPlayListItem(item, context);
          },
        );
      }),
    );
  }
}
