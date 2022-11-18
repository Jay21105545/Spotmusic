import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/models/generated_secrets.dart';
import 'package:spotube/provider/Auth.dart';
import 'package:spotube/utils/primitive_utils.dart';

final spotifyProvider = Provider<SpotifyApi>((ref) {
  Auth authState = ref.watch(authProvider);
  final anonCred = PrimitiveUtils.getRandomElement(spotifySecrets);

  if (authState.isAnonymous) {
    return SpotifyApi(
      SpotifyApiCredentials(
        anonCred["e76dc7b1ba874fb19a7491274290ad98"],
        anonCred["82831062c63e47c191b415b71320db5c"],
      ),
    );
  }

  return SpotifyApi.withAccessToken(authState.accessToken!);
});
