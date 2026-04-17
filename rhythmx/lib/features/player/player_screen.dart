import 'dart:async';
import '../../data/models/track.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/api/providers.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final List<Track> queue;
  final int startIndex;

  const PlayerScreen({
    super.key,
    required this.queue,
    required this.startIndex,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late final AudioPlayer _player;
  late int _index;
  StreamSubscription<Duration?>? _durSub;

  Track get current => widget.queue[_index];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _index = widget.startIndex;
    _loadAndPlay(autoPlay: true);

    // Safety: when preview ends, auto pause (usually ends by itself)
    _durSub = _player.durationStream.listen((d) {});
  }

  Future<void> _loadAndPlay({required bool autoPlay}) async {
    final t = current;

    // Add to recent played
    await ref.read(localStoreProvider).addRecentPlayed(t);

    // Preview only
    if (t.preview.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preview not available.")));
      return;
    }

    try {
      await _player.setUrl(t.preview);
      if (autoPlay) await _player.play();
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to play preview.")));
    }
  }

  void _next() {
    if (_index < widget.queue.length - 1) {
      _index++;
      _loadAndPlay(autoPlay: true);
    }
  }

  void _prev() {
    if (_index > 0) {
      _index--;
      _loadAndPlay(autoPlay: true);
    }
  }

  Future<void> _toggleFavorite() async {
    await ref.read(localStoreProvider).toggleFavorite(current);
    setState(() {});
  }

  Future<void> _shareCopy() async {
    final text = "${current.title} — ${current.artistName}";
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Copied to clipboard.")));
  }

  @override
  void dispose() {
    _durSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lowData = ref.watch(lowDataModeProvider);

    final cover = lowData ? current.coverMedium : current.coverBig;

    return Scaffold(
      appBar: AppBar(title: const Text("Now Playing")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CachedNetworkImage(
                imageUrl: cover,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: Colors.white10, height: 280),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.white10,
                  height: 280,
                  child: const Icon(Icons.music_note, size: 48),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              current.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              current.artistName,
              style: const TextStyle(color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            const Text(
              "Preview only (30 seconds)",
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 16),

            // Slider
            StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (_, snap) {
                final pos = snap.data ?? Duration.zero;
                final dur = _player.duration ?? const Duration(seconds: 30);
                final max = dur.inMilliseconds.toDouble().clamp(
                  1,
                  double.infinity,
                );
                final val = pos.inMilliseconds.toDouble().clamp(0, max);

                return Column(
                  children: [
                    Slider(
                      value: val,
                      max: max,
                      onChanged: (v) =>
                          _player.seek(Duration(milliseconds: v.toInt())),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _fmt(pos),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          _fmt(dur),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 34,
                  onPressed: _prev,
                  icon: const Icon(Icons.skip_previous),
                ),
                StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  builder: (_, snap) {
                    final playing = snap.data?.playing ?? false;
                    return FilledButton(
                      onPressed: () =>
                          playing ? _player.pause() : _player.play(),
                      child: Icon(playing ? Icons.pause : Icons.play_arrow),
                    );
                  },
                ),
                IconButton(
                  iconSize: 34,
                  onPressed: _next,
                  icon: const Icon(Icons.skip_next),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Favorite + Share
            FutureBuilder<bool>(
              future: ref.read(localStoreProvider).isFavorite(current.id),
              builder: (_, snap) {
                final fav = snap.data ?? false;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _toggleFavorite,
                      icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
                      label: Text(fav ? "Favorited" : "Favorite"),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _shareCopy,
                      icon: const Icon(Icons.share),
                      label: const Text("Copy"),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}
