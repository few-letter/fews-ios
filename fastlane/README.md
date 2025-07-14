fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios upload

```sh
[bundle exec] fastlane ios upload
```

App Store에 앱을 빌드하고 업로드합니다. (메타데이터 및 스크린샷 생성 포함)

### ios testflight

```sh
[bundle exec] fastlane ios testflight
```

TestFlight에 앱을 빌드하고 업로드합니다.

### ios submit_to_appstore

```sh
[bundle exec] fastlane ios submit_to_appstore
```

App Store에 리뷰를 위해 앱을 빌드하고 제출합니다.

### ios submit_to_appstore_info

```sh
[bundle exec] fastlane ios submit_to_appstore_info
```

App Store에 메타데이터와 스크린샷만 업로드합니다.

### ios reset

```sh
[bundle exec] fastlane ios reset
```

인증서를 안전하게 초기화합니다.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
