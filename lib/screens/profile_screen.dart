import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../providers/ranking_provider.dart';
import '../providers/stamp_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isSyncing = false;

  /// client.md 명세: 서버 올리기 UI 전용 핸들러 함수
  Future<void> _handleSyncToServer() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);

    // 1. "서버에 데이터를 업로드하는 중..." 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          backgroundColor: AppColors.canvas,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(width: 20),
                const Expanded(
                  child: Text(
                    '서버에 데이터를 업로드하는 중...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // 2. 가상 서버 동기화 실행
    await ref.read(stampProvider.notifier).syncToServer();

    if (!mounted) return;

    // 로딩 다이얼로그 닫기
    Navigator.of(context, rootNavigator: true).pop();
    setState(() => _isSyncing = false);

    // 3. "업로드 버튼 동작 확인 완료 (서버 연동 예정)" 스낵바 알림
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.cloud_done_rounded, color: AppColors.onPrimary, size: 20),
            SizedBox(width: 10),
            Text(
              '업로드 버튼 동작 확인 완료 (서버 연동 예정)',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 스탬프 전체 초기화 확인 다이얼로그
  void _confirmClearStamps() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
        backgroundColor: AppColors.canvas,
        title: const Text(
          '스탬프 전체 초기화',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: const Text(
          '모든 스탬프 내역, 누적 포인트, 콤보 기록이 영구 삭제됩니다.\n정말 초기화하시겠습니까?',
          style: TextStyle(color: AppColors.body, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(stampProvider.notifier).clearAllStamps();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('모든 스탬프 및 점수 기록이 초기화되었습니다.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
            ),
            child: const Text('초기화 실행'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stampState = ref.watch(stampProvider);
    final myRank = ref.watch(myRankProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: const Text(
          '내 정보 & 동기화',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 프로필 카드
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(color: AppColors.hairline),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Center(
                    child: Text('👑', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          const Text(
                            '나 (스탬퍼)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondarySoft,
                              borderRadius: AppRadius.roundedFull,
                            ),
                            child: Text(
                              '랭킹 ${myRank.rank}위',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '클라이언트 유저 앱 정회원',
                        style: TextStyle(fontSize: 13, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 서버 올리기 (UI 전용) - client.md 요구사항: 눈에 잘 띄는 버튼
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF0F1), Color(0xFFFFE4E6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.roundedLg,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              boxShadow: AppColors.primaryGlow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.cloud_upload_rounded, color: AppColors.primary, size: 24),
                    SizedBox(width: 8),
                    Text(
                      '서버 클라우드 동기화',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '오프라인에 저장된 내 스탬프 및 랭킹 점수를 중앙 서버로 안전하게 업로드합니다.',
                  style: TextStyle(fontSize: 13, color: AppColors.body, height: 1.4),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : _handleSyncToServer,
                    icon: const Icon(Icons.sync_rounded, size: 20),
                    label: const Text(
                      '서버에 내 스탬프/랭킹 올리기',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 콤보 제한 시간 설정 (client.md 명세: 1분/10분/30분 등 변경 가능)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(color: AppColors.hairline),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timelapse_rounded, color: AppColors.secondary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '콤보 유지 제한 시간 설정',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '이전 스탬프 후 다음 스탬프까지 콤보가 유지되는 허용 시간입니다. (기본: 10분)',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 320;
                    return SegmentedButton<int>(
                      segments: [
                        ButtonSegment(
                          value: 1,
                          label: Text(isCompact ? '1분' : '1분 (테스트)'),
                        ),
                        const ButtonSegment(value: 5, label: Text('5분')),
                        ButtonSegment(
                          value: 10,
                          label: Text(isCompact ? '10분' : '10분 (기본)'),
                        ),
                        const ButtonSegment(value: 30, label: Text('30분')),
                      ],
                      selected: {stampState.comboDurationMinutes},
                      onSelectionChanged: (Set<int> newSelection) {
                        ref.read(stampProvider.notifier).setComboDuration(newSelection.first);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('콤보 유지 시간이 ${newSelection.first}분으로 설정되었습니다.'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        textStyle: WidgetStateProperty.all(
                          TextStyle(
                            fontSize: isCompact ? 11 : 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 테스트 편의 기능 섹션 (client.md 명세: [콤보 타이머 리셋], [스탬프 초기화])
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(color: AppColors.hairline),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bug_report_rounded, color: AppColors.muted, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '개발 및 테스트 편의 도구',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // 콤보 타이머 리셋 버튼
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(stampProvider.notifier).resetComboTimer();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('콤보 타이머가 리셋(만료)되었습니다. 다음 스탬프는 1콤보부터 시작합니다.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.timer_off_rounded, size: 18),
                    label: const Text('콤보 타이머 즉시 리셋 (만료)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // 스탬프 초기화 버튼
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: _confirmClearStamps,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    label: const Text(
                      '스탬프 및 기록 전체 초기화',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 앱 버전 정보
          const Center(
            child: Text(
              'Stamp Client App v1.0.0 (Admin TOTP-SHA256 호환)',
              style: TextStyle(fontSize: 12, color: AppColors.mutedSoft),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
