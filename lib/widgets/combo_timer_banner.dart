import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../providers/stamp_provider.dart';

class ComboTimerBanner extends StatelessWidget {
  final StampState stampState;

  const ComboTimerBanner({
    super.key,
    required this.stampState,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = stampState.isComboActive;
    final progress = stampState.comboProgress;

    // 게이지 색상: 남은 시간이 적을수록 민트 -> 코랄로 전환
    final gaugeColor = progress < 0.25 ? AppColors.primary : AppColors.secondary;
    final gaugeBgColor = progress < 0.25 ? AppColors.primarySoft : AppColors.secondarySoft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: isActive ? gaugeColor.withValues(alpha: 0.35) : AppColors.hairline,
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: isActive
            ? (progress < 0.25 ? AppColors.primaryGlow : AppColors.mintGlow)
            : AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? gaugeColor : AppColors.surfaceStrong,
                      borderRadius: AppRadius.roundedFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? Icons.bolt_rounded : Icons.timer_outlined,
                          size: 14,
                          color: isActive ? AppColors.onPrimary : AppColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'COMBO x${stampState.currentCombo}' : 'COMBO READY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isActive ? AppColors.onPrimary : AppColors.muted,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: AppRadius.roundedFull,
                      ),
                      child: Text(
                        '+${stampState.currentCombo * 100}P 배수',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              // 실시간 카운트다운 타이머
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: isActive ? gaugeColor : AppColors.mutedSoft,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isActive ? stampState.formattedRemainingTime : '--:--',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isActive ? gaugeColor : AppColors.mutedSoft,
                      letterSpacing: -0.5,
                      fontFeatures: AppTheme.tabularFigures,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 프로그레스 게이지 바
          ClipRRect(
            borderRadius: AppRadius.roundedFull,
            child: Stack(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  color: gaugeBgColor,
                ),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  widthFactor: progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: progress < 0.25
                            ? [AppColors.primary, AppColors.primaryActive]
                            : [AppColors.secondary, const Color(0xFF00B887)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isActive
                ? '제한 시간 내 다음 스탬프를 찍으면 콤보가 유지되고 더 많은 점수를 얻어요!'
                : 'QR 코드를 스캔해 스탬프를 찍으면 콤보 카운트다운이 시작됩니다.',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
