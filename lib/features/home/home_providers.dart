import '../../data/models/track.dart';
import '../../data/api/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final trendingProvider = FutureProvider<List<Track>>((ref) async {
  return ref.read(deezerApiProvider).getTrendingTracks();
});

final banglaHitsProvider = FutureProvider<List<Track>>((ref) async {
  return ref.read(deezerApiProvider).searchTracks("bangla bengali dhaka");
});

final romanticProvider = FutureProvider<List<Track>>((ref) async {
  return ref.read(deezerApiProvider).searchTracks("romantic bangla");
});

final islamicProvider = FutureProvider<List<Track>>((ref) async {
  return ref.read(deezerApiProvider).searchTracks("nasheed islamic");
});

final folkProvider = FutureProvider<List<Track>>((ref) async {
  return ref.read(deezerApiProvider).searchTracks("folk bangla lalan");
});
