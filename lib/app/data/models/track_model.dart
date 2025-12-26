import '../../domain/entities/track.dart';

class TrackModel extends Track {
  TrackModel({
    required String id,
    required String name,
    required String artistName,
    required String albumImage,
    required String audioUrl,
    required int duration,
  }) : super(
          id: id,
          name: name,
          artistName: artistName,
          albumImage: albumImage,
          audioUrl: audioUrl,
          duration: duration,
        );

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Track',
      artistName: json['artist_name'] ?? 'Unknown Artist',
      albumImage: json['image'] ?? '',
      audioUrl: json['audio'] ?? '',
      duration: json['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artist_name': artistName,
      'image': albumImage,
      'audio': audioUrl,
      'duration': duration,
    };
  }
}
