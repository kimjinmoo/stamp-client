import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/qr_payload.dart';

/// Admin 앱과 100% 호환되는 동적 보안 QR(TOTP/HMAC-SHA256) 검증 서비스
class QrSecurityService {
  QrSecurityService._();

  /// 1. 공유 비밀키 (Shared Secret) - Admin 앱과 동일
  static const String sharedSecret = 'STAMP_SECRET_KEY_2026_V1';

  /// 시간 윈도우 크기 (30초)
  static const int timeWindowSeconds = 30;

  /// HMAC-SHA256 토큰 생성 ($placeId:$window)
  static String generateToken(String placeId, int window) {
    final message = '$placeId:$window';
    final key = utf8.encode(sharedSecret);
    final bytes = utf8.encode(message);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }

  /// 현재 시간 기준의 타임 윈도우 계산
  static int getCurrentWindow([DateTime? time]) {
    final now = time ?? DateTime.now();
    final epochSeconds = now.millisecondsSinceEpoch ~/ 1000;
    return epochSeconds ~/ timeWindowSeconds;
  }

  /// QR 페이로드 동적 보안 검증
  /// currentWindow 및 currentWindow - 1 (직전 30초 윈도우) 검증 허용
  static bool verifyQrPayload(QrPayload payload) {
    final currentWindow = getCurrentWindow();
    final tokenCurrent = generateToken(payload.placeId, currentWindow);
    final tokenPrev = generateToken(payload.placeId, currentWindow - 1);

    final normalizedInput = payload.token.trim().toLowerCase();
    return (normalizedInput == tokenCurrent.toLowerCase() ||
        normalizedInput == tokenPrev.toLowerCase());
  }

  /// 시뮬레이션 및 테스트용 매장 목록
  static const List<Map<String, String>> sampleStores = [
    {'id': 'STORE_SEOUL_001', 'name': '강남 본점'},
    {'id': 'STORE_SEOUL_002', 'name': '홍대 아틀리에'},
    {'id': 'STORE_SEOUL_003', 'name': '성수 플래그십'},
    {'id': 'STORE_SEOUL_004', 'name': '여의도 더현대점'},
    {'id': 'STORE_SEOUL_005', 'name': '잠실 롯데월드몰점'},
    {'id': 'STORE_BUSAN_001', 'name': '해운대 센텀점'},
    {'id': 'STORE_JEJU_001', 'name': '제주 애월 오션스토어'},
  ];

  static int _sampleIndex = 0;

  /// 테스트용 유효 QR 페이로드 생성 (시뮬레이션용)
  static QrPayload createValidSimulationPayload() {
    final store = sampleStores[_sampleIndex % sampleStores.length];
    _sampleIndex++;

    final now = DateTime.now();
    final window = getCurrentWindow(now);
    final token = generateToken(store['id']!, window);

    return QrPayload(
      placeId: store['id']!,
      placeName: store['name']!,
      timestamp: now.millisecondsSinceEpoch ~/ 1000,
      token: token,
    );
  }

  /// 테스트용 위조/만료된 QR 페이로드 생성 (위조 방어 검증용)
  static QrPayload createInvalidSimulationPayload() {
    final store = sampleStores[0];
    final now = DateTime.now();
    // 5분 전(만료) 또는 잘못된 토큰
    final expiredWindow = getCurrentWindow(now) - 10;
    final fakeToken = generateToken('STORE_FAKE_HACKER', expiredWindow);

    return QrPayload(
      placeId: store['id']!,
      placeName: store['name']!,
      timestamp: (now.millisecondsSinceEpoch ~/ 1000) - 300,
      token: fakeToken,
    );
  }
}
