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
    target/aarch64-apple-darwin/release/libdefguard_boringtun.a target/uniffi

mv target/uniffi/defguard_boringtun.swift ${PWD}/../VPNExtension/BoringTun/
rm -f -r ${PWD}/../VPNExtension/BoringTun/defguard_boringtun.xcframework
xcrun xcodebuild -create-xcframework \
    -library target/aarch64-apple-darwin/release/libdefguard_boringtun.a -headers target/uniffi \
    -library target/aarch64-apple-ios/release/libdefguard_boringtun.a -headers target/uniffi \
    -library target/aarch64-apple-ios-sim/release/libdefguard_boringtun.a -headers target/uniffi \
    -output ${PWD}/../VPNExtension/BoringTun/defguard_boringtun.xcframework
mv target/uniffi/defguard_boringtunFFI.h ${PWD}/../VPNExtension/BoringTun/
