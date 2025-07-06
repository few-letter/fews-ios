# FEWS iOS 앱 도구 (xmakes)

iOS 앱 개발을 위한 유틸리티 도구들입니다.

## 🚀 시작하기

### 1. 가상환경 설정

```bash
cd xmakes
python3 setup_venv.py
```

### 2. 도구 실행

```bash
# ⚠️ 중요: python이 아닌 python3을 사용해야 합니다
python3 main.py
```

## 🔧 에러 해결

### `zsh: command not found: python` 에러

이 에러는 시스템에 `python` 명령어가 없을 때 발생합니다. 아래 방법을 사용하세요:

```bash
# ❌ 잘못된 방법
python main.py

# ✅ 올바른 방법
python3 main.py
```

### 가상환경 문제

만약 가상환경 관련 에러가 발생하면:

```bash
# 가상환경 재설정
cd xmakes
rm -rf venv
python3 setup_venv.py
```

## 📱 사용 가능한 기능

1. **앱스토어 프리뷰 이미지 생성**

   - 앱스토어용 프리뷰 이미지 자동 생성
   - 다양한 언어 지원
   - iPhone/iPad 디바이스 대응

2. **가상환경 설정**
   - Python 가상환경 자동 설정
   - 필요한 패키지 자동 설치

## 🎯 Fastlane 연동

이 도구는 Fastlane과 연동되어 사용됩니다:

```bash
# 스크린샷 생성 (fastlane에서 자동으로 xmakes 호출)
cd ../fastlane
bundle exec fastlane screenshots
```

## 📁 폴더 구조

```
xmakes/
├── main.py              # 메인 실행 파일
├── setup_venv.py        # 가상환경 설정
├── requirements.txt     # Python 패키지 의존성
├── venv/               # 가상환경 (자동 생성)
└── appstore/           # 앱스토어 관련 도구
    ├── run_appstore_preview.py
    ├── make_appstore_preview.py
    └── output/         # 생성된 이미지 (자동 생성)
```

## 🆘 문제 해결

문제가 발생하면 다음 순서로 확인하세요:

1. **Python 버전 확인**

   ```bash
   python3 --version
   # Python 3.7 이상 필요
   ```

2. **가상환경 재설정**

   ```bash
   rm -rf venv
   python3 setup_venv.py
   ```

3. **Fastlane 경로 확인**
   - Fastlane에서 실행 시 xmakes 폴더 위치 확인
   - 상대 경로: `../xmakes`

## 📞 문의

문제가 있거나 기능 요청이 있으시면 이슈를 등록해주세요.
