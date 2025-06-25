//! Export bindings using `uniffi`.

use std::sync::{Arc, Mutex};

use aead::rand_core::OsRng;
use base64::prelude::*;

use crate::{
    // serialization::KeyBytes,
    noise::{errors::WireGuardError, Tunn, TunnResult},
    x25519::StaticSecret,
};

// TODO: use serialization::KeyBytes
#[derive(uniffi::Object)]
pub struct KeyBytes([u8; 32]);

#[uniffi::export]
impl KeyBytes {
    #[uniffi::constructor]
    pub fn secret() -> Self {
        let key = StaticSecret::random_from_rng(OsRng).to_bytes();
        Self(key)
    }

    /// Provide internal bytes as `Vec`.
    /// It is needed mainly to implmenet Equatable and Hashable in Swift.
    pub fn raw_bytes(&self) -> Vec<u8> {
        self.0.into()
    }

    /// Provide base64-encoded public key.
    pub fn public_key(&self) -> String {
        BASE64_STANDARD.encode(self.0)
    }
}

#[derive(uniffi::Object)]
pub struct Tunnel(Arc<Mutex<Tunn>>);

/// Mapping of `TunnResult` which can be exported with UniFFI.
#[derive(uniffi::Enum)]
pub enum TunnelResult {
    Done,
    Err(WireGuardError),
    WriteToNetwork(Vec<u8>),
    WriteToTunnelV4(Vec<u8>),
    WriteToTunnelV6(Vec<u8>),
}

impl<'a> From<TunnResult<'a>> for TunnelResult {
    fn from(result: TunnResult<'a>) -> Self {
        match result {
            TunnResult::Done => Self::Done,
            TunnResult::Err(e) => Self::Err(e),
            TunnResult::WriteToNetwork(bytes) => Self::WriteToNetwork(bytes.into()),
            TunnResult::WriteToTunnelV4(bytes, _) => Self::WriteToTunnelV4(bytes.into()),
            TunnResult::WriteToTunnelV6(bytes, _) => Self::WriteToTunnelV6(bytes.into()),
        }
    }
}

#[uniffi::export]
impl Tunnel {
    #[uniffi::constructor]
    pub fn new(
        private_key: &KeyBytes,
        server_public_key: &KeyBytes,
        // preshared_key: Option<&KeyBytes>,
        keep_alive: Option<u16>,
        index: u32,
    ) -> Self {
        let tunnel = Arc::new(Mutex::new(Tunn::new(
            private_key.0.into(),
            server_public_key.0.into(),
            // preshared_key.map(|key| key.0.into()),
            None,
            keep_alive,
            index,
            None,
        )));

        Self(tunnel)
    }

    pub fn read(&self, src: &[u8]) -> TunnelResult {
        let dst_len = src.len().max(148);
        let mut dst = vec![0; dst_len];
        if let Ok(mut tunn) = self.0.lock() {
            tunn.decapsulate(None, src, dst.as_mut_slice()).into()
        } else {
            // FIXME
            TunnelResult::Done
        }
    }

    pub fn write(&self, src: &[u8]) -> TunnelResult {
        let dst_len = src.len().max(148);
        let mut dst = vec![0; dst_len];
        if let Ok(mut tunn) = self.0.lock() {
            tunn.encapsulate(src, dst.as_mut_slice()).into()
        } else {
            // FIXME
            TunnelResult::Done
        }
    }
}
