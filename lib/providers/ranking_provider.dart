import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_rank.dart';
import 'stamp_provider.dart';

/// 가상 유저 10명의 Mock 랭킹 초기 데이터
final List<UserRank> _mockUsers = [
  const UserRank(
    id: 'user_01',
    userName: '스탬프헌터민우',
    avatarEmoji: '⚡',
    totalScore: 2800,
    maxCombo: 8,
  ),
  const UserRank(
    id: 'user_02',
    userName: '카페투어러지혜',
    avatarEmoji: '☕',
    totalScore: 2100,
    maxCombo: 6,
  ),
  const UserRank(
    id: 'user_03',
    userName: '성수동산책가',
    avatarEmoji: '🌿',
    totalScore: 1800,
    maxCombo: 5,
  ),
  const UserRank(
    id: 'user_04',
    userName: '주말러너동현',
    avatarEmoji: '🏃',
    totalScore: 1500,
    maxCombo: 5,
  ),
  const UserRank(
    id: 'user_05',
    userName: '디저트원정대',
    avatarEmoji: '🍰',
    totalScore: 1200,
    maxCombo: 4,
  ),
  const UserRank(
    id: 'user_06',
    userName: '핫플마스터수빈',
    avatarEmoji: '🔥',
    totalScore: 900,
    maxCombo: 3,
  ),
  const UserRank(
    id: 'user_07',
    userName: '골목탐험가',
    avatarEmoji: '🧭',
    totalScore: 600,
    maxCombo: 3,
  ),
  const UserRank(
    id: 'user_08',
    userName: '베이커리덕후',
    avatarEmoji: '🥐',
    totalScore: 400,
    maxCombo: 2,
  ),
  const UserRank(
    id: 'user_09',
    userName: '행복한산책자',
    avatarEmoji: '🌸',
    totalScore: 200,
    maxCombo: 1,
  ),
  const UserRank(
    id: 'user_10',
    userName: '스탬프초보',
    avatarEmoji: '🌱',
    totalScore: 100,
    maxCombo: 1,
  ),
];

/// 현재 유저의 실시간 점수/콤보와 10명의 가상 유저를 통합 정렬한 랭킹 리스트 Provider
final rankingListProvider = Provider<List<UserRank>>((ref) {
  final stampState = ref.watch(stampProvider);

  // 현재 유저 객체
  final currentUser = UserRank(
    id: 'current_user_me',
    userName: '나 (스탬퍼)',
    avatarEmoji: '👑',
    totalScore: stampState.totalScore,
    maxCombo: stampState.maxCombo,
    isCurrentUser: true,
  );

  // 가상 유저 10명 + 나 1명 = 총 11명 목록
  final allUsers = <UserRank>[..._mockUsers, currentUser];

  // 총점 내림차순, 총점이 같으면 최고 콤보 내림차순 정렬
  allUsers.sort((a, b) {
    if (b.totalScore != a.totalScore) {
      return b.totalScore.compareTo(a.totalScore);
    }
    return b.maxCombo.compareTo(a.maxCombo);
  });

  // 순위(rank: 1, 2, 3...) 부여
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
      totalScore: 0,
      maxCombo: 0,
      isCurrentUser: true,
      rank: 11,
    ),
  );
});
