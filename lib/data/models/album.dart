class Album {
  final int id;
  final String title;
  final String coverSmall;
  final String coverMedium;
  final String coverBig;
  final String artistName;

  Album({
    required this.id,
    required this.title,
    required this.coverSmall,
    required this.coverMedium,
    required this.coverBig,
    required this.artistName,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    final artist = json["artist"] ?? {};
    return Album(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      coverSmall: json["cover_small"] ?? "",
      coverMedium: json["cover_medium"] ?? "",
      coverBig: json["cover_big"] ?? "",
      artistName: artist["name"] ?? "",
    );
  }
}
