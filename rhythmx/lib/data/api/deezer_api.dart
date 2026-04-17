import 'dart:convert';
import '../models/album.dart';
import '../models/track.dart';
import '../models/artist.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

class DeezerApi {
  final http.Client _client;
  DeezerApi(this._client);

  Future<List<Track>> getTrendingTracks() async {
    final uri = Uri.parse("${AppConstants.baseUrl}/chart/0/tracks");
    final res = await _client.get(uri);
    if (res.statusCode != 200) throw Exception("Failed to load trending");
    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    final data = (jsonMap["data"] as List? ?? []);
    return data.map((e) => Track.fromJson(e)).toList();
  }

  Future<List<Track>> searchTracks(String query) async {
    final uri = Uri.parse(
      "${AppConstants.baseUrl}/search?q=${Uri.encodeComponent(query)}",
    );
    final res = await _client.get(uri);
    if (res.statusCode != 200) throw Exception("Search failed");
    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    final data = (jsonMap["data"] as List? ?? []);
    return data.map((e) => Track.fromJson(e)).toList();
  }

  Future<Artist> getArtist(int id) async {
    final uri = Uri.parse("${AppConstants.baseUrl}/artist/$id");
    final res = await _client.get(uri);
    if (res.statusCode != 200) throw Exception("Artist load failed");
    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    return Artist.fromJson(jsonMap);
  }

  Future<List<Track>> getArtistTopTracks(int id, {int limit = 50}) async {
    final uri = Uri.parse(
      "${AppConstants.baseUrl}/artist/$id/top?limit=$limit",
    );
    final res = await _client.get(uri);
    if (res.statusCode != 200) throw Exception("Artist top tracks failed");
    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    final data = (jsonMap["data"] as List? ?? []);
    return data.map((e) => Track.fromJson(e)).toList();
  }

  Future<Album> getAlbum(int id) async {
    final uri = Uri.parse("${AppConstants.baseUrl}/album/$id");
    final res = await _client.get(uri);
    if (res.statusCode != 200) throw Exception("Album load failed");
    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    return Album.fromJson(jsonMap);
  }

  Future<List<Track>> getAlbumTracks(int albumId) async {
    final uri = Uri.parse("${AppConstants.baseUrl}/album/$albumId/tracks");
    final res = await _client.get(uri);
    if (res.statusCode != 200) throw Exception("Album tracks failed");
    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    final data = (jsonMap["data"] as List? ?? []);
    return data.map((e) => Track.fromJson(e)).toList();
  }
}
