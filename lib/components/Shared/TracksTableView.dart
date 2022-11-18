import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/components/Library/UserLocalTracks.dart';
import 'package:spotube/components/Shared/DownloadConfirmationDialog.dart';
import 'package:spotube/components/Shared/NotFound.dart';
import 'package:spotube/components/Shared/SortTracksDropdown.dart';
import 'package:spotube/components/Shared/TrackTile.dart';
import 'package:spotube/hooks/useBreakpoints.dart';
import 'package:spotube/provider/Downloader.dart';
import 'package:spotube/provider/Playback.dart';
import 'package:spotube/utils/primitive_utils.dart';
import 'package:spotube/utils/service_utils.dart';

final trackCollectionSortState =
    StateProvider.family<SortBy, String>((ref, _) => SortBy.none);

class TracksTableView extends HookConsumerWidget {
  final void Function(Track currentTrack)? onTrackPlayButtonPressed;
  final List<Track> tracks;
  final bool userPlaylist;
  final String? playlistId;
  final bool isSliver;

  final Widget? heading;
  const TracksTableView(
    this.tracks, {
    Key? key,
    this.onTrackPlayButtonPressed,
    this.userPlaylist = false,
    this.playlistId,
    this.heading,
    this.isSliver = true,
  }) : super(key: key);

  @override
  Widget build(context, ref) {
    Playback playback = ref.watch(playbackProvider);
    final downloader = ref.watch(downloaderProvider);
    TextStyle tableHeadStyle =
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

    final breakpoint = useBreakpoints();

    final selected = useState<List<String>>([]);
    final showCheck = useState<bool>(false);
    final sortBy = ref.watch(trackCollectionSortState(playlistId ?? ''));

    final sortedTracks = useMemoized(
      () {
        return ServiceUtils.sortTracks(tracks, sortBy);
      },
      [tracks, sortBy],
    );

    final selectedTracks = useMemoized(
      () => sortedTracks.where(
        (track) => selected.value.contains(track.id),
      ),
      [sortedTracks],
    );

    final children = sortedTracks.isEmpty
        ? [const NotFound(vertical: true)]
        : [
            if (heading != null) heading!,
            Row(
              children: [
                Checkbox(
                  value: selected.value.length == sortedTracks.length,
                  onChanged: (checked) {
                    if (!showCheck.value) showCheck.value = true;
                    if (checked == true) {
                      selected.value = sortedTracks.map((s) => s.id!).toList();
                    } else {
                      selected.value = [];
                      showCheck.value = false;
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "#",
                    textAlign: TextAlign.center,
                    style: tableHeadStyle,
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "Title",
                        style: tableHeadStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // used alignment of this table-head
                if (breakpoint.isMoreThan(Breakpoints.md)) ...[
                  const SizedBox(width: 100),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "Album",
                          overflow: TextOverflow.ellipsis,
                          style: tableHeadStyle,
                        ),
                      ],
                    ),
                  )
                ],
                if (!breakpoint.isSm) ...[
                  const SizedBox(width: 10),
                  Text("Time", style: tableHeadStyle),
                  const SizedBox(width: 10),
                ],
                SortTracksDropdown(
                  value: sortBy,
                  onChanged: (value) {
                    ref
                        .read(trackCollectionSortState(playlistId ?? '').state)
                        .state = value;
                  },
                ),
                PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        enabled: selected.value.isNotEmpty,
                        value: "download",
                        child: Row(
                          children: [
                            const Icon(Icons.file_download_outlined),
                            Text(
                              "Download ${selectedTracks.isNotEmpty ? "(${selectedTracks.length})" : ""}",
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                  onSelected: (action) async {
                    switch (action) {
                      case "download":
                        {
                          final isConfirmed = await showDialog(
                              context: context,
                              builder: (context) {
                                return const DownloadConfirmationDialog();
                              });
                          if (isConfirmed != true) return;
                          for (final selectedTrack in selectedTracks) {
                            downloader.addToQueue(selectedTrack);
                          }
                          selected.value = [];
                          showCheck.value = false;
                          break;
                        }
                      default:
                    }
                  },
                ),
              ],
            ),
            ...sortedTracks.asMap().entries.map((track) {
              String duration =
                  "${track.value.duration?.inMinutes.remainder(60)}:${PrimitiveUtils.zeroPadNumStr(track.value.duration?.inSeconds.remainder(60) ?? 0)}";
              return InkWell(
                onLongPress: () {
                  showCheck.value = true;
                  selected.value = [...selected.value, track.value.id!];
                },
                onTap: () {
                  if (showCheck.value) {
                    final alreadyChecked =
                        selected.value.contains(track.value.id);
                    if (alreadyChecked) {
                      selected.value = selected.value
                          .where((id) => id != track.value.id)
                          .toList();
                    } else {
                      selected.value = [...selected.value, track.value.id!];
                    }
                  } else {
                    onTrackPlayButtonPressed?.call(track.value);
                  }
                },
                child: TrackTile(
                  playback,
                  playlistId: playlistId,
                  track: track,
                  duration: duration,
                  userPlaylist: userPlaylist,
                  isActive: playback.track?.id == track.value.id,
                  onTrackPlayButtonPressed: onTrackPlayButtonPressed,
                  isChecked: selected.value.contains(track.value.id),
                  showCheck: showCheck.value,
                  onCheckChange: (checked) {
                    if (checked == true) {
                      selected.value = [...selected.value, track.value.id!];
                    } else {
                      selected.value = selected.value
                          .where((id) => id != track.value.id)
                          .toList();
                    }
                  },
                ),
              );
            }).toList(),
          ];

    if (isSliver) {
      return SliverList(delegate: SliverChildListDelegate(children));
    }
    return ListView(children: children);
  }
}
