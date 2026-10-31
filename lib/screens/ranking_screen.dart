import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../models/user_rank.dart';
import '../providers/ranking_provider.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingList = ref.watch(rankingListProvider);
    final myRank = ref.watch(myRankProvider);

    // 1위, 2위, 3위 분리 (포디움용)
    final top1 = rankingList.isNotEmpty ? rankingList[0] : null;
    final top2 = rankingList.length > 1 ? rankingList[1] : null;
    final top3 = rankingList.length > 2 ? rankingList[2] : null;

    // 4위 이하 리스트
    final remainingRanks = rankingList.length > 3 ? rankingList.sublist(3) : <UserRank>[];

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: const Text(
          '콤보 랭킹 보드',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // 내 순위 요약 배너 (상단 고정 하이라이트)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${myRank.rank}',
                      style: const TextStyle(
                        fontSize: 16,
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
                      Row(
                        children: [
                          const Text(
                            '내 현재 순위',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: AppRadius.roundedFull,
                            ),
                            child: Text(
                              '최고 ${myRank.maxCombo} Combo',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '총 획득 점수: ${myRank.totalScore} P',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.body,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_upward_rounded, color: AppColors.secondary, size: 20),
              ],
            ),
          ),

          // 스크롤 영역 (포디움 + 리스트)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // 1~3위 포디움 UI
                if (top1 != null) ...[
                  _buildPodium(context, top1, top2, top3),
                  const SizedBox(height: 24),
                ],

                // 전체 순위 섹션 타이틀
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Text(
                    '전체 랭킹 순위',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),

                // 4위 이하 리스트
                ...remainingRanks.map((user) => _buildRankTile(user)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 1~3위 상단 포디움 위젯
  Widget _buildPodium(
    BuildContext context,
    UserRank top1,
    UserRank? top2,
    UserRank? top3,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.hairline),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          const Text(
            '🏆 TOP 3 COMBO MASTERS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.accentPop,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
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
    bool isFirst = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 왕관 아이콘 (1위는 골드 왕관)
        Icon(
          isFirst ? Icons.workspace_premium_rounded : Icons.star_rounded,
          color: crownColor,
          size: isFirst ? 30 : 22,
        ),
        const SizedBox(height: 4),

        // 원형 아바타
        Container(
          width: isFirst ? 58 : 46,
          height: isFirst ? 58 : 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: user.isCurrentUser ? AppColors.primarySoft : AppColors.surfaceSoft,
            border: Border.all(
              color: user.isCurrentUser ? AppColors.primary : crownColor,
              width: isFirst ? 2.5 : 1.5,
            ),
          ),
          child: Center(
            child: Text(
              user.avatarEmoji,
              style: TextStyle(fontSize: isFirst ? 26 : 20),
            ),
          ),
        ),
        const SizedBox(height: 6),

        // 닉네임
        Text(
          user.userName,
          style: TextStyle(
            fontSize: isFirst ? 13 : 11,
            fontWeight: user.isCurrentUser ? FontWeight.w800 : FontWeight.w700,
            color: user.isCurrentUser ? AppColors.primary : AppColors.ink,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),

        // 점수
        Text(
          '${user.totalScore}P',
          style: TextStyle(
            fontSize: isFirst ? 13 : 11,
            fontWeight: FontWeight.w800,
            color: isFirst ? AppColors.ink : AppColors.muted,
          ),
        ),
        const SizedBox(height: 8),

        // 포디움 기둥
        Container(
          height: pillarHeight,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: pillarColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              '$rank위',
              style: TextStyle(
                fontSize: isFirst ? 20 : 16,
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
  Widget _buildRankTile(UserRank user) {
    final isMe = user.isCurrentUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primarySoft : AppColors.canvas,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: isMe ? AppColors.primary : AppColors.hairline,
          width: isMe ? 1.5 : 1.0,
        ),
        boxShadow: isMe ? AppColors.primaryGlow : AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // 순위 숫자
          SizedBox(
            width: 32,
            child: Text(
              '${user.rank}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isMe ? AppColors.primary : AppColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),

          // 아바타
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.avatarEmoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 닉네임 & 콤보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.userName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isMe ? FontWeight.w800 : FontWeight.w700,
                        color: isMe ? AppColors.primary : AppColors.ink,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadius.roundedFull,
                        ),
                        child: const Text(
                          'ME',
                          style: TextStyle(
                            fontSize: 10,
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
                  '최고 연속 ${user.maxCombo} 콤보',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),

          // 점수
          Text(
            '${user.totalScore} P',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isMe ? AppColors.primary : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
