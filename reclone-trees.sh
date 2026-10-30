#!/bin/bash
set -e

DEVICES=(
  "a25x"
  "s5e8825-common"
)
XML="$(pwd)/.repo/local_manifests/manifest.xml"
URL="https://github.com/FloppyBuilds"
[[ -z "$BRANCH" ]] && BRANCH="lineage-24.0"

if [[ ! -f "$XML" ]]; then
  echo "manifest.xml not found. Please execute from root dir."
  exit 1
fi

for m in "${DEVICES[@]}"; do
  sed -i "/$m/d" "$XML"
  (
  echo "Cloning $m"
  [ -d "$(pwd)/device/samsung/$m" ] && rm -rf "$(pwd)/device/samsung/$m"
  git clone -j"$(nproc --all)" -q "$URL/android_device_samsung_$m" -b "$BRANCH" "$(pwd)/device/samsung/$m"
  [ -d "$(pwd)/vendor/samsung/$m" ] && rm -rf "$(pwd)/vendor/samsung/$m"
  git clone -j"$(nproc --all)" -q "$URL/proprietary_vendor_samsung_$m" -b "$BRANCH" "$(pwd)/vendor/samsung/$m"
  ) &
done

# shellcheck disable=SC2046
wait $(jobs -p) || exit 1
