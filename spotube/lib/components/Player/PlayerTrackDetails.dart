import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/components/Shared/UniversalImage.dart';
import 'package:spotube/hooks/useBreakpoints.dart';
import 'package:spotube/provider/Playback.dart';
import 'package:spotube/utils/type_conversion_utils.dart';

class PlayerTrackDetails extends HookConsumerWidget {
  final String? albumArt;
  final Color? color;
  const PlayerTrackDetails({Key? key, this.albumArt, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final breakpoint = useBreakpoints();
    final playback = ref.watch(playbackProvider);

    return Row(
      children: [
        if (albumArt != null)
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: UniversalImage(
              path: albumArt!,
              height: 50,
              width: 50,
              placeholder: (context, url) {
                return Image.asset(
                  "assets/album-placeholder.png",
                  height: 50,
                  width: 50,
                );
              },
            ),
          ),
        if (breakpoint.isLessThanOrEqualTo(Breakpoints.md))
          Flexible(
            child: Text(
              playback.track?.name ?? "Not playing",
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  ?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ),

        //  title of the currently playing track
        if (breakpoint.isMoreThan(Breakpoints.md))
          Flexible(
            flex: 1,
            child: Column(
              children: [
                Text(
                  playback.track?.name ?? "Not playing",
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.copyWith(fontWeight: FontWeight.bold, color: color),
                ),
                TypeConversionUtils.artists_X_ClickableArtists(
                  playback.track?.artists ?? [],
                )
              ],
            ),
          ),
      ],
    );
  }
}
