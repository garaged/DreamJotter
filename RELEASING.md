# Releasing DreamJotter for macOS

## Preconditions

- M15 acceptance matrix completed for the release candidate.
- `main` is clean and all required CI checks pass.
- Version and build number are updated in packaging configuration.
- Release notes and privacy/help content match the application.
- Developer ID Application certificate is installed in the signing keychain.
- A `notarytool` keychain profile is configured locally or in the protected release environment.

## Build and package

```sh
bash scripts/package-first-tester-macos
```

Verify the universal executable:

```sh
lipo -archs dist/DreamJotter.app/Contents/MacOS/DreamJotterMac
```

Expected architectures:

```text
arm64 x86_64
```

## Sign, notarize, and staple

```sh
export SIGNING_IDENTITY='Developer ID Application: Your Name (TEAMID)'
export NOTARY_PROFILE='dreamjotter-notary'

bash scripts/package-release.sh \
  "$(pwd)/dist/DreamJotter.app" \
  "$(pwd)/dist"
```

The signing identity and notarization credentials must never be committed.

## Distribution verification

```sh
codesign --verify --deep --strict --verbose=2 dist/DreamJotter.app
xcrun stapler validate dist/DreamJotter.app
spctl --assess --type execute --verbose=4 dist/DreamJotter.app
```

Test the final archive on a clean supported Mac by downloading it through the intended distribution channel. This validates quarantine and Gatekeeper behavior that cannot be reproduced by opening a bundle directly from the build directory.

## GitHub release process

1. Merge the accepted M15 release PR.
2. Create an annotated tag such as `v1.0.0` at the accepted commit.
3. Create a GitHub release from the tag.
4. Copy the matching section from `RELEASE_NOTES.md`.
5. Attach the notarized ZIP and its SHA-256 checksum.
6. Keep the previous public build available until the new build passes clean-machine validation.

## Rollback

A release is withdrawn when Gatekeeper validation fails, a migration can lose canonical data, or a critical save/open regression is confirmed. Publish a clear notice, restore the previous known-good artifact, and create a patch release from a dedicated branch.
