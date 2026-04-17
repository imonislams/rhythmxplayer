import 'home_providers.dart';
import '../../data/models/track.dart';
import '../player/player_screen.dart';
import 'package:flutter/material.dart';
import '../../data/api/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowData = ref.watch(lowDataModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("RhythmX"),
        actions: [
          if (lowData)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: Text("Low Data", style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _Section(
            title: "Trending",
            asyncTracks: ref.watch(trendingProvider),
            lowData: lowData,
          ),
          _Section(
            title: "Bangla Hits",
            asyncTracks: ref.watch(banglaHitsProvider),
            lowData: lowData,
          ),
          _Section(
            title: "Romantic",
            asyncTracks: ref.watch(romanticProvider),
            lowData: lowData,
          ),
          _Section(
            title: "Islamic / Nasheed",
            asyncTracks: ref.watch(islamicProvider),
            lowData: lowData,
          ),
          _Section(
            title: "Folk / Lalon",
            asyncTracks: ref.watch(folkProvider),
            lowData: lowData,
          ),
        ],
      ),
    );
  }
}

class _Section extends ConsumerWidget {
  final String title;
  final AsyncValue<List<Track>> asyncTracks;
  final bool lowData;

  const _Section({
    required this.title,
    required this.asyncTracks,
    required this.lowData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 160,
            child: asyncTracks.when(
              data: (tracks) => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: tracks.length.clamp(0, 20),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final t = tracks[i];
                  final cover = lowData ? t.coverSmall : t.coverMedium;

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      await ref.read(localStoreProvider).addRecentPlayed(t);

                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PlayerScreen(queue: tracks, startIndex: i),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CachedNetworkImage(
                              imageUrl: cover,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              fadeInDuration: const Duration(milliseconds: 100),
                              placeholder: (_, __) =>
                                  Container(color: Colors.white10),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.white10,
                                child: const Icon(Icons.music_note),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            t.artistName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Failed to load: $title"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
