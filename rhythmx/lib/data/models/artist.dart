class Artist {
  final int id;
  final String name;
  final int nbFan;
  final String pictureSmall;
  final String pictureMedium;
  final String pictureBig;

  Artist({
    required this.id,
    required this.name,
    required this.nbFan,
    required this.pictureSmall,
    required this.pictureMedium,
    required this.pictureBig,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      nbFan: json["nb_fan"] ?? 0,
      pictureSmall: json["picture_small"] ?? "",
      pictureMedium: json["picture_medium"] ?? "",
      pictureBig: json["picture_big"] ?? "",
    );
  }
}
