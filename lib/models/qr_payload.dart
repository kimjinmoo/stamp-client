import 'dart:convert';

class QrPayload {
  final String placeId;
  final String placeName;
  final int timestamp;
  final String token;

  const QrPayload({
    required this.placeId,
    required this.placeName,
    required this.timestamp,
    required this.token,
  });

  Map<String, dynamic> toJson() => {
        'placeId': placeId,
        'placeName': placeName,
        'timestamp': timestamp,
        'token': token,
      };

  String toJsonString() => jsonEncode(toJson());

  factory QrPayload.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('placeId') ||
        !json.containsKey('placeName') ||
        !json.containsKey('timestamp') ||
        !json.containsKey('token')) {
      throw const FormatException('QR 페이로드 필수 필드가 누락되었습니다.');
    }
    return QrPayload(
      placeId: json['placeId'] as String,
      placeName: json['placeName'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      token: json['token'] as String,
    );
  }

  factory QrPayload.fromJsonString(String rawString) {
    final dynamic decoded = jsonDecode(rawString.trim());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('올바른 JSON 객체 형식이 아닙니다.');
    }
    return QrPayload.fromJson(decoded);
  }
}
