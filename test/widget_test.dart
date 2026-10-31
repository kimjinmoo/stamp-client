import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stamp_client/main.dart';
import 'package:stamp_client/models/qr_payload.dart';
import 'package:stamp_client/services/qr_security_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('동적 보안 QR(TOTP HMAC-SHA256) 검증 테스트', () {
    test('유효한 타임 윈도우 토큰은 검증 성공해야 한다', () {
      final validPayload = QrSecurityService.createValidSimulationPayload();
      final isValid = QrSecurityService.verifyQrPayload(validPayload);
      expect(isValid, isTrue);
    });

    test('직전 30초 윈도우(currentWindow - 1) 토큰도 허용되어야 한다', () {
      const placeId = 'STORE_SEOUL_001';
      final currentWindow = QrSecurityService.getCurrentWindow();
      final prevToken = QrSecurityService.generateToken(placeId, currentWindow - 1);

      final payload = QrPayload(
        placeId: placeId,
        placeName: '강남 본점',
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        token: prevToken,
      );

      final isValid = QrSecurityService.verifyQrPayload(payload);
      expect(isValid, isTrue);
    });

    test('위조되거나 30초 이상 지난 만료된 토큰은 검증 실패해야 한다', () {
      final invalidPayload = QrSecurityService.createInvalidSimulationPayload();
      final isValid = QrSecurityService.verifyQrPayload(invalidPayload);
      expect(isValid, isFalse);
    });
  });

  group('앱 위젯 렌더링 스모크 테스트', () {
    testWidgets('앱 정상 시작 및 스탬프 보드 타이틀 렌더링 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: StampClientApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 메인 앱바 타이틀 확인
      expect(find.text('스탬프 투어 & 콤보'), findsOneWidget);
      // 상단 벤토 카드 확인
      expect(find.text('내 총점'), findsOneWidget);
      expect(find.text('현재 콤보'), findsOneWidget);
      // FAB 확인
      expect(find.text('QR 스탬프 찍기'), findsOneWidget);
    });
  });
}
