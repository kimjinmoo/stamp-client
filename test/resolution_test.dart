import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stamp_client/core/theme/app_theme.dart';
import 'package:stamp_client/models/stamp.dart';
import 'package:stamp_client/providers/stamp_provider.dart';
import 'package:stamp_client/screens/main_navigation_screen.dart';
import 'package:stamp_client/screens/profile_screen.dart';
import 'package:stamp_client/screens/qr_scan_screen.dart';
import 'package:stamp_client/screens/ranking_screen.dart';
import 'package:stamp_client/screens/splash_screen.dart';
import 'package:stamp_client/screens/stamp_home_screen.dart';
import 'package:stamp_client/widgets/stamp_success_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // 대표적인 다양한 폰 해상도 (논리 픽셀 기준)
  // 1. 소형/컴팩트: iPhone SE 1st (320x568), 구형/보급형 안드로이드 (360x640)
  // 2. 대중적인 표준: Galaxy A/S 시리즈 기본 (360x800), iPhone SE 2/3 (375x667), iPhone mini/X (375x812)
  // 3. 최신 플래그십 표준: iPhone 12~16 (390x844, 393x852), Galaxy S23/S24 / Pixel (412x915)
  // 4. 대화면/Pro Max: iPhone 14/15/16 Pro Max (430x932)
  final testSizes = [
    const Size(320, 568), // iPhone SE 1세대 / 초소형 기기
    const Size(360, 640), // 360p 보급형 안드로이드
    const Size(360, 800), // 삼성 갤럭시 A/기본 시리즈 표준
    const Size(375, 667), // iPhone SE 2/3세대 (아이폰 6/7/8 크기)
    const Size(375, 812), // iPhone mini / X / 11 Pro
    const Size(390, 844), // iPhone 12 / 13 / 14
    const Size(412, 915), // Galaxy S23/S24 / Pixel 7/8
    const Size(430, 932), // iPhone 14/15/16 Pro Max
  ];

  for (final size in testSizes) {
    group('폰 해상도 검증 [${size.width.toInt()}x${size.height.toInt()}]', () {
      testWidgets('메인 내비게이션 탭 오버플로우 없음', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const MainNavigationScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('스플래시 화면 애니메이션 오버플로우 없음', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const SplashScreen(duration: Duration(milliseconds: 300)),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 150));
        expect(tester.takeException(), isNull);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('스탬프 홈 화면(콤보 활성 & 대시보드) 오버플로우 없음', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final container = ProviderContainer();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const StampHomeScreen(),
            ),
          ),
        );

        // 스탬프 적립 및 콤보 활성화 시뮬레이션
        await container.read(stampProvider.notifier).processQrCode(
          '{"placeId":"STORE_SEOUL_001","placeName":"강남 본점 플래그십 스토어","timestamp":${DateTime.now().millisecondsSinceEpoch ~/ 1000},"token":""}',
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        container.dispose();
      });

      testWidgets('랭킹 화면(포디움 & 순위 리스트) 오버플로우 없음', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const RankingScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('내 정보 & 동기화 화면(세그먼트 버튼 & 리스트) 오버플로우 없음', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const ProfileScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('QR 스캔 화면(가이드 프레임 & 시뮬레이션 패널) 오버플로우 없음', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const QrScanScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('스탬프 적립 성공 팝업 다이얼로그 오버플로우 없음', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  StampSuccessDialog.show(
                    context,
                    Stamp(
                      id: 'test',
                      placeId: 'STORE_001',
                      placeName: '홍대입구역 스페셜 팝업 스토어 1호점',
                      earnedPoints: 1200,
                      combo: 5,
                      stampedAt: DateTime.now(),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    });
  }

  // 시스템 텍스트 크기 확대(접근성 1.3배 글꼴) 테스트
  group('접근성 대형 폰트(TextScaler 1.3배) 환경 검증', () {
    testWidgets('375x667(SE)에서 글자 확대 시에도 전체 화면 정상 렌더링', (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(375, 667),
            textScaler: TextScaler.linear(1.3),
          ),
          child: ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const MainNavigationScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
