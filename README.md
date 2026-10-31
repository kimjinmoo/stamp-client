# 🏷️ 스탬프 투어 & 콤보 랭킹 클라이언트 앱 (Stamp Client)

Flutter 기반의 일반 사용자(B2C)용 **스탬프 투어 및 연속 방문 콤보(Combo) 랭킹 애플리케이션**입니다.  
매장에 비치된 관리자(Admin) 앱의 동적 보안 QR 코드를 카메라로 스캔하여 스탬프를 적립하고, 제한 시간 내 연속 방문을 통해 콤보 배수 보너스와 랭킹 경쟁의 즐거움을 제공합니다.

---

## 📱 주요 화면 및 기능

### 1. 동적 보안(TOTP) QR 스캔 및 검증
- **Admin 앱 100% 호환 규격**:
  - 공유 비밀키(Shared Secret): `STAMP_SECRET_KEY_2026_V1`
  - 30초 단위 타임 윈도우 기반 `HMAC-SHA256` 해시 토큰 생성 및 검증
  - 기기 간 미세 시간 오차 허용을 위해 `currentWindow` 및 `currentWindow - 1` 허용
  - 위조 및 캡처 복사본 스캔 시 `"유효 시간이 만료되었거나 복사된 QR 코드입니다."` 방어 차단
- **개발/테스트 편의 기능 (카메라 없이 테스트 가능)**:
  - `[테스트용 유효 QR 즉시 스캔 시뮬레이션]`: 현재 유효한 30초 HMAC 토큰을 즉시 생성하여 적립 시뮬레이션
  - `[위조/만료 QR 차단 방어 테스트]`: 위조 및 만료 토큰을 전송하여 보안 방어 로직 정상 작동 여부 검증
  - 플래시 라이트 토글 및 전/후면 카메라 전환 지원

### 2. 스탬프 보드 및 콤보(Combo) 시스템 (탭 1)
- **실시간 콤보 카운트다운 타이머**:
  - 설정된 제한 시간(기본 10분, 테스트 설정 가능) 내 스캔 시 연속 콤보(`currentCombo + 1`) 누적
  - 제한 시간 초과 시 콤보 1단계로 리셋
  - 남은 시간에 따라 **프레시 민트(`#00D19A`)**에서 종료 임박 시 **제스티 코랄(`#FF5A5F`)**로 변하는 부드러운 애니메이션 프로그레스 바
- **게이미피케이션 점수 산정**:
  - 기본 100점 × `currentCombo` 배수 (예: 1콤보=100P, 2콤보=200P, 3콤보=300P 누적)
  - 역대 최대 달성 기록(`maxCombo`) 자동 갱신
- **소프트 벤토 그리드(Bento Grid) 대시보드**:
  - 내 총점, 현재 콤보, 최고 기록, 모은 스탬프 수를 한눈에 파악
- **스탬프 획득 연출**:
  - 도장 팝 애니메이션(`Curves.elasticOut`) 및 촉각 햅틱 피드백(`HapticFeedback.mediumImpact()`)
  - 획득 당시 콤보 및 장소, 일시 정보가 담긴 도장 카드 제공
- **플로팅 스캔 버튼 (`fab-scan-orb`)**:
  - 우측 하단 Level 2 Coral Glow 그림자가 적용된 QR 스탬프 스캔 진입 버튼

### 3. 실시간 콤보 랭킹 (탭 2)
- **1위~3위 TOP 3 포디움 UI**:
  - 1위(골드 왕관 및 써니 앰버 `#FFB800` 골드 링 아바타), 2위(실버), 3위(브론즈) 차등 높이 포디움
- **실시간 순위 반영**:
  - 10명의 가상(Mock) 유저 데이터와 현재 사용자('나')의 실시간 점수 및 최고 콤보를 종합하여 순위 실시간 변동
  - 내 순위 카드(`My Rank`) 하이라이트(코랄 틴트 배경 + 코랄 테두리) 및 상단 고정 요약 바 제공

### 4. 내 정보 & 클라우드 동기화 (탭 3)
- **서버 올리기 (UI 전용)**:
  - 눈에 띄는 `[서버에 내 스탬프/랭킹 올리기]` 버튼 배치
  - 클릭 시 `"서버에 데이터를 업로드하는 중..."` 로딩 다이얼로그 표시 후 `"업로드 버튼 동작 확인 완료 (서버 연동 예정)"` 스낵바 알림 제공 (`Future<void> syncToServer()`)
- **콤보 제한 시간 변경**:
  - 1분(빠른 테스트용), 5분, 10분(기본값), 30분 세그먼트 버튼 선택
- **개발 및 테스트 도구**:
  - `[콤보 타이머 즉시 리셋 (만료)]`: 콤보 타이머를 즉시 종료하여 리셋 상태 테스트
  - `[스탬프 및 기록 전체 초기화]`: SharedPreferences 로컬 데이터 및 전체 기록 초기화

---

## 🎨 디자인 시스템 (DESIGN.md 준수)

- **Fresh & Sophisticated B2C 트렌드**:
  - 메인 포인트: **Zesty Coral (`#FF5A5F`)**
  - 서브/리워드/타이머: **Fresh Mint (`#00D19A`)**
  - 랭킹/강조: **Sunny Amber (`#FFB800`)**
  - 배경: **Pure White (`#FFFFFF`)** & **Cool Alabaster (`#F8FAFC`)**
  - 텍스트: **Deep Charcoal (`#111827`)**
- **마이크로 인터랙션**:
  - 모든 카드와 주요 버튼 터치 시 `120ms` 동안 `scale(0.97)` 축소 효과 (`PressableScale`)
  - 모든 숫자/타이머에 `font-variant-numeric: tabular-nums` 고정폭 폰트 적용
  - 넉넉한 라운딩(`14px` 버튼, `20px` 카드, `28px` 모달)

---

## 🛠️ 기술 스택 및 의존성

| 패키지 | 버전 | 용도 |
|---|---|---|
| `flutter_riverpod` | `^3.4.3` | 최신 Notifier 기반 전역 상태 관리 |
| `mobile_scanner` | `^7.4.3` | 고성능 카메라 QR 코드 실시간 스캔 |
| `crypto` | `^3.0.8` | Admin 앱 호환 HMAC-SHA256 동적 보안 검증 |
| `shared_preferences` | `^2.5.6` | 스탬프 목록, 점수, 콤보 기록 영속화 |
| `intl` | `^0.20.3` | 날짜 및 시간 포맷팅 |

---

## 📋 권한 설정 가이드

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 카메라 권한 추가 -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    ...
</manifest>
```

### iOS (`ios/Runner/Info.plist`)
```xml
<dict>
    ...
    <!-- 카메라 권한 설명 추가 -->
    <key>NSCameraUsageDescription</key>
    <string>QR 코드 스캔 및 스탬프 적립을 위해 카메라 접근 권한이 필요합니다.</string>
</dict>
```

---

## 📂 프로젝트 구조

```text
lib/
├── main.dart                       # 앱 진입점 및 ProviderScope, 테마 설정
├── core/
│   └── theme/
│       ├── app_colors.dart         # DESIGN.md 컬러, 그림자, 곡률 토큰
│       └── app_theme.dart          # Light Theme 및 고정폭 타이포그래피
├── models/
│   ├── qr_payload.dart             # QR JSON 페이로드 모델
│   ├── stamp.dart                  # 스탬프 적립 도메인 모델
│   └── user_rank.dart              # 유저 랭킹 모델
├── services/
│   └── qr_security_service.dart    # TOTP HMAC-SHA256 검증 및 시뮬레이션 생성기
├── providers/
│   ├── stamp_provider.dart         # 스탬프, 콤보, 타이머, 영속화 상태 관리 (Riverpod Notifier)
│   └── ranking_provider.dart       # 10인 Mock + 내 순위 실시간 정렬
├── screens/
│   ├── main_navigation_screen.dart # 3개 탭 하단 네비게이션
│   ├── stamp_home_screen.dart      # 탭 1: 스탬프 보드 & 대시보드
│   ├── qr_scan_screen.dart         # QR 스캐너 & 즉시 시뮬레이션
│   ├── ranking_screen.dart         # 탭 2: 1~3위 포디움 & 전체 랭킹
│   └── profile_screen.dart         # 탭 3: 내 정보 & 서버 동기화
└── widgets/
    ├── bento_stat_card.dart        # 벤토 그리드 통계 카드
    ├── combo_timer_banner.dart     # 실시간 카운트다운 타이머 배너
    ├── pressable_scale.dart        # 터치 스케일 마이크로 인터랙션
    ├── stamp_slot_card.dart        # 스탬프 도장 슬롯 카드
    └── stamp_success_dialog.dart   # 스탬프 획득 탄력 팝업 다이얼로그
```

---

## 🚀 실행 및 테스트 방법

### 의존성 설치
```bash
flutter pub get
```

### 단위 및 위젯 테스트 실행
```bash
flutter test
```
- TOTP HMAC-SHA256 유효 타임 윈도우 검증 통과
- 직전 30초 윈도우(`currentWindow - 1`) 오차 허용 검증 통과
- 위조/만료 토큰 차단 검증 통과
- 메인 위젯 렌더링 스모크 테스트 통과

### 정적 코드 분석
```bash
flutter analyze
```
- 린트 및 컴파일 경고 0건

### 앱 실행
```bash
flutter run
```
*카메라가 없는 에뮬레이터에서도 스캔 화면의 **`[테스트용 유효 QR 즉시 스캔 시뮬레이션]`** 버튼을 통해 즉시 모든 기능을 테스트할 수 있습니다.*
