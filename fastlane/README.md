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

Upload to TestFlight

### ios submit_to_appstore

```sh
[bundle exec] fastlane ios submit_to_appstore
```

Build and submit to App Store for review

### ios generate_screenshots

```sh
[bundle exec] fastlane ios generate_screenshots
```

Generate screenshots for App Store

### ios upload_appstore_info

```sh
[bundle exec] fastlane ios upload_appstore_info
```

Upload App Store info (metadata + screenshots upload only)

### ios full_upload

```sh
[bundle exec] fastlane ios full_upload
```

Generate screenshots and upload App Store info (combined)

### ios reset

```sh
[bundle exec] fastlane ios reset
```

Reset certificates

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
