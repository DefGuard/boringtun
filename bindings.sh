#!/bin/sh
set -e

CARGO="${HOME}/.cargo/bin/cargo"

for TARGET in aarch64-apple-darwin aarch64-apple-ios aarch64-apple-ios-sim
do
    echo "${TARGET}"
    ${CARGO} build --lib --release --target ${TARGET}
done

rm -f -r target/uniffi
${CARGO} run --release --bin uniffi-bindgen -- \
    --xcframework --headers --modulemap --swift-sources \
    target/aarch64-apple-darwin/release/libboringtun.a target/uniffi

mv target/uniffi/boringtun.swift ${PWD}/../VPNExtension/BoringTun/
rm -f -r ${PWD}/../VPNExtension/BoringTun/boringtun.xcframework
xcrun xcodebuild -create-xcframework \
    -library target/aarch64-apple-darwin/release/libboringtun.a -headers target/uniffi \
    -library target/aarch64-apple-ios/release/libboringtun.a -headers target/uniffi \
    -library target/aarch64-apple-ios-sim/release/libboringtun.a -headers target/uniffi \
    -output ${PWD}/../VPNExtension/BoringTun/boringtun.xcframework
mv target/uniffi/boringtunFFI.h ${PWD}/../VPNExtension/BoringTun/
