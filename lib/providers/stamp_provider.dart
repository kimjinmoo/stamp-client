import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/qr_payload.dart';
import '../models/stamp.dart';
import '../services/qr_security_service.dart';

/// 스탬프 상태 모델
class StampState {
  final List<Stamp> stamps;
  final int currentCombo;
  final int maxCombo;
  final int totalScore;
  final DateTime? lastStampedAt;
  final int comboDurationMinutes;
  final int remainingSeconds;
  final bool isLoading;

  const StampState({
    this.stamps = const [],
    this.currentCombo = 0,
    this.maxCombo = 0,
    this.totalScore = 0,
    this.lastStampedAt,
    this.comboDurationMinutes = 10,
    this.remainingSeconds = 0,
    this.isLoading = false,
  });

  bool get isComboActive => currentCombo > 0 && remainingSeconds > 0;

  double get comboProgress {
    if (!isComboActive) return 0.0;
    final totalSec = comboDurationMinutes * 60;
    if (totalSec <= 0) return 0.0;
    return (remainingSeconds / totalSec).clamp(0.0, 1.0);
  }

  String get formattedRemainingTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final minStr = minutes.toString().padLeft(2, '0');
    final secStr = seconds.toString().padLeft(2, '0');
    return '$minStr:$secStr';
  }

  StampState copyWith({
    List<Stamp>? stamps,
    int? currentCombo,
    int? maxCombo,
    int? totalScore,
    DateTime? lastStampedAt,
    bool clearLastStampedAt = false,
    int? comboDurationMinutes,
    int? remainingSeconds,
    bool? isLoading,
  }) {
    return StampState(
      stamps: stamps ?? this.stamps,
      currentCombo: currentCombo ?? this.currentCombo,
      maxCombo: maxCombo ?? this.maxCombo,
      totalScore: totalScore ?? this.totalScore,
      lastStampedAt: clearLastStampedAt ? null : (lastStampedAt ?? this.lastStampedAt),
      comboDurationMinutes: comboDurationMinutes ?? this.comboDurationMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 스탬프 스캔 결과 객체
class StampScanResult {
  final bool isSuccess;
  final Stamp? stamp;
  final String? errorMessage;
  final int combo;
  final int points;

  StampScanResult.success({
    required this.stamp,
    required this.combo,
    required this.points,
  })  : isSuccess = true,
        errorMessage = null;

  StampScanResult.failure(this.errorMessage)
      : isSuccess = false,
        stamp = null,
        combo = 0,
        points = 0;
}

/// 스탬프 및 콤보 시스템 상태 관리 Notifier (Riverpod 3 Notifier 표준)
class StampNotifier extends Notifier<StampState> {
  Timer? _countdownTimer;
  bool _disposed = false;
  static const String _prefStampsKey = 'stamp_client_stamps_v1';
  static const String _prefTotalScoreKey = 'stamp_client_total_score_v1';
  static const String _prefMaxComboKey = 'stamp_client_max_combo_v1';
  static const String _prefCurrentComboKey = 'stamp_client_current_combo_v1';
  static const String _prefLastStampedAtKey = 'stamp_client_last_stamped_at_v1';
  static const String _prefComboDurationKey = 'stamp_client_combo_duration_v1';

  @override
  StampState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _countdownTimer?.cancel();
    });

    _loadFromPreferences();
    return const StampState();
  }

  /// SharedPreferences에서 기존 데이터 복원
  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;
      final stampsJson = prefs.getStringList(_prefStampsKey) ?? [];
      final stamps = stampsJson
          .map((s) => Stamp.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();

      final totalScore = prefs.getInt(_prefTotalScoreKey) ?? 0;
      final maxCombo = prefs.getInt(_prefMaxComboKey) ?? 0;
      final currentCombo = prefs.getInt(_prefCurrentComboKey) ?? 0;
      final comboDuration = prefs.getInt(_prefComboDurationKey) ?? 10;
      final lastStampedStr = prefs.getString(_prefLastStampedAtKey);
      final lastStampedAt = lastStampedStr != null ? DateTime.tryParse(lastStampedStr) : null;

      state = state.copyWith(
        stamps: stamps,
        totalScore: totalScore,
        maxCombo: maxCombo,
        currentCombo: currentCombo,
        comboDurationMinutes: comboDuration,
        lastStampedAt: lastStampedAt,
      );

      _startTimer();
      _updateRemainingTime();
    } catch (e) {
      if (!_disposed) {
        _startTimer();
      }
    }
  }

  /// SharedPreferences에 상태 저장
  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stampsJson = state.stamps
          .map((s) => jsonEncode(s.toJson()))
          .toList();

      await prefs.setStringList(_prefStampsKey, stampsJson);
      await prefs.setInt(_prefTotalScoreKey, state.totalScore);
      await prefs.setInt(_prefMaxComboKey, state.maxCombo);
      await prefs.setInt(_prefCurrentComboKey, state.currentCombo);
      await prefs.setInt(_prefComboDurationKey, state.comboDurationMinutes);
      if (state.lastStampedAt != null) {
        await prefs.setString(_prefLastStampedAtKey, state.lastStampedAt!.toIso8601String());
      } else {
        await prefs.remove(_prefLastStampedAtKey);
      }
    } catch (_) {}
  }

  /// 1초 단위 타이머 시작
  void _startTimer() {
    _countdownTimer?.cancel();
    if (_disposed) return;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }
      _updateRemainingTime();
    });
  }

  /// 남은 시간 계산 및 콤보 만료 처리
  void _updateRemainingTime() {
    if (state.lastStampedAt == null) {
      if (state.remainingSeconds != 0 || state.currentCombo != 0) {
        state = state.copyWith(remainingSeconds: 0, currentCombo: 0);
      }
      return;
    }

    final now = DateTime.now();
    final elapsedSec = now.difference(state.lastStampedAt!).inSeconds;
    final totalAllowedSec = state.comboDurationMinutes * 60;
    final remaining = totalAllowedSec - elapsedSec;

    if (remaining <= 0) {
      if (state.currentCombo != 0 || state.remainingSeconds != 0) {
        state = state.copyWith(
          currentCombo: 0,
          remainingSeconds: 0,
        );
        _saveToPreferences();
      }
    } else {
      state = state.copyWith(remainingSeconds: remaining);
    }
  }

  /// QR 스캔 데이터 검증 및 스탬프 적립
  Future<StampScanResult> processQrCode(String rawCode) async {
    // 1. JSON 파싱
    QrPayload payload;
    try {
      payload = QrPayload.fromJsonString(rawCode);
    } catch (e) {
      return StampScanResult.failure('유효하지 않은 QR 코드 형식입니다.');
    }

    // 2. 동적 보안(TOTP HMAC-SHA256) 검증
    final isValid = QrSecurityService.verifyQrPayload(payload);
    if (!isValid) {
      return StampScanResult.failure('유효 시간이 만료되었거나 복사된 QR 코드입니다.');
    }

    // 3. 콤보 및 점수 계산 로직
    final now = DateTime.now();
    final comboTimeoutSec = state.comboDurationMinutes * 60;

    int newCombo = 1;
    if (state.lastStampedAt != null) {
      final elapsed = now.difference(state.lastStampedAt!).inSeconds;
      if (elapsed <= comboTimeoutSec) {
        newCombo = state.currentCombo + 1;
      } else {
        newCombo = 1;
      }
    } else {
      newCombo = 1;
    }

    final newMaxCombo = max(state.maxCombo, newCombo);
    final earnedPoints = 100 * newCombo;
    final newTotalScore = state.totalScore + earnedPoints;

    final newStamp = Stamp(
      id: '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
      placeId: payload.placeId,
      placeName: payload.placeName,
      stampedAt: now,
      combo: newCombo,
      earnedPoints: earnedPoints,
    );

    final updatedStamps = [newStamp, ...state.stamps];

    state = state.copyWith(
      stamps: updatedStamps,
      currentCombo: newCombo,
      maxCombo: newMaxCombo,
      totalScore: newTotalScore,
      lastStampedAt: now,
      remainingSeconds: comboTimeoutSec,
    );

    await _saveToPreferences();

    return StampScanResult.success(
      stamp: newStamp,
      combo: newCombo,
      points: earnedPoints,
    );
  }

  /// 콤보 유지 시간 변경 (1분, 5분, 10분, 30분)
  void setComboDuration(int minutes) {
    state = state.copyWith(comboDurationMinutes: minutes);
    _updateRemainingTime();
    _saveToPreferences();
  }

  /// 테스트용: 콤보 타이머 즉시 리셋 (만료 시뮬레이션)
  void resetComboTimer() {
    state = state.copyWith(
      currentCombo: 0,
      remainingSeconds: 0,
      clearLastStampedAt: true,
    );
    _saveToPreferences();
  }

  /// 테스트용: 전체 스탬프 및 점수 초기화
  Future<void> clearAllStamps() async {
    state = const StampState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefStampsKey);
    await prefs.remove(_prefTotalScoreKey);
    await prefs.remove(_prefMaxComboKey);
    await prefs.remove(_prefCurrentComboKey);
    await prefs.remove(_prefLastStampedAtKey);
  }

  /// UI 전용 서버 동기화 함수
  Future<void> syncToServer() async {
    await Future.delayed(const Duration(milliseconds: 1500));
  }
}

/// 전역 StampProvider 정의 (Riverpod 3 NotifierProvider)
final stampProvider = NotifierProvider<StampNotifier, StampState>(StampNotifier.new);
