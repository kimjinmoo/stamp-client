import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stamp_client/core/theme/app_theme.dart';
import 'package:stamp_client/models/user_rank.dart';
import 'package:stamp_client/providers/ranking_provider.dart';
import 'package:stamp_client/screens/ranking_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('2가지 랭킹 기준 및 4가지 기간별 랭킹 산출 로직 단위 테스트', () {
    test('스탬프 랭킹(stamps) 선택 시 스탬프 등록 개수 내림차순 정렬 확인', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(rankingTypeProvider.notifier).setType(RankingType.stamps);
      container.read(rankingPeriodProvider.notifier).setPeriod(RankingPeriod.monthly);

      final list = container.read(rankingListProvider);
      expect(list.isNotEmpty, isTrue);

      for (int i = 0; i < list.length - 1; i++) {
        expect(list[i].stampCount >= list[i + 1].stampCount, isTrue,
            reason: 'index $i (${list[i].stampCount}) should be >= ${list[i + 1].stampCount}');
      }
    });

    test('콤보 랭킹(combo) 선택 시 최고 콤보 배수 내림차순 정렬 확인', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(rankingTypeProvider.notifier).setType(RankingType.combo);
      container.read(rankingPeriodProvider.notifier).setPeriod(RankingPeriod.monthly);

      final list = container.read(rankingListProvider);
      expect(list.isNotEmpty, isTrue);

      for (int i = 0; i < list.length - 1; i++) {
        expect(list[i].maxCombo >= list[i + 1].maxCombo, isTrue,
            reason: 'index $i (${list[i].maxCombo}) should be >= ${list[i + 1].maxCombo}');
      }
    });

    test('기간(일별, 주별, 월별, 년별) 변경에 따라 1위 유저의 지표가 정상 갱신되는지 확인', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(rankingTypeProvider.notifier).setType(RankingType.stamps);

      container.read(rankingPeriodProvider.notifier).setPeriod(RankingPeriod.daily);
      final dailyTop = container.read(rankingListProvider).first;

      container.read(rankingPeriodProvider.notifier).setPeriod(RankingPeriod.yearly);
      final yearlyTop = container.read(rankingListProvider).first;

      // 연간 스탬프 개수가 일별 스탬프 개수보다 커야 함
      expect(yearlyTop.stampCount > dailyTop.stampCount, isTrue);
    });
  });

  group('랭킹 화면 UI 인터랙션 위젯 테스트', () {
    testWidgets('상단 2단 탭 및 4단 기간 필터 탭 터치 시 정상 전환 동작', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const RankingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 초기 탭 확인
      expect(find.text('🏷️ 스탬프 랭킹'), findsOneWidget);
      expect(find.text('⚡ 콤보 랭킹'), findsOneWidget);
      expect(find.text('TOP 3 STAMP MASTERS'), findsOneWidget);

      // 4단 기간 필터 렌더링 확인
      expect(find.text('일별'), findsOneWidget);
      expect(find.text('주별'), findsOneWidget);
      expect(find.text('월별'), findsOneWidget);
      expect(find.text('년별'), findsOneWidget);

      // '⚡ 콤보 랭킹' 탭 터치
      await tester.tap(find.text('⚡ 콤보 랭킹'));
      await tester.pumpAndSettle();

      // 포디움 헤더가 콤보 마스터로 전환되었는지 확인
      expect(find.text('TOP 3 COMBO MASTERS'), findsOneWidget);

      // '일별' 필터 터치
      await tester.tap(find.text('일별'));
      await tester.pumpAndSettle();
      expect(find.text('내 일별 순위'), findsOneWidget);

      // '주별' 필터 터치
      await tester.tap(find.text('주별'));
      await tester.pumpAndSettle();
      expect(find.text('내 주별 순위'), findsOneWidget);
    });
  });
}
