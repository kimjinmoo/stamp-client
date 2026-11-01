import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  final Duration duration;

  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 2400),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _stampController;
  late AnimationController _rippleController;
  late AnimationController _textController;

  late Animation<double> _stampScale;
  late Animation<double> _stampRotate;
  late Animation<double> _rippleScale;
  late Animation<double> _rippleOpacity;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  Timer? _step1Timer;
  Timer? _step2Timer;
  Timer? _navTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    // 1. 도장 낙하 및 탄력 애니메이션 (0ms ~ 750ms)
    _stampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _stampScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 2.2, end: 0.9)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
    ]).animate(_stampController);

    _stampRotate = Tween<double>(begin: -0.22, end: 0.0).animate(
      CurvedAnimation(
        parent: _stampController,
        curve: Curves.easeOutBack,
      ),
    );

    // 2. 파동(Ripple) 효과 애니메이션 (도장 착지 시점부터 400ms ~ 1200ms)
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _rippleScale = Tween<double>(begin: 0.8, end: 2.2).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: Curves.easeOutCubic,
      ),
    );

    _rippleOpacity = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: Curves.easeOut,
      ),
    );

    // 3. 타이틀 텍스트 페이드인 & 슬라이드업 애니메이션 (600ms ~ 1200ms)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() {
    // 시퀀스 1: 도장 낙하 시작
    _stampController.forward();

    // 도장 착지 타이밍에 햅틱 및 파동 발산
    _step1Timer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      _rippleController.forward();
    });

    // 시퀀스 2: 타이틀 및 안내 문구 페이드인
    _step2Timer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      _textController.forward();
    });

    // 시퀀스 3: 메인 화면으로 부드럽게 화면 전환
    _navTimer = Timer(widget.duration, () {
      if (!mounted || _isNavigating) return;
      _navigateToHome();
    });
  }

  void _navigateToHome() {
    _isNavigating = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _step1Timer?.cancel();
    _step2Timer?.cancel();
    _navTimer?.cancel();
    _stampController.dispose();
    _rippleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          // 배경 은은한 그라데이션 장식 원 (앰비언트 글로우)
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primarySoft.withValues(alpha: 0.6),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondarySoft.withValues(alpha: 0.5),
              ),
            ),
          ),

          // 중앙 애니메이션 컨텐츠
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. 도장 & 파동 애니메이션 스택
                SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 외곽 파동 링 (Ripple 1 - 코랄)
                      AnimatedBuilder(
                        animation: _rippleController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _rippleScale.value,
                            child: Opacity(
                              opacity: _rippleOpacity.value,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // 외곽 파동 링 (Ripple 2 - 민트)
                      AnimatedBuilder(
                        animation: _rippleController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: math.max(0.1, _rippleScale.value * 0.8),
                            child: Opacity(
                              opacity: math.max(0.0, _rippleOpacity.value * 0.85),
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.secondary.withValues(alpha: 0.6),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // 탄력 있는 도장 메인 엠블럼
                      AnimatedBuilder(
                        animation: _stampController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _stampRotate.value,
                            child: Transform.scale(
                              scale: _stampScale.value,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF5E62), Color(0xFFE62348)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: AppRadius.roundedXl,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 원형 스탬프 테두리
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    width: 2,
                                  ),
                                ),
                              ),
                              // 내부 민트 뱃지 & 번개 아이콘
                              Container(
                                width: 62,
                                height: 62,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.secondary,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.bolt_rounded,
                                    size: 38,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // 별빛 스파클
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentPop,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2. 타이틀 & 서브타이틀 슬라이드인
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textFade,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: const Icon(
                              Icons.stars_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '스탬프 투어 & 콤보',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: AppRadius.roundedFull,
                          border: Border.all(color: AppColors.hairline),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '찍을수록 커지는 연속 콤보 랭킹 혜택',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.body,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 하단 버전 정보 및 은은한 프로그레스 바
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textFade,
              child: const Column(
                children: [
                  Text(
                    'Stamp Tour & Combo v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedSoft,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Powered by Grepiu',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
