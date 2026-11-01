enum RankingType {
  stamps('스탬프 랭킹', '스탬프 등록 수 최다', '🏷️'),
  combo('콤보 랭킹', '콤보 게이지 최고', '⚡');

  final String title;
  final String description;
  final String emoji;
  const RankingType(this.title, this.description, this.emoji);
}

enum RankingPeriod {
  daily('일별', '오늘'),
  weekly('주별', '이번 주'),
  monthly('월별', '이번 달'),
  yearly('년별', '올해');

  final String label;
  final String sublabel;
  const RankingPeriod(this.label, this.sublabel);
}

class UserRank {
  final String id;
  final String userName;
  final String avatarEmoji;
  final int totalScore;
  final int maxCombo;
  final int stampCount;
  final bool isCurrentUser;
  final int rank;

  const UserRank({
    required this.id,
    required this.userName,
    required this.avatarEmoji,
    required this.totalScore,
    required this.maxCombo,
    this.stampCount = 0,
    this.isCurrentUser = false,
    this.rank = 0,
  });

  UserRank copyWith({
    String? id,
    String? userName,
    String? avatarEmoji,
    int? totalScore,
    int? maxCombo,
    int? stampCount,
    bool? isCurrentUser,
    int? rank,
  }) {
    return UserRank(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      totalScore: totalScore ?? this.totalScore,
      maxCombo: maxCombo ?? this.maxCombo,
      stampCount: stampCount ?? this.stampCount,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      rank: rank ?? this.rank,
    );
  }
}
