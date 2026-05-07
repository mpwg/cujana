#!/usr/bin/env bash
set -euo pipefail

DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-.xcode-derived-data}"
ARCHS="${ARCHS:-arm64}"
IPHONEOS_DEPLOYMENT_TARGET="${IPHONEOS_DEPLOYMENT_TARGET:-26.0}"
MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-26.0}"
TEST_DESTINATION="${TEST_DESTINATION:-platform=macOS,arch=arm64,variant=Mac Catalyst}"

xcodebuild -resolvePackageDependencies \
  -project Cujana.xcodeproj \
  -scheme Cujana-UnitTests \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -onlyUsePackageVersionsFromResolvedFile \
  -skipPackageUpdates

xcodebuild build-for-testing -quiet -showBuildTimingSummary \
  -project Cujana.xcodeproj \
  -scheme Cujana-UnitTests \
  -destination 'generic/platform=macOS,variant=Mac Catalyst' \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -onlyUsePackageVersionsFromResolvedFile \
  -skipPackageUpdates \
  -parallelizeTargets \
  -jobs "$(sysctl -n hw.ncpu)" \
  ARCHS="$ARCHS" \
  COMPILER_INDEX_STORE_ENABLE=NO \
  IPHONEOS_DEPLOYMENT_TARGET="$IPHONEOS_DEPLOYMENT_TARGET" \
  MACOSX_DEPLOYMENT_TARGET="$MACOSX_DEPLOYMENT_TARGET" \
  CODE_SIGNING_ALLOWED=NO

xctestrun_path="$(find "$DERIVED_DATA_PATH/Build/Products" -maxdepth 1 -name '*.xctestrun' -print -quit)"
if [ -z "$xctestrun_path" ]; then
  echo "No xctestrun file was produced by build-for-testing." >&2
  exit 1
fi

xcodebuild test-without-building -quiet -showBuildTimingSummary \
  -xctestrun "$xctestrun_path" \
  -destination "$TEST_DESTINATION" \
  -parallel-testing-enabled YES \
  -maximum-parallel-testing-workers 4 \
  -collect-test-diagnostics never \
  CODE_SIGNING_ALLOWED=NO
