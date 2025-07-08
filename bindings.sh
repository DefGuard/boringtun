#!/bin/sh
set -e

CARGO="${HOME}/.cargo/bin/cargo"

for TARGET in aarch64-apple-darwin aarch64-apple-ios aarch64-apple-ios-sim
do
    echo "${TARGET}"
    ${CARGO} build --lib --release --target ${TARGET}
done

# ${CARGO} run --release --bin uniffi-bindgen -- generate \
#     --crate boringtun \
#     --library target/release/libboringtun.dylib \
#     --language swift \
#     --out-dir target/uniffi
rm -f -r target/uniffi
${CARGO} run --release --bin uniffi-bindgen -- \
    --xcframework --headers --modulemap --swift-sources \
    target/release/libboringtun.dylib target/uniffi
mv target/uniffi/boringtun.swift ${PWD}/NetExt/BoringTun/
rm -f -r ${PWD}/NetExt/BoringTun/boringtun.xcframework
xcrun xcodebuild -create-xcframework \
    -library target/aarch64-apple-darwin/release/libboringtun.dylib -headers target/uniffi \
    -library target/aarch64-apple-ios/release/libboringtun.dylib -headers target/uniffi \
    -library target/aarch64-apple-ios-sim/release/libboringtun.dylib -headers target/uniffi \
    -output ${PWD}/NetExt/BoringTun/boringtun.xcframework
mv target/uniffi/boringtunFFI.h ${PWD}/NetExt/BoringTun/
