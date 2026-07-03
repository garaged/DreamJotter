# Building DreamJotter Locally

DreamJotter is distributed as source code and can be built locally on any supported Mac. You do not need a prebuilt application binary.

## Supported systems

- macOS 14 Sonoma or later
- Apple Silicon (`arm64`) or Intel (`x86_64`) Mac
- Xcode with Swift 6 support
- Command Line Tools selected in Xcode

Check the active developer tools:

```sh
xcode-select -p
swift --version
```

If the command-line tools are not configured, open Xcode and select them under:

```text
Xcode → Settings → Locations → Command Line Tools
```

## Get the source

```sh
git clone https://github.com/garaged/DreamJotter.git
cd DreamJotter
```

To build the current development branch used for Milestone 12:

```sh
git switch feature/m12-profile-management
git pull --ff-only
```

## Build and run with Xcode

This is the recommended workflow for contributors.

1. Open the Swift package:

   ```sh
   open Package.swift
   ```

2. In Xcode, select the `DreamJotterMac` scheme.
3. Select `My Mac` as the run destination.
4. Press **Run** or use `Command-R`.

Xcode builds the application, copies Swift Package Manager resources, and launches DreamJotter locally.

## Build and run from Terminal

Build the debug executable for the current Mac architecture:

```sh
swift build --product DreamJotterMac
```

Run it directly:

```sh
swift run DreamJotterMac
```

For a clean build with isolated caches:

```sh
rm -rf /private/tmp/DreamJotterSwiftPM

CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterClangModuleCache \
swift build \
  --product DreamJotterMac \
  --disable-sandbox \
  --scratch-path /private/tmp/DreamJotterSwiftPM
```

Then run the built executable:

```sh
/private/tmp/DreamJotterSwiftPM/debug/DreamJotterMac
```

The exact binary directory can be queried with:

```sh
swift build --show-bin-path
```

## Build a local `.app`

To create a normal macOS application bundle containing both Apple Silicon and Intel executable slices:

```sh
bash scripts/package-first-tester-macos
```

The generated files are:

```text
dist/DreamJotter.app
dist/DreamJotter-0.1.0-first-tester.zip
```

Open the locally built app:

```sh
open dist/DreamJotter.app
```

Confirm its supported architectures:

```sh
lipo -archs dist/DreamJotter.app/Contents/MacOS/DreamJotterMac
```

Expected output:

```text
arm64 x86_64
```

The generated app is ad-hoc signed for local testing. It is not notarized for public distribution.

## Build for one architecture

### Current Mac architecture

```sh
swift build \
  --configuration release \
  --product DreamJotterMac
```

### Apple Silicon

```sh
xcrun --sdk macosx swift build \
  --configuration release \
  --product DreamJotterMac \
  --triple arm64-apple-macosx14.0 \
  --disable-sandbox \
  --scratch-path /private/tmp/DreamJotterSwiftPM-arm64
```

### Intel

```sh
xcrun --sdk macosx swift build \
  --configuration release \
  --product DreamJotterMac \
  --triple x86_64-apple-macosx14.0 \
  --disable-sandbox \
  --scratch-path /private/tmp/DreamJotterSwiftPM-x86_64
```

## Run tests

Run the complete test suite:

```sh
swift test
```

For an isolated test build:

```sh
CLANG_MODULE_CACHE_PATH=/private/tmp/DreamJotterTestClangModuleCache \
swift test \
  --disable-sandbox \
  --scratch-path /private/tmp/DreamJotterTests
```

Run only localization tests:

```sh
swift test --filter LocalizationResourceTests
```

## Validate Spanish localization

Normalize reviewed Spanish copy before committing localization changes:

```sh
python3 scripts/normalize-spanish-copy
```

Run the localization audit:

```sh
python3 scripts/localization-check
```

Check that the deprecated unaccented spelling does not remain in source files:

```sh
grep -RIn \
  --exclude-dir=.git \
  --exclude-dir=.build \
  --exclude-dir=dist \
  -E '\b[Gg]uion\b' \
  Apps docs
```

A successful check prints no matches.

## Clean generated files

Clean the default SwiftPM build:

```sh
swift package clean
rm -rf .build
```

Clean packaged application output and isolated build caches:

```sh
rm -rf dist
rm -rf /private/tmp/DreamJotterSwiftPM*
rm -rf /private/tmp/DreamJotterFirstTesterBuild
rm -rf /private/tmp/DreamJotterClangModuleCache*
```

## Common problems

### Xcode cannot find the correct Swift toolchain

Update Xcode and confirm that `xcode-select` points to it:

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
swift --version
```

### Build artifacts appear stale

Remove `.build`, `dist`, and the temporary DreamJotter caches, then rebuild.

### Spanish resources do not appear

Build the `.app` using `scripts/package-first-tester-macos`. The script copies the SwiftPM resource bundle and the localized `.lproj` directories into the application bundle.

Verify packaged resources with:

```sh
find dist/DreamJotter.app/Contents/Resources \
  -maxdepth 3 \
  -type f \
  -name '*.strings'
```

### macOS refuses to open a locally built app

The packaging script ad-hoc signs the app. Verify the signature:

```sh
codesign --verify --deep --strict --verbose=2 dist/DreamJotter.app
```

Because the app is built locally, it should not have the quarantine attribute normally applied to downloaded applications. If the source directory itself was downloaded as an archive, inspect attributes with:

```sh
xattr -lr dist/DreamJotter.app
```

## Contributing

Before opening a pull request, run:

```sh
python3 scripts/normalize-spanish-copy
python3 scripts/localization-check
swift test
```

Do not commit generated `.build`, `dist`, or temporary cache directories.
