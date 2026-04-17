import 'dart:convert';
import '../models/track.dart';
import '../../core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  static const _kLowData = "low_data_mode";
  static const _kFavorites = "favorites";
  static const _kRecent = "recent_played";
  static const _kSearchHistory = "search_history";

  Future<bool> getLowDataMode() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kLowData) ?? false;
  }

  Future<void> setLowDataMode(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kLowData, value);
  }

  Future<List<Track>> getFavorites() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_kFavorites) ?? [];
    return raw.map((s) => Track.fromJson(jsonDecode(s))).toList();
  }

  Future<void> toggleFavorite(Track track) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_kFavorites) ?? [];
    final exists = raw.any((s) => (jsonDecode(s)["id"] == track.id));
    if (exists) {
      raw.removeWhere((s) => (jsonDecode(s)["id"] == track.id));
    } else {
      raw.insert(0, jsonEncode(track.toJson()));
    }
    await sp.setStringList(_kFavorites, raw);
  }

  Future<bool> isFavorite(int trackId) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_kFavorites) ?? [];
    return raw.any((s) => (jsonDecode(s)["id"] == trackId));
  }

  Future<List<Track>> getRecentPlayed() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_kRecent) ?? [];
    return raw.map((s) => Track.fromJson(jsonDecode(s))).toList();
  }

  Future<void> addRecentPlayed(Track track) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList(_kRecent) ?? [];

    raw.removeWhere((s) => (jsonDecode(s)["id"] == track.id));
    raw.insert(0, jsonEncode(track.toJson()));

    if (raw.length > AppConstants.recentPlayedLimit) {
      raw.removeRange(AppConstants.recentPlayedLimit, raw.length);
    }
    await sp.setStringList(_kRecent, raw);
  }

  Future<List<String>> getSearchHistory() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_kSearchHistory) ?? [];
  }

  Future<void> addSearchHistory(String query) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_kSearchHistory) ?? [];
    final q = query.trim();
    if (q.isEmpty) return;

    list.removeWhere((x) => x.toLowerCase() == q.toLowerCase());
    list.insert(0, q);

    if (list.length > 20) list.removeRange(20, list.length);
    await sp.setStringList(_kSearchHistory, list);
  }

  Future<void> clearSearchHistory() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kSearchHistory);
  }
}
