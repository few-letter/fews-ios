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

### ios upload_testflight

```sh
[bundle exec] fastlane ios upload_testflight
```

Upload to TestFlight

### ios nuke

```sh
[bundle exec] fastlane ios nuke
```

Delete all certificates and profiles (development + appstore)

### ios sign

```sh
[bundle exec] fastlane ios sign
```

Generate certificates and profiles (development + appstore)

### ios clean_all

```sh
[bundle exec] fastlane ios clean_all
```

Clean build cache and dependencies

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
