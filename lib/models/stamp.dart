import 'package:intl/intl.dart';

class Stamp {
  final String id;
  final String placeId;
  final String placeName;
  final DateTime stampedAt;
  final int combo;
  final int earnedPoints;

  const Stamp({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.stampedAt,
    required this.combo,
    required this.earnedPoints,
  });

  String get formattedDate => DateFormat('yyyy.MM.dd').format(stampedAt);
  String get formattedTime => DateFormat('HH:mm:ss').format(stampedAt);
  String get formattedDateTime => DateFormat('MM/dd HH:mm').format(stampedAt);

  Map<String, dynamic> toJson() => {
        'id': id,
        'placeId': placeId,
        'placeName': placeName,
        'stampedAt': stampedAt.toIso8601String(),
        'combo': combo,
        'earnedPoints': earnedPoints,
      };

  factory Stamp.fromJson(Map<String, dynamic> json) {
    return Stamp(
      id: json['id'] as String,
      placeId: json['placeId'] as String,
      placeName: json['placeName'] as String,
      stampedAt: DateTime.parse(json['stampedAt'] as String),
      combo: (json['combo'] as num).toInt(),
      earnedPoints: (json['earnedPoints'] as num).toInt(),
    );
  }
}
