#!/bin/sh
set -e

DST="${PWD}/../VPNExtension/BoringTun"
TARGET_DIR="${CARGO_TARGET_DIR:-./target}"

for TARGET in aarch64-apple-darwin aarch64-apple-ios aarch64-apple-ios-sim
do
    echo "${TARGET}"
    cargo build --features bindgen --lib --release --target ${TARGET}
done

rm -f -r ${TARGET_DIR}/uniffi
cargo run --features bindgen --release --bin uniffi-bindgen -- \
    --xcframework --headers --modulemap --swift-sources \
    ${TARGET_DIR}/aarch64-apple-darwin/release/libdefguard_boringtun.a ${TARGET_DIR}/uniffi

mkdir -p "${DST}"
mv ${TARGET_DIR}/uniffi/defguard_boringtun.swift ${DST}/
rm -f -r ${DST}/defguard_boringtun.xcframework
xcrun xcodebuild -create-xcframework \
    -library ${TARGET_DIR}/aarch64-apple-darwin/release/libdefguard_boringtun.a \
    -headers ${TARGET_DIR}/uniffi \
    -library ${TARGET_DIR}/aarch64-apple-ios/release/libdefguard_boringtun.a \
    -headers ${TARGET_DIR}/uniffi \
    -library ${TARGET_DIR}/aarch64-apple-ios-sim/release/libdefguard_boringtun.a \
    -headers ${TARGET_DIR}/uniffi \
    -output ${DST}/defguard_boringtun.xcframework
mv ${TARGET_DIR}/uniffi/defguard_boringtunFFI.h ${DST}/
