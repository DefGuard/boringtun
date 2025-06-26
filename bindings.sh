#!/bin/sh
set -e

cargo build --release
cargo run --release --bin uniffi-bindgen generate \
    --library target/release/libboringtun.dylib \
    --language swift \
    --out-dir ${HOME}/Projects/NetExt/BoringTun
ln -f -s ${PWD}/target/release/libboringtun.dylib ${PWD}/NetExt/BoringTun/libboringtun.dylib
