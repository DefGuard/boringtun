#!/bin/sh
set -e

CARGO="${HOME}/.cargo/bin/cargo"

for TARGET in aarch64-apple-darwin aarch64-apple-ios aarch64-apple-ios-sim
do
    echo "${TARGET}"
    ${CARGO} build --lib --release --target ${TARGET}
done

# ${CARGO} build --lib --release
# ${CARGO} run --release --bin uniffi-bindgen -- generate \
#     --crate boringtun \
#     --library target/release/libboringtun.dylib \
#     --language swift \
#     --out-dir target/uniffi

rm -f -r target/uniffi
${CARGO} run --release --bin uniffi-bindgen -- \
    --xcframework --headers --modulemap --swift-sources \
    target/aarch64-apple-darwin/release/libboringtun.a target/uniffi

# swiftc \
#     -module-name boringtun \
#     -emit-library -o libboringtun.dylib \
#     -emit-module -emit-module-path ${PWD}/NetExt/BoringTun/ \
#     -parse-as-library \
#     -I target/uniffi/ \
#     -L target/release/ \
#     -lboringtun \
#     -Xcc -fmodule-map-file=target/uniffi/boringtunFFI.modulemap \
#     target/uniffi/boringtun.swift

mv target/uniffi/boringtun.swift ${PWD}/../VPNExtension/BoringTun/
rm -f -r ${PWD}/../VPNExtension/BoringTun/boringtun.xcframework
xcrun xcodebuild -create-xcframework \
    -library target/aarch64-apple-darwin/release/libboringtun.a -headers target/uniffi \
    -library target/aarch64-apple-ios/release/libboringtun.a -headers target/uniffi \
    -library target/aarch64-apple-ios-sim/release/libboringtun.a -headers target/uniffi \
    -output ${PWD}/../VPNExtension/BoringTun/boringtun.xcframework
mv target/uniffi/boringtunFFI.h ${PWD}/../VPNExtension/BoringTun/
