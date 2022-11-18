import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/components/LoaderShimmers/ShimmerPlaybuttonCard.dart';
import 'package:spotube/components/Playlist/PlaylistCard.dart';
import 'package:spotube/components/Shared/Waypoint.dart';
import 'package:spotube/models/Logger.dart';
import 'package:spotube/provider/SpotifyDI.dart';
import 'package:spotube/provider/SpotifyRequests.dart';

class CategoryCard extends HookConsumerWidget {
  final Category category;
  final Iterable<PlaylistSimple>? playlists;
  CategoryCard(
    this.category, {
    Key? key,
    this.playlists,
  }) : super(key: key);

  final logger = getLogger(CategoryCard);

  @override
  Widget build(BuildContext context, ref) {
    final scrollController = useScrollController();
    final spotify = ref.watch(spotifyProvider);
    final playlistQuery = useInfiniteQuery(
      job: categoryPlaylistsQueryJob(category.id!),
      externalData: spotify,
    );
    final hasNextPage = playlistQuery.pages.isEmpty
        ? false
        : (playlistQuery.pages.last?.items?.length ?? 0) == 5;

    final playlists = playlistQuery.pages
        .expand(
          (page) => page?.items ?? const Iterable.empty(),
        )
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                category.name ?? "Unknown",
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
        ),
        playlistQuery.hasError
            ? Text("Something Went Wrong\n${playlistQuery.errors.first}")
            : SizedBox(
                height: 245,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: Scrollbar(
                    controller: scrollController,
                    interactive: false,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        if (index == playlists.length - 1 && hasNextPage) {
                          return Waypoint(
                            onEnter: () {
                              playlistQuery.fetchNextPage();
                            },
                            child: const ShimmerPlaybuttonCard(count: 1),
                          );
                        }
                        return PlaylistCard(playlists[index]);
                      },
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
