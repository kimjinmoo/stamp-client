class UserRank {
  final String id;
  final String userName;
  final String avatarEmoji;
  final int totalScore;
  final int maxCombo;
  final bool isCurrentUser;
  final int rank;

  const UserRank({
    required this.id,
    required this.userName,
    required this.avatarEmoji,
    required this.totalScore,
    required this.maxCombo,
    this.isCurrentUser = false,
    this.rank = 0,
  });

  UserRank copyWith({
    String? id,
    String? userName,
    String? avatarEmoji,
    int? totalScore,
    int? maxCombo,
    bool? isCurrentUser,
    int? rank,
  }) {
    return UserRank(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      totalScore: totalScore ?? this.totalScore,
      maxCombo: maxCombo ?? this.maxCombo,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      rank: rank ?? this.rank,
    );
  }
}
