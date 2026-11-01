import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../models/user_rank.dart';
import '../providers/ranking_provider.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingType = ref.watch(rankingTypeProvider);
    final rankingPeriod = ref.watch(rankingPeriodProvider);
    final rankingList = ref.watch(rankingListProvider);
    final myRank = ref.watch(myRankProvider);

    // 1위, 2위, 3위 분리 (포디움용)
    final top1 = rankingList.isNotEmpty ? rankingList[0] : null;
    final top2 = rankingList.length > 1 ? rankingList[1] : null;
    final top3 = rankingList.length > 2 ? rankingList[2] : null;

    // 4위 이하 리스트
    final remainingRanks = rankingList.length > 3 ? rankingList.sublist(3) : <UserRank>[];

    final isStampRank = rankingType == RankingType.stamps;
    final themeColor = isStampRank ? AppColors.secondary : AppColors.primary;
    final themeSoftColor = isStampRank ? AppColors.secondarySoft : AppColors.primarySoft;

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: const Text(
          '스탬프 & 콤보 랭킹',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // 1. 최상단: 랭킹 기준 2단 전환 탭 (스탬프 최다 등록 vs 콤보 게이지 최고)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: AppRadius.roundedLg,
                border: Border.all(color: AppColors.hairline),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeTabButton(
                      context: context,
                      title: '🏷️ 스탬프 랭킹',
                      isSelected: rankingType == RankingType.stamps,
                      selectedColor: AppColors.secondary,
                      onTap: () {
                        ref.read(rankingTypeProvider.notifier).setType(RankingType.stamps);
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildTypeTabButton(
                      context: context,
                      title: '⚡ 콤보 랭킹',
                      isSelected: rankingType == RankingType.combo,
                      selectedColor: AppColors.primary,
                      onTap: () {
                        ref.read(rankingTypeProvider.notifier).setType(RankingType.combo);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. 4가지 기간 필터 바 (일별 / 주별 / 월별 / 년별)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: RankingPeriod.values.map((period) {
                final isSelected = rankingPeriod == period;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () {
                        ref.read(rankingPeriodProvider.notifier).setPeriod(period);
                      },
                      borderRadius: AppRadius.roundedFull,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? themeColor : AppColors.canvas,
                          borderRadius: AppRadius.roundedFull,
                          border: Border.all(
                            color: isSelected ? themeColor : AppColors.hairline,
                          ),
                          boxShadow: isSelected
                              ? (isStampRank ? AppColors.mintGlow : AppColors.primaryGlow)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            period.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppColors.onPrimary : AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 6),

          // 3. 내 순위 요약 배너 (선택된 랭킹 및 기간에 따라 실시간 반영)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: themeSoftColor,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(color: themeColor, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: themeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${myRank.rank}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            '내 ${rankingPeriod.label} 순위',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: themeColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: AppRadius.roundedFull,
                            ),
                            child: Text(
                              isStampRank
                                  ? '총 ${myRank.stampCount}개 스탬프'
                                  : '최고 ${myRank.maxCombo} Combo',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isStampRank
                          ? '${rankingPeriod.sublabel} 누적 점수: ${myRank.totalScore} P · 최고 ${myRank.maxCombo}콤보'
                          : '${rankingPeriod.sublabel} 누적 점수: ${myRank.totalScore} P · 총 ${myRank.stampCount}개 적립',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.body,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  isStampRank ? Icons.confirmation_number_rounded : Icons.bolt_rounded,
                  color: themeColor,
                  size: 22,
                ),
              ],
            ),
          ),

          // 4. 스크롤 영역 (1~3위 포디움 + 4위 이하 리스트)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // 1~3위 포디움 UI
                if (top1 != null) ...[
                  _buildPodium(context, top1, top2, top3, isStampRank),
                  const SizedBox(height: 20),
                ],

                // 전체 순위 섹션 타이틀
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${rankingPeriod.sublabel} 전체 순위',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          isStampRank ? '스탬프 등록순 정렬' : '최고 콤보순 정렬',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // 4위 이하 리스트
                ...remainingRanks.map((user) => _buildRankTile(user, isStampRank)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 랭킹 기준 상단 탭 버튼
  Widget _buildTypeTabButton({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedMd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: AppRadius.roundedMd,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isSelected ? AppColors.onPrimary : AppColors.muted,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  /// 1~3위 상단 포디움 위젯
  Widget _buildPodium(
    BuildContext context,
    UserRank top1,
    UserRank? top2,
    UserRank? top3,
    bool isStampRank,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.hairline),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: isStampRank ? AppColors.secondary : AppColors.accentPop,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isStampRank ? 'TOP 3 STAMP MASTERS' : 'TOP 3 COMBO MASTERS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isStampRank ? AppColors.secondary : AppColors.accentPop,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 2위 (Silver)
              if (top2 != null)
                Expanded(
                  child: _buildPodiumColumn(
                    user: top2,
                    rank: 2,
                    pillarHeight: 88,
                    pillarColor: const Color(0xFFE2E8F0),
                    crownColor: const Color(0xFF94A3B8),
                    isStampRank: isStampRank,
                  ),
                )
              else
                const Spacer(),

              // 1위 (Gold) - 가장 높고 화려하게
              Expanded(
                child: _buildPodiumColumn(
                  user: top1,
                  rank: 1,
                  pillarHeight: 116,
                  pillarColor: const Color(0xFFFFF3C4),
                  crownColor: AppColors.accentPop,
                  isFirst: true,
                  isStampRank: isStampRank,
                ),
              ),

              // 3위 (Bronze)
              if (top3 != null)
                Expanded(
                  child: _buildPodiumColumn(
                    user: top3,
                    rank: 3,
                    pillarHeight: 70,
                    pillarColor: const Color(0xFFFFEDD5),
                    crownColor: const Color(0xFFD97706),
                    isStampRank: isStampRank,
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  /// 개별 포디움 기둥 및 아바타
  Widget _buildPodiumColumn({
    required UserRank user,
    required int rank,
    required double pillarHeight,
    required Color pillarColor,
    required Color crownColor,
    required bool isStampRank,
    bool isFirst = false,
  }) {
    final mainValue = isStampRank ? '${user.stampCount}개' : '${user.maxCombo}x';
    final highlightColor = isStampRank ? AppColors.secondary : AppColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 왕관 아이콘
        Icon(
          isFirst ? Icons.workspace_premium_rounded : Icons.star_rounded,
          color: crownColor,
          size: isFirst ? 28 : 20,
        ),
        const SizedBox(height: 4),

        // 원형 아바타
        Container(
          width: isFirst ? 56 : 44,
          height: isFirst ? 56 : 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: user.isCurrentUser ? AppColors.primarySoft : AppColors.surfaceSoft,
            border: Border.all(
              color: user.isCurrentUser ? highlightColor : crownColor,
              width: isFirst ? 2.5 : 1.5,
            ),
          ),
          child: Center(
            child: Text(
              user.avatarEmoji,
              style: TextStyle(fontSize: isFirst ? 24 : 18),
            ),
          ),
        ),
        const SizedBox(height: 6),

        // 닉네임
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            user.userName,
            style: TextStyle(
              fontSize: isFirst ? 12 : 11,
              fontWeight: user.isCurrentUser ? FontWeight.w800 : FontWeight.w700,
              color: user.isCurrentUser ? highlightColor : AppColors.ink,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 2),

        // 핵심 성과 지표 뱃지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            color: isFirst
                ? (isStampRank ? AppColors.secondarySoft : const Color(0xFFFEF3C7))
                : AppColors.surfaceSoft,
            borderRadius: AppRadius.roundedFull,
          ),
          child: Text(
            mainValue,
            style: TextStyle(
              fontSize: isFirst ? 12 : 11,
              fontWeight: FontWeight.w800,
              color: isFirst
                  ? (isStampRank ? AppColors.secondary : const Color(0xFFB45309))
                  : AppColors.ink,
            ),
          ),
        ),
        const SizedBox(height: 2),

        // 서브 점수
        Text(
          '${user.totalScore}P',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),

        // 포디움 기둥
        Container(
          height: pillarHeight,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: pillarColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Center(
            child: Text(
              '$rank위',
              style: TextStyle(
                fontSize: isFirst ? 19 : 15,
                fontWeight: FontWeight.w900,
                color: isFirst ? const Color(0xFFB45309) : AppColors.body,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 4위 이하 랭킹 타일
  Widget _buildRankTile(UserRank user, bool isStampRank) {
    final isMe = user.isCurrentUser;
    final themeColor = isStampRank ? AppColors.secondary : AppColors.primary;
    final themeSoft = isStampRank ? AppColors.secondarySoft : AppColors.primarySoft;

    final mainMetric = isStampRank ? '${user.stampCount}개 스탬프' : '${user.maxCombo}x 콤보';
    final subMetric = isStampRank
        ? '최고 ${user.maxCombo}콤보 · ${user.totalScore} P'
        : '총 ${user.stampCount}개 적립 · ${user.totalScore} P';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? themeSoft : AppColors.canvas,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: isMe ? themeColor : AppColors.hairline,
          width: isMe ? 1.5 : 1.0,
        ),
        boxShadow: isMe
            ? (isStampRank ? AppColors.mintGlow : AppColors.primaryGlow)
            : AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // 순위 숫자
          SizedBox(
            width: 28,
            child: Text(
              '${user.rank}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isMe ? themeColor : AppColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),

          // 아바타
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.avatarEmoji,
                style: const TextStyle(fontSize: 19),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 닉네임 & 상세 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.userName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isMe ? FontWeight.w800 : FontWeight.w700,
                          color: isMe ? themeColor : AppColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: AppRadius.roundedFull,
                        ),
                        child: const Text(
                          'ME',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subMetric,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 우측 핵심 지표 뱃지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isMe ? AppColors.canvas : themeSoft,
              borderRadius: AppRadius.roundedFull,
              border: Border.all(color: themeColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              mainMetric,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: themeColor,
                fontFeatures: AppTheme.tabularFigures,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
