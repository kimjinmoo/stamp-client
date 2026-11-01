import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stamp_client/core/theme/app_theme.dart';
import 'package:stamp_client/screens/main_navigation_screen.dart';
import 'package:stamp_client/screens/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('스플래시 화면 애니메이션 및 전환 테스트', () {
    testWidgets('스플래시 화면 렌더링 및 도장/타이틀 요소 표시 확인', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SplashScreen(
            duration: Duration(milliseconds: 1500),
          ),
        ),
      );

      // 초기 빌드
      await tester.pump(const Duration(milliseconds: 100));

      // 엠블럼 내 번개 아이콘 확인
      expect(find.byIcon(Icons.bolt_rounded), findsWidgets);

      // 타이틀 페이드인 단계 진행
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('스탬프 투어 & 콤보'), findsOneWidget);
      expect(find.text('찍을수록 커지는 연속 콤보 랭킹 혜택'), findsOneWidget);
    });

    testWidgets('지정된 시간 후 메인 화면(MainNavigationScreen)으로 자동 전환', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(
              duration: Duration(milliseconds: 800),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(MainNavigationScreen), findsNothing);

      // 애니메이션 및 대기 시간 경과
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      // 메인 화면으로 전환 완료 확인
      expect(find.byType(MainNavigationScreen), findsOneWidget);
    });

    testWidgets('초소형 320x568 해상도에서도 스플래시 화면 오버플로우 없음', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SplashScreen(
            duration: Duration(milliseconds: 500),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });
  });
}
