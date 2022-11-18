import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/components/Artist/ArtistCard.dart';
import 'package:spotube/components/Shared/Waypoint.dart';
import 'package:spotube/provider/SpotifyDI.dart';
import 'package:spotube/provider/SpotifyRequests.dart';

class UserArtists extends HookConsumerWidget {
  const UserArtists({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final artistQuery = useInfiniteQuery(
      job: currentUserFollowingArtistsQueryJob,
      externalData: ref.watch(spotifyProvider),
    );

    final artists = useMemoized(
        () => artistQuery.pages
            .expand<Artist>((page) => page?.items ?? const Iterable.empty())
            .toList(),
        [artistQuery.pages]);

    final hasNextPage = artistQuery.pages.isEmpty
        ? false
        : (artistQuery.pages.last?.items?.length ?? 0) == 15;

    return GridView.builder(
      itemCount: artists.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 250,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        if (index == artists.length - 1 && hasNextPage) {
          return Waypoint(
            onEnter: () {
              artistQuery.fetchNextPage();
            },
            child: ArtistCard(artists[index]),
          );
        }
        return ArtistCard(artists[index]);
      },
    );
  }
}
