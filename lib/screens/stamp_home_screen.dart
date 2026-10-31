import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../providers/stamp_provider.dart';
import '../widgets/bento_stat_card.dart';
import '../widgets/combo_timer_banner.dart';
import '../widgets/stamp_slot_card.dart';
import 'qr_scan_screen.dart';

class StampHomeScreen extends ConsumerWidget {
  const StampHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stampState = ref.watch(stampProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: AppRadius.roundedSm,
              ),
              child: const Icon(Icons.stars_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              '스탬프 투어 & 콤보',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.ink),
            tooltip: 'QR 스캔',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QrScanScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // 새로고침
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 실시간 콤보 카운트다운 타이머 배너
              ComboTimerBanner(stampState: stampState),
              const SizedBox(height: 16),

              // 2. 벤토 그리드 대시보드 (2x2)
              Row(
                children: [
                  Expanded(
                    child: BentoStatCard(
                      title: '내 총점',
                      value: '${stampState.totalScore} P',
                      subtitle: '스탬프 적립 점수',
                      icon: Icons.monetization_on_rounded,
                      iconColor: AppColors.accentPop,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BentoStatCard(
                      title: '현재 콤보',
                      value: stampState.isComboActive ? '${stampState.currentCombo}x' : '0x',
                      subtitle: stampState.isComboActive ? '연속 보너스 적용 중' : '비활성 상태',
                      icon: Icons.bolt_rounded,
                      iconColor: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: BentoStatCard(
                      title: '최고 기록',
                      value: '${stampState.maxCombo} Combo',
                      subtitle: '역대 최대 달성',
                      icon: Icons.emoji_events_rounded,
                      iconColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BentoStatCard(
                      title: '모은 스탬프',
                      value: '${stampState.stamps.length} 개',
                      subtitle: '방문 완료 매장',
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.ink,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 3. 내 스탬프 보드 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '내 스탬프 보드',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '총 ${stampState.stamps.length}회 적립',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. 스탬프 목록 또는 Empty State
              if (stampState.stamps.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: AppRadius.roundedLg,
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.confirmation_number_outlined,
                          size: 36,
                          color: AppColors.mutedSoft,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '아직 획득한 스탬프가 없습니다',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '하단의 [QR 스탬프 찍기] 버튼을 눌러\n매장 QR 코드를 스캔하고 콤보를 시작해보세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stampState.stamps.length,
                  itemBuilder: (context, index) {
                    final stamp = stampState.stamps[index];
                    return StampSlotCard(stamp: stamp);
                  },
                ),

              // FAB 여백
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      // 우측 하단 FAB 버튼 (DESIGN.md: fab-scan-orb / Level 2 Coral Glow)
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.roundedFull,
          boxShadow: AppColors.primaryGlow,
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const QrScanScreen()),
            );
          },
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
          label: const Text(
            'QR 스탬프 찍기',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
