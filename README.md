# fews-ios

> **Few** apps in **one** repository - iOS 앱 개발 모노레포

**Scalable iOS monorepo solution enabling efficient multi-app management through shared architecture, automated localization, and unified deployment pipeline.**

## 📱 앱 목록

|                                                            앱 아이콘                                                             |            앱 이름             |         부제목         |                                                                App Store                                                                |
| :------------------------------------------------------------------------------------------------------------------------------: | :----------------------------: | :--------------------: | :-------------------------------------------------------------------------------------------------------------------------------------: |
| <img src="Apps/Toffs/Resources/Assets.xcassets/AppIcon.appiconset/512.png" width="60" height="60" style="border-radius: 12px;">  |      **Toffs - 매매일지**      |      투자 관리 앱      |                    [다운로드](https://apps.apple.com/kr/app/toffs-%EB%A7%A4%EB%A7%A4%EC%9D%BC%EC%A7%80/id1619745259)                    |
| <img src="Apps/Plots/Resources/Assets.xcassets/AppIcon.appiconset/512.png" width="60" height="60" style="border-radius: 12px;">  |     **Plots - 독서 기록**      |  책, 영화, 문화 기록   |                   [다운로드](https://apps.apple.com/kr/app/plots-%EB%8F%85%EC%84%9C-%EA%B8%B0%EB%A1%9D/id6449458459)                    |
| <img src="Apps/Retros/Resources/Assets.xcassets/AppIcon.appiconset/512.png" width="60" height="60" style="border-radius: 12px;"> |     **Retros - 회고 일기**     | KPT로 체계적 성장 관리 |                   [다운로드](https://apps.apple.com/kr/app/retros-%ED%9A%8C%EA%B3%A0-%EC%9D%BC%EA%B8%B0/id6479611984)                   |
| <img src="Apps/Multis/Resources/Assets.xcassets/AppIcon.appiconset/512.png" width="60" height="60" style="border-radius: 12px;"> |    **Multis - 투두 타이머**    |   멀티 타이머 생산성   |              [다운로드](https://apps.apple.com/kr/app/multis-%ED%88%AC%EB%91%90-%ED%83%80%EC%9D%B4%EB%A8%B8/id6449679061)               |
| <img src="Apps/Capts/Resources/Assets.xcassets/AppIcon.appiconset/512.png" width="60" height="60" style="border-radius: 12px;">  | **Capts - 사진 텍스트 변환기** |     AI 스마트 OCR      | [다운로드](https://apps.apple.com/kr/app/capts-%EC%82%AC%EC%A7%84-%ED%85%8D%EC%8A%A4%ED%8A%B8-%EB%B3%80%ED%99%98%EA%B8%B0/id6463266155) |

## 🏗️ 모노레포 아키텍처

이 저장소는 **모노레포(Monorepo)** 패턴을 채택하여 여러 iOS 앱을 하나의 저장소에서 관리합니다.

### 왜 모노레포인가?

**장점:**

- 📦 **코드 공유**: 공통 모듈과 컴포넌트를 여러 앱에서 재사용
- 🔄 **일관성**: 동일한 개발 도구, 컨벤션, CI/CD 파이프라인 적용
- 🚀 **효율성**: 한 번의 수정으로 모든 앱에 공통 기능 배포
- 🎯 **관리 편의성**: 하나의 저장소에서 모든 프로젝트 관리

**구조:**

```
fews-ios/
├── Apps/                 # 각 앱별 타겟
│   ├── Capts/           # OCR 앱
│   ├── Retros/          # 회고 일기 앱
│   ├── Multis/          # 타이머 앱
│   ├── Plots/           # 독서 기록 앱
│   └── Toffs/           # 투자 관리 앱
├── Modules/             # 공유 모듈
│   ├── CommonFeature/   # 공통 기능
│   └── DS/              # 디자인 시스템
├── fastlane/            # 자동화 배포
└── Tuist/               # 프로젝트 관리
```

### 기술 스택

- **프로젝트 관리**: Tuist
- **아키텍처**: TCA (The Composable Architecture)
- **데이터**: SwiftData
- **UI**: SwiftUI
- **배포**: Fastlane
- **언어**: Swift 5.9+

## 🤖 AI 기반 현지화 자동화

**Cursor Rules**를 활용하여 **20개국 언어 현지화를 완전 자동화**한 혁신적인 시스템입니다.

### 🎯 Cursor Rules 자동화 시스템

이 프로젝트의 핵심 혁신은 **AI 기반 현지화 자동화**입니다. 단순한 번역을 넘어서 **문화적 맥락**과 **앱스토어 최적화**까지 고려한 지능형 시스템을 구축했습니다.

```
📝 한국어 메타데이터 작성
    ↓
🤖 Cursor Rules 실행
    ↓
🌍 20개국 동시 번역 + 최적화
    ↓
✅ 자동 검증 (글자수, 키워드, 문화적 적합성)
    ↓
🚀 Fastlane 자동 배포
```

### 지원 언어 (우선순위별)

🇰🇷 한국어 (기준) → 🇺🇸 영어 → 🇯🇵 일본어 → 🇨🇳 중국어(간체) → 🇹🇼 중국어(번체) → 🇩🇪 독일어 → 🇫🇷 프랑스어 → 🇪🇸 스페인어 → 🇮🇹 이탈리아어 → 🇧🇷 포르투갈어 → 🇷🇺 러시아어 → 🇸🇦 아랍어 → 🇮🇳 힌디어 → 🇹🇷 터키어 → 🇵🇱 폴란드어 → 🇳🇱 네덜란드어 → 🇸🇪 스웨덴어 → 🇩🇰 덴마크어 → 🇫🇮 핀란드어 → 🇳🇴 노르웨이어

### 자동화 특징

- 🤖 **AI 기반 번역**: Cursor Rules가 문맥과 앱 특성을 고려한 번역 생성
- 🎯 **키워드 최적화**: 각 국가별 앱스토어 검색 트렌드 자동 반영
- 🔍 **실시간 검증**: 글자수 제한, 파일 무결성, 문화적 적합성 자동 체크
- 📊 **일관성 보장**: 모든 앱에 동일한 품질 기준과 톤앤매너 적용
- ⚡ **원클릭 배포**: 번역부터 앱스토어 업로드까지 완전 자동화

> 📋 **현지화 자동화**: [20개국 번역 및 키워드 최적화 규칙](./.cursor/rules/metadata_appstore_translate_ko_to_other.mdc)  
> 🔍 **품질 검증**: [App Store 메타데이터 글자수 제한 및 무결성 검증](./.cursor/rules/metadata_appstore_check_number_of_character.mdc)

## 🚀 자동화된 빌드 & 배포

Fastlane을 활용한 멀티 앱 빌드 시스템으로 **5개 앱을 한 번에 관리**할 수 있습니다.

### 주요 명령어

|      명령어       |       설명        | 기능                                                                                                |
| :---------------: | :---------------: | :-------------------------------------------------------------------------------------------------- |
| `fastlane upload` |   **메인 배포**   | • 앱 선택 (단일/다중)<br>• 버전 정보 일괄 입력<br>• 메타데이터 업로드<br>• 빌드 & TestFlight 업로드 |
| `fastlane reset`  | **인증서 재설정** | • Development/AppStore 인증서 초기화<br>• 새 인증서 생성 및 동기화                                  |

### 빌드 프로세스

```bash
# 1. 앱 선택 (예: 1,3,5 = Toffs, Retros, Multis)
번호 선택 (여러개는 콤마로 구분): 1,3,5

# 2. 버전 정보 입력
Toffs의 새 버전: 1.2.0
Retros의 새 버전: 2.1.0
Multis의 새 버전: 1.5.0

# 3. 자동 실행
✅ 메타데이터 업로드 (20개국 현지화)
✅ Tuist 프로젝트 생성
✅ 빌드 (Release 구성)
✅ TestFlight 업로드
```

### 빌드 시스템 특징

- 🎯 **선택적 빌드**: 필요한 앱만 선택하여 빌드
- ⚡ **병렬 처리**: 각 앱을 독립적으로 처리
- 🔄 **자동 복구**: 실패 시 다음 앱으로 자동 진행
- 📊 **결과 요약**: 성공/실패 앱 목록 제공

---

### 그외

저는 2년 전에 [https://github.com/folio-world](https://github.com/folio-world) 모노레포를 만들어보면 재밌을 것 같아서 시작했던 프로젝트였는데 마무리를 못지었었습니다. 제가 제일 오래 기여한 사이드 프로젝트인 few에 정착해서 개발 공부 겸, 신기술 적용 겸 조금이나마 좋은 앱들을 만들어서 유저에게 제공 해보는 삶을 살아가려고 합니다. 당시에는 AI 같은 툴들이 전혀 없어서 직접 손으로 치는 맛이 있었는데 요즘에는 딸깍의 시대가 된 것 같아요. 그리고 곧 이런 생각도 들었습니다. 내가 AI가 하려고 하는 작업을 방해하는 병목은 아닐까? 구현의 윗단에서 설계를 잘 해서 AI와 함께 이 레포지토리를 점차 키워나가보려고 합니다.

특이점이 오기 시작해서, AI로 만들어진 앱들이 점차 더 많아질 것 같습니다. 품질 저하를 우려하진 않습니다. 모든 것은 사용자의 선택이기 때문에 자유가 보장되어야 한다고 생각합니다. 그것을 더 잘 활용할 수 있는 방법 중 하나인 모노레포가 다시 유행할 것 이라고 생각합니다. (물론 iOS의 project는 그 자체로 이미 모노레포이긴 합니다) 개인이나 회사들이 앱들을 여러개 갖게 되고 이럴거면 리소스를 한 곳에 모아버리자 라는 생각을 갖게 될 것이라고 생각합니다. (감사합니다.)
