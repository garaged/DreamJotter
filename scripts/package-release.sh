#!/usr/bin/env bash

set -euo pipefail

APP_PATH="${1:-}"
OUTPUT_DIR="${2:-dist}"

if [[ -z "${APP_PATH}" ]]; then
  echo "Usage: $0 /path/to/DreamJotter.app [output-directory]" >&2
  exit 64
fi

if [[ ! -d "${APP_PATH}" ]]; then
  echo "Error: application bundle does not exist: ${APP_PATH}" >&2
  exit 66
fi

APP_PATH="$(cd "$(dirname "${APP_PATH}")" && pwd)/$(basename "${APP_PATH}")"
mkdir -p "${OUTPUT_DIR}"
OUTPUT_DIR="$(cd "${OUTPUT_DIR}" && pwd)"

APP_NAME="$(basename "${APP_PATH}" .app)"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "${APP_PATH}/Contents/Info.plist")"
ZIP_PATH="${OUTPUT_DIR}/${APP_NAME}-${VERSION}.zip"
ENTITLEMENTS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/config/DreamJotter.entitlements"
SIGNING_IDENTITY="${SIGNING_IDENTITY:-}"
NOTARY_PROFILE="${NOTARY_PROFILE:-}"

for tool in codesign ditto spctl xcrun lipo; do
  command -v "${tool}" >/dev/null 2>&1 || {
    echo "Error: required tool '${tool}' was not found." >&2
    exit 69
  }
done

if [[ -z "${SIGNING_IDENTITY}" ]]; then
  echo "Error: SIGNING_IDENTITY must contain a Developer ID Application identity." >&2
  exit 78
fi

EXECUTABLE="${APP_PATH}/Contents/MacOS/DreamJotterMac"
ARCHITECTURES="$(lipo -archs "${EXECUTABLE}")"
[[ " ${ARCHITECTURES} " == *" arm64 "* ]] || { echo "Error: release is missing arm64." >&2; exit 65; }
[[ " ${ARCHITECTURES} " == *" x86_64 "* ]] || { echo "Error: release is missing x86_64." >&2; exit 65; }

find "${APP_PATH}/Contents" -type f \( -name '*.dylib' -o -perm -111 \) -print0 | while IFS= read -r -d '' item; do
  [[ "${item}" == "${EXECUTABLE}" ]] && continue
  codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" "${item}"
done

codesign --force --deep --timestamp --options runtime \
  --entitlements "${ENTITLEMENTS}" \
  --sign "${SIGNING_IDENTITY}" \
  "${APP_PATH}"

codesign --verify --deep --strict --verbose=2 "${APP_PATH}"
rm -f "${ZIP_PATH}"
ditto -c -k --keepParent "${APP_PATH}" "${ZIP_PATH}"

if [[ -n "${NOTARY_PROFILE}" ]]; then
  xcrun notarytool submit "${ZIP_PATH}" --keychain-profile "${NOTARY_PROFILE}" --wait
  xcrun stapler staple "${APP_PATH}"
  xcrun stapler validate "${APP_PATH}"
  spctl --assess --type execute --verbose=4 "${APP_PATH}"
else
  echo "Warning: NOTARY_PROFILE is not set; notarization and stapling were skipped." >&2
fi

echo "Release archive: ${ZIP_PATH}"
echo "Architectures: ${ARCHITECTURES}"
