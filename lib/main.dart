import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fl_query/fl_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotube/components/Shared/ReplaceDownloadedFileDialog.dart';
import 'package:spotube/entities/CacheTrack.dart';
import 'package:spotube/models/GoRouteDeclarations.dart';
import 'package:spotube/models/Intents.dart';
import 'package:spotube/models/LocalStorageKeys.dart';
import 'package:spotube/models/Logger.dart';
import 'package:spotube/provider/AudioPlayer.dart';
import 'package:spotube/provider/Downloader.dart';
import 'package:spotube/provider/Playback.dart';
import 'package:spotube/provider/UserPreferences.dart';
import 'package:spotube/provider/YouTube.dart';
import 'package:spotube/services/MobileAudioService.dart';
import 'package:spotube/themes/dark-theme.dart';
import 'package:spotube/themes/light-theme.dart';
import 'package:spotube/utils/platform.dart';

final bowl = QueryBowl(refetchOnExternalDataChange: true);
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CacheTrackAdapter());
  Hive.registerAdapter(CacheTrackEngagementAdapter());
  Hive.registerAdapter(CacheTrackSkipSegmentAdapter());
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsDesktop) {
    doWhenWindowReady(() async {
      final localStorage = await SharedPreferences.getInstance();
      final rawSize = localStorage.getString(LocalStorageKeys.windowSizeInfo);
      final savedSize = rawSize != null ? json.decode(rawSize) : null;
      final double? height = savedSize?["height"];
      final double? width = savedSize?["width"];
      appWindow.minSize = const Size(359, 700);
      appWindow.alignment = Alignment.center;
      appWindow.title = "Spotube";
      if (height != null && width != null && height >= 700 && width >= 359) {
        appWindow.size = Size(width, height);
      } else {
        appWindow.maximize();
      }
      appWindow.show();
    });
  }
  MobileAudioService? audioServiceHandler;
  runApp(
    Builder(
      builder: (context) {
        return ProviderScope(
          overrides: [
            playbackProvider.overrideWithProvider(
              ChangeNotifierProvider(
                (ref) {
                  final youtube = ref.watch(youtubeProvider);
                  final player = ref.watch(audioPlayerProvider);

                  final playback = Playback(
                    player: player,
                    youtube: youtube,
                    ref: ref,
                  );

                  if (audioServiceHandler == null) {
                    AudioService.init(
                      builder: () => MobileAudioService(playback),
                      config: const AudioServiceConfig(
                        androidNotificationChannelId: 'com.krtirtho.Spotube',
                        androidNotificationChannelName: 'Spotube',
                        androidNotificationOngoing: true,
                      ),
                    ).then(
                      (value) {
                        playback.mobileAudioService = value;
                        audioServiceHandler = value;
                      },
                    );
                  }

                  return playback;
                },
              ),
            ),
            downloaderProvider.overrideWithProvider(
              ChangeNotifierProvider(
                (ref) {
                  return Downloader(
                    ref,
                    queueInstance,
                    yt: ref.watch(youtubeProvider),
                    downloadPath: ref.watch(
                      userPreferencesProvider.select(
                        (s) => s.downloadLocation,
                      ),
                    ),
                    onFileExists: (track) {
                      final logger = getLogger(Downloader);
                      try {
                        logger.v(
                          "[onFileExists] download confirmation for ${track.name}",
                        );
                        return showDialog<bool>(
                          context: context,
                          builder: (_) =>
                              ReplaceDownloadedFileDialog(track: track),
                        ).then((s) => s ?? false);
                      } catch (e, stack) {
                        logger.e(
                          "onFileExists",
                          e,
                          stack,
                        );
                        return false;
                      }
                    },
                  );
                },
              ),
            )
          ],
          child: QueryBowlScope(
            bowl: bowl,
            child: const Spotube(),
          ),
        );
      },
    ),
  );
}

class Spotube extends StatefulHookConsumerWidget {
  const Spotube({Key? key}) : super(key: key);

  @override
  SpotubeState createState() => SpotubeState();
}

class SpotubeState extends ConsumerState<Spotube> with WidgetsBindingObserver {
  final logger = getLogger(Spotube);
  SharedPreferences? localStorage;

  Size? prevSize;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then(((value) => localStorage = value));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final windowSameDimension = kIsMobile
        ? false
        : prevSize?.width == appWindow.size.width &&
            prevSize?.height == appWindow.size.height;

    if (localStorage == null || windowSameDimension || kIsMobile) return;
    localStorage!.setString(
      LocalStorageKeys.windowSizeInfo,
      jsonEncode({
        'width': appWindow.isMaximized ? 0.0 : appWindow.size.width,
        'height': appWindow.isMaximized ? 0.0 : appWindow.size.height,
      }),
    );
    prevSize = appWindow.size;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode =
        ref.watch(userPreferencesProvider.select((s) => s.themeMode));
    final accentMaterialColor =
        ref.watch(userPreferencesProvider.select((s) => s.accentColorScheme));
    final backgroundMaterialColor = ref
        .watch(userPreferencesProvider.select((s) => s.backgroundColorScheme));
    final player = ref.watch(audioPlayerProvider);
    final youtube = ref.watch(youtubeProvider);

    useEffect(() {
      return () {
        player.dispose();
        youtube.close();
      };
    }, []);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Spotube',
      theme: lightTheme(
        accentMaterialColor: accentMaterialColor,
        backgroundMaterialColor: backgroundMaterialColor,
      ),
      darkTheme: darkTheme(
        accentMaterialColor: accentMaterialColor,
        backgroundMaterialColor: backgroundMaterialColor,
      ),
      themeMode: themeMode,
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.space): PlayPauseIntent(ref),
        const SingleActivator(LogicalKeyboardKey.comma, control: true):
            NavigationIntent(router, "/settings"),
        const SingleActivator(
          LogicalKeyboardKey.keyB,
          control: true,
          shift: true,
        ): HomeTabIntent(ref, tab: HomeTabs.browse),
        const SingleActivator(
          LogicalKeyboardKey.keyS,
          control: true,
          shift: true,
        ): HomeTabIntent(ref, tab: HomeTabs.search),
        const SingleActivator(
          LogicalKeyboardKey.keyL,
          control: true,
          shift: true,
        ): HomeTabIntent(ref, tab: HomeTabs.library),
        const SingleActivator(
          LogicalKeyboardKey.keyY,
          control: true,
          shift: true,
        ): HomeTabIntent(ref, tab: HomeTabs.lyrics),
        const SingleActivator(
          LogicalKeyboardKey.keyW,
          control: true,
          shift: true,
        ): CloseAppIntent(),
      },
      actions: {
        ...WidgetsApp.defaultActions,
        PlayPauseIntent: PlayPauseAction(),
        NavigationIntent: NavigationAction(),
        HomeTabIntent: HomeTabAction(),
        CloseAppIntent: CloseAppAction(),
      },
    );
  }
}
