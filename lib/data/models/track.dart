class Track {
  final int id;
  final String title;
  final String preview; // 30 sec preview url
  final int duration;

  final int artistId;
  final String artistName;

  final int albumId;
  final String albumTitle;

  final String coverSmall;
  final String coverMedium;
  final String coverBig;

  Track({
    required this.id,
    required this.title,
    required this.preview,
    required this.duration,
    required this.artistId,
    required this.artistName,
    required this.albumId,
    required this.albumTitle,
    required this.coverSmall,
    required this.coverMedium,
    required this.coverBig,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    final artist = json["artist"] ?? {};
    final album = json["album"] ?? {};

    return Track(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      preview: json["preview"] ?? "",
      duration: json["duration"] ?? 0,
      artistId: artist["id"] ?? 0,
      artistName: artist["name"] ?? "",
      albumId: album["id"] ?? 0,
      albumTitle: album["title"] ?? "",
      coverSmall: album["cover_small"] ?? "",
      coverMedium: album["cover_medium"] ?? "",
      coverBig: album["cover_big"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "preview": preview,
    "duration": duration,
    "artistId": artistId,
    "artistName": artistName,
    "albumId": albumId,
    "albumTitle": albumTitle,
    "coverSmall": coverSmall,
    "coverMedium": coverMedium,
    "coverBig": coverBig,
  };
}
