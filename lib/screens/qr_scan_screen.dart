import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/theme/app_colors.dart';
import '../providers/stamp_provider.dart';
import '../services/qr_security_service.dart';
import '../widgets/stamp_success_dialog.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  late MobileScannerController _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// QR 바코드 감지 시 처리
  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    await _processRawCode(rawValue);
  }

  /// QR 데이터 검증 및 스탬프 적립 처리
  Future<void> _processRawCode(String rawCode) async {
    setState(() => _isProcessing = true);

    final result = await ref.read(stampProvider.notifier).processQrCode(rawCode);

    if (!mounted) return;

    if (result.isSuccess && result.stamp != null) {
      // 적립 성공 팝업
      await StampSuccessDialog.show(context, result.stamp!);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      // 검증 실패 에러 다이얼로그
      await _showErrorDialog(result.errorMessage ?? '알 수 없는 오류가 발생했습니다.');
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// 에러 다이얼로그 (client.md 규격: "유효 시간이 만료되었거나 복사된 QR 코드입니다.")
  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
          backgroundColor: AppColors.canvas,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
              ),
              const SizedBox(width: 10),
              const Text(
                '스탬프 적립 실패',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.body,
              height: 1.5,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
              ),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  /// 테스트용 유효 QR 시뮬레이션
  Future<void> _simulateValidScan() async {
    if (_isProcessing) return;
    final payload = QrSecurityService.createValidSimulationPayload();
    await _processRawCode(payload.toJsonString());
  }

  /// 테스트용 위조/만료 QR 시뮬레이션
  Future<void> _simulateInvalidScan() async {
    if (_isProcessing) return;
    final payload = QrSecurityService.createInvalidSimulationPayload();
    await _processRawCode(payload.toJsonString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'QR 스탬프 스캔',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          // 플래시 토글
          IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.on:
                    return const Icon(Icons.flash_on_rounded, color: AppColors.accentPop);
                  case TorchState.off:
                  default:
                    return const Icon(Icons.flash_off_rounded, color: Colors.white);
                }
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          // 카메라 전/후면 전환
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 모바일 스캐너 뷰
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videocam_off_rounded, size: 56, color: Colors.white54),
                      const SizedBox(height: 16),
                      const Text(
                        '카메라를 실행할 수 없습니다.\n(에뮬레이터 또는 권한 미승인)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error.errorDetails?.message ?? error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '하단의 [테스트용 유효 QR 시뮬레이션] 버튼을 눌러 바로 테스트할 수 있습니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 스캔 타겟 오버레이 프레임
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: AppRadius.roundedXl,
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: Stack(
                children: [
                  // 코너 가이드라인 포인트
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 상단 안내 문구
          Positioned(
            top: 24,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: AppRadius.roundedFull,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner_rounded, color: AppColors.secondary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '매장의 동적 QR 코드를 사각형 안에 맞춰주세요',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),

          // 하단 테스트 편의 시뮬레이션 컨트롤 패널
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.canvas.withValues(alpha: 0.95),
                borderRadius: AppRadius.roundedLg,
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.build_circle_outlined, size: 16, color: AppColors.muted),
                      SizedBox(width: 6),
                      Text(
                        '개발 및 테스트 편의 기능',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 유효 QR 즉시 스캔 시뮬레이션 버튼 (client.md 명세)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _simulateValidScan,
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: const Text(
                        '테스트용 유효 QR 즉시 스캔 시뮬레이션',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 위조/만료 QR 차단 테스트 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing ? null : _simulateInvalidScan,
                      icon: const Icon(Icons.block_rounded, size: 16, color: AppColors.error),
                      label: const Text(
                        '위조/만료 QR 차단 방어 테스트',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 로딩 인디케이터
          if (_isProcessing)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
