#!/bin/sh
set -e

CARGO="${HOME}/.cargo/bin/cargo"
DST="${PWD}/../VPNExtension/BoringTun"

for TARGET in aarch64-apple-darwin aarch64-apple-ios aarch64-apple-ios-sim
do
    echo "${TARGET}"
    ${CARGO} build --lib --release --target ${TARGET}
done

rm -f -r target/uniffi
${CARGO} run --release --bin uniffi-bindgen -- \
    --xcframework --headers --modulemap --swift-sources \
    target/aarch64-apple-darwin/release/libdefguard_boringtun.a target/uniffi

mkdir -p "${DST}"
mv target/uniffi/defguard_boringtun.swift ${DST}/
rm -f -r ${DST}/defguard_boringtun.xcframework
xcrun xcodebuild -create-xcframework \
    -library target/aarch64-apple-darwin/release/libdefguard_boringtun.a -headers target/uniffi \
    -library target/aarch64-apple-ios/release/libdefguard_boringtun.a -headers target/uniffi \
    -library target/aarch64-apple-ios-sim/release/libdefguard_boringtun.a -headers target/uniffi \
    -output ${DST}/defguard_boringtun.xcframework
mv target/uniffi/defguard_boringtunFFI.h ${DST}/
