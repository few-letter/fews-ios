# FewCuts

FewCuts는 SwiftUI, TCA(The Composable Architecture), SwiftData를 사용하여 개발된 동영상 편집 iOS 앱입니다.

## 기술 스택

- **SwiftUI**: 사용자 인터페이스 구성
- **TCA (The Composable Architecture)**: 상태 관리 및 아키텍처
- **SwiftData**: 데이터 저장 및 관리
- **Firebase**: 분석 및 백엔드 서비스

## 프로젝트 구조

```
Sources/
├── FewCutsApp.swift          # 메인 앱 파일
├── ContentView.swift         # 메인 콘텐츠 뷰
├── Core/                     # 앱의 핵심 기능
│   └── AppFeature.swift      # 메인 앱 Feature
├── Features/                 # 각 기능별 모듈
│   ├── ProjectListFeature.swift
│   └── ProjectListView.swift
├── Model/                    # 데이터 모델
│   ├── VideoProject.swift
│   └── VideoClip.swift
└── Shared/                   # 공통 유틸리티
    └── Extensions.swift
```

## 주요 기능

- 동영상 프로젝트 생성 및 관리
- 동영상 클립 편집
- 프로젝트 목록 관리
- SwiftData를 통한 데이터 영속성

## 빌드 및 실행

1. Xcode에서 프로젝트 열기
2. 필요한 의존성 설치 (Tuist를 통해 자동 관리)
3. 시뮬레이터 또는 실제 기기에서 실행

## 라이선스

[라이선스 정보를 여기에 추가]
