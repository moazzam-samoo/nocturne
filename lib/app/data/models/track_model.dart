import '../../domain/entities/track.dart';

class TrackModel extends Track {
  TrackModel({
    required String id,
    required String title,
    required String artistName,
    required String artistImage,
    required String albumImage,
    required String audioUrl,
    required int duration,
  }) : super(
          id: id,
          title: title,
          artistName: artistName,
          artistImage: artistImage,
          albumImage: albumImage,
          audioUrl: audioUrl,
          duration: duration,
        );

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] ?? '',
      title: json['name'] ?? 'Unknown Track',
      artistName: json['artist_name'] ?? 'Unknown Artist',
      artistImage: json['artist_image'] ?? '', // Jamendo often provides this
      albumImage: json['image'] ?? '', // Cover art
      audioUrl: json['audio'] ?? '', // Full audio stream
      duration: json['duration'] ?? 0,
    );
  }

  static List<TrackModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => TrackModel.fromJson(e)).toList();
  }
}
