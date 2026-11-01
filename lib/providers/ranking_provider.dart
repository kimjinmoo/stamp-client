import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_rank.dart';
import 'stamp_provider.dart';

/// 선택된 랭킹 타입 Notifier (스탬프 랭킹 vs 콤보 랭킹)
class RankingTypeNotifier extends Notifier<RankingType> {
  @override
  RankingType build() => RankingType.stamps;

  void setType(RankingType type) {
    state = type;
  }
}

final rankingTypeProvider =
    NotifierProvider<RankingTypeNotifier, RankingType>(RankingTypeNotifier.new);

/// 선택된 랭킹 기간 Notifier (일별, 주별, 월별, 년별)
class RankingPeriodNotifier extends Notifier<RankingPeriod> {
  @override
  RankingPeriod build() => RankingPeriod.monthly;

  void setPeriod(RankingPeriod period) {
    state = period;
  }
}

final rankingPeriodProvider =
    NotifierProvider<RankingPeriodNotifier, RankingPeriod>(RankingPeriodNotifier.new);

/// 가상 유저 10명의 기준 프로필
class _MockProfile {
  final String id;
  final String userName;
  final String avatarEmoji;
  // 기간별 (일별, 주별, 월별, 년별) 스탬프수, 최고콤보, 총점
  final Map<RankingPeriod, _Stat> stats;

  const _MockProfile({
    required this.id,
    required this.userName,
    required this.avatarEmoji,
    required this.stats,
  });
}

class _Stat {
  final int stampCount;
  final int maxCombo;
  final int totalScore;

  const _Stat({
    required this.stampCount,
    required this.maxCombo,
    required this.totalScore,
  });
}

final List<_MockProfile> _mockProfiles = [
  const _MockProfile(
    id: 'user_01',
    userName: '스탬프헌터민우',
    avatarEmoji: '⚡',
    stats: {
      RankingPeriod.daily: _Stat(stampCount: 5, maxCombo: 7, totalScore: 1400),
      RankingPeriod.weekly: _Stat(stampCount: 14, maxCombo: 9, totalScore: 3800),
      RankingPeriod.monthly: _Stat(stampCount: 28, maxCombo: 11, totalScore: 8400),
      RankingPeriod.yearly: _Stat(stampCount: 120, maxCombo: 14, totalScore: 36000),
    },
  ),
  const _MockProfile(
    id: 'user_02',
    userName: '카페투어러지혜',
    avatarEmoji: '☕',
    stats: {
      RankingPeriod.daily: _Stat(stampCount: 4, maxCombo: 5, totalScore: 900),
      RankingPeriod.weekly: _Stat(stampCount: 16, maxCombo: 6, totalScore: 3500),
      RankingPeriod.monthly: _Stat(stampCount: 32, maxCombo: 8, totalScore: 7800),
      RankingPeriod.yearly: _Stat(stampCount: 135, maxCombo: 10, totalScore: 34000),
    },
  ),
  const _MockProfile(
    id: 'user_03',
    userName: '성수동산책가',
    avatarEmoji: '🌿',
    stats: {
      RankingPeriod.daily: _Stat(stampCount: 3, maxCombo: 6, totalScore: 800),
      RankingPeriod.weekly: _Stat(stampCount: 11, maxCombo: 7, totalScore: 2800),
      RankingPeriod.monthly: _Stat(stampCount: 24, maxCombo: 9, totalScore: 6600),
      RankingPeriod.yearly: _Stat(stampCount: 98, maxCombo: 12, totalScore: 29000),
    },
  ),
  const _MockProfile(
    id: 'user_04',
    userName: '주말러너동현',
    avatarEmoji: '🏃',
    stats: {
      RankingPeriod.daily: _Stat(stampCount: 6, maxCombo: 4, totalScore: 1100),
      RankingPeriod.weekly: _Stat(stampCount: 12, maxCombo: 8, totalScore: 3100),
      RankingPeriod.monthly: _Stat(stampCount: 22, maxCombo: 8, totalScore: 5900),
      RankingPeriod.yearly: _Stat(stampCount: 88, maxCombo: 11, totalScore: 25000),
    },
  ),
  const _MockProfile(
    id: 'user_05',
    userName: '디저트원정대',
    avatarEmoji: '🍰',
    stats: {
      RankingPeriod.daily: _Stat(stampCount: 2, maxCombo: 3, totalScore: 400),
      RankingPeriod.weekly: _Stat(stampCount: 9, maxCombo: 5, totalScore: 2100),
      RankingPeriod.monthly: _Stat(stampCount: 21, maxCombo: 7, totalScore: 5400),
      RankingPeriod.yearly: _Stat(stampCount: 82, maxCombo: 9, totalScore: 22000),
    },
  ),
  const _MockProfile(
    id: 'user_06',
    userName: '핫플마스터수빈',
    avatarEmoji: '🔥',
    stats: {
      RankingPeriod.daily: _Stat(stampCount: 3, maxCombo: 8, totalScore: 1200),
      RankingPeriod.weekly: _Stat(stampCount: 8, maxCombo: 8, totalScore: 2400),
      RankingPeriod.monthly: _Stat(stampCount: 18, maxCombo: 10, totalScore: 5100),
      RankingPeriod.yearly: _Stat(stampCount: 75, maxCombo: 13, totalScore: 23000),
    },
  ),
  const _MockProfile(
    id: 'user_07',
    userName: '골목탐험가',
    avatarEmoji: '🧭',
    stats: {
      RankingPeriod.daily: _Stat(stampCount: 2, maxCombo: 4, totalScore: 500),
      RankingPeriod.weekly: _Stat(stampCount: 6, maxCombo: 5, totalScore: 1600),
      RankingPeriod.monthly: _Stat(stampCount: 15, maxCombo: 6, totalScore: 4200),
      RankingPeriod.yearly: _Stat(stampCount: 64, maxCombo: 8, totalScore: 18000),
    },
  ),
  const _MockProfile(
    id: 'user_08',
    userName: '베이커리덕후',
    avatarEmoji: '🥐',
    stats: {
      RankingPeriod.daily: _Stat(stampCount: 1, maxCombo: 2, totalScore: 200),
      RankingPeriod.weekly: _Stat(stampCount: 5, maxCombo: 4, totalScore: 1200),
      RankingPeriod.monthly: _Stat(stampCount: 12, maxCombo: 5, totalScore: 3100),
      RankingPeriod.yearly: _Stat(stampCount: 50, maxCombo: 7, totalScore: 14000),
    },
  ),
  const _MockProfile(
    id: 'user_09',
    userName: '행복한산책자',
    avatarEmoji: '🌸',
    stats: {
      RankingPeriod.daily: _Stat(stampCount: 1, maxCombo: 1, totalScore: 100),
      RankingPeriod.weekly: _Stat(stampCount: 4, maxCombo: 3, totalScore: 900),
      RankingPeriod.monthly: _Stat(stampCount: 9, maxCombo: 4, totalScore: 2200),
      RankingPeriod.yearly: _Stat(stampCount: 38, maxCombo: 6, totalScore: 9800),
    },
  ),
  const _MockProfile(
    id: 'user_10',
    userName: '스탬프초보',
    avatarEmoji: '🌱',
    stats: {
      RankingPeriod.daily: _Stat(stampCount: 1, maxCombo: 1, totalScore: 100),
      RankingPeriod.weekly: _Stat(stampCount: 2, maxCombo: 2, totalScore: 400),
      RankingPeriod.monthly: _Stat(stampCount: 6, maxCombo: 3, totalScore: 1400),
      RankingPeriod.yearly: _Stat(stampCount: 22, maxCombo: 4, totalScore: 5600),
    },
  ),
];

/// 선택된 랭킹 타입과 기간에 맞춰 정렬된 실시간 랭킹 리스트 Provider
final rankingListProvider = Provider<List<UserRank>>((ref) {
  final stampState = ref.watch(stampProvider);
  final rankingType = ref.watch(rankingTypeProvider);
  final rankingPeriod = ref.watch(rankingPeriodProvider);

  final now = DateTime.now();

  // 1. 현재 사용자의 기간별 실제 스탬프 필터링
  final periodStamps = stampState.stamps.where((s) {
    switch (rankingPeriod) {
      case RankingPeriod.daily:
        return s.stampedAt.year == now.year &&
            s.stampedAt.month == now.month &&
            s.stampedAt.day == now.day;
      case RankingPeriod.weekly:
        // 이번 주 (월요일 시작 기준)
        final daysFromMonday = (now.weekday - 1);
        final startOfWeek = DateTime(now.year, now.month, now.day - daysFromMonday);
        return s.stampedAt.isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
      case RankingPeriod.monthly:
        return s.stampedAt.year == now.year && s.stampedAt.month == now.month;
      case RankingPeriod.yearly:
        return s.stampedAt.year == now.year;
    }
  }).toList();

  final userStampCount = periodStamps.length;
  final userTotalScore = periodStamps.fold<int>(0, (sum, s) => sum + s.earnedPoints);
  final userMaxCombo = periodStamps.isEmpty
      ? 0
      : periodStamps.map((s) => s.combo).reduce((a, b) => a > b ? a : b);

  // 현재 유저 객체
  final currentUser = UserRank(
    id: 'current_user_me',
    userName: '나 (스탬퍼)',
    avatarEmoji: '👑',
    stampCount: userStampCount > 0 ? userStampCount : stampState.stamps.length,
    totalScore: userTotalScore > 0 ? userTotalScore : stampState.totalScore,
    maxCombo: userMaxCombo > 0 ? userMaxCombo : stampState.maxCombo,
    isCurrentUser: true,
  );

  // 가상 유저 데이터 기간 매핑
  final mockUserRanks = _mockProfiles.map((p) {
    final stat = p.stats[rankingPeriod] ??
        const _Stat(stampCount: 1, maxCombo: 1, totalScore: 100);
    return UserRank(
      id: p.id,
      userName: p.userName,
      avatarEmoji: p.avatarEmoji,
      stampCount: stat.stampCount,
      maxCombo: stat.maxCombo,
      totalScore: stat.totalScore,
    );
  }).toList();

  final allUsers = <UserRank>[...mockUserRanks, currentUser];

  // 2. 랭킹 기준에 따른 정렬
  allUsers.sort((a, b) {
    if (rankingType == RankingType.stamps) {
      // 1순위: 스탬프 수 최다
      if (b.stampCount != a.stampCount) {
        return b.stampCount.compareTo(a.stampCount);
      }
      // 2순위: 총점
      if (b.totalScore != a.totalScore) {
        return b.totalScore.compareTo(a.totalScore);
      }
      // 3순위: 최고 콤보
      return b.maxCombo.compareTo(a.maxCombo);
    } else {
      // 1순위: 콤보 최고
      if (b.maxCombo != a.maxCombo) {
        return b.maxCombo.compareTo(a.maxCombo);
      }
      // 2순위: 총점
      if (b.totalScore != a.totalScore) {
        return b.totalScore.compareTo(a.totalScore);
      }
      // 3순위: 스탬프 수
      return b.stampCount.compareTo(a.stampCount);
    }
  });

  // 3. 순위 부여
  return List.generate(allUsers.length, (index) {
    return allUsers[index].copyWith(rank: index + 1);
  });
});

/// 현재 유저의 실시간 순위 Provider
final myRankProvider = Provider<UserRank>((ref) {
  final rankings = ref.watch(rankingListProvider);
  return rankings.firstWhere(
    (u) => u.isCurrentUser,
    orElse: () => const UserRank(
      id: 'current_user_me',
      userName: '나 (스탬퍼)',
      avatarEmoji: '👑',
      stampCount: 0,
      totalScore: 0,
      maxCombo: 0,
      isCurrentUser: true,
      rank: 11,
    ),
  );
});
