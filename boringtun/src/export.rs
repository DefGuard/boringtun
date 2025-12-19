//! Export bindings using `uniffi`.

use std::sync::{Arc, Mutex};

use crate::{
    noise::{Tunn, TunnResult, errors::WireGuardError},
    serialization::{KeyBytes, KeyBytesError},
};

const MIN_BUFFER_SIZE: usize = 148;

#[derive(uniffi::Object)]
pub struct Tunnel(Arc<Mutex<Tunn>>);

#[derive(uniffi::Record)]
pub struct TunnelStats {
    tx_bytes: u64,       // transmitted
    rx_bytes: u64,       // received
    last_handshake: u64, // timestamp (since UNIX epoch)
}

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
    #[must_use]
    #[uniffi::constructor]
    pub fn new(
        private_key: String,
        server_public_key: String,
        preshared_key: Option<String>,
        keep_alive: Option<u16>,
        index: u32,
    ) -> Result<Self, KeyBytesError> {
        let private_key = KeyBytes::from_string(&private_key)?;
        let server_public_key = KeyBytes::from_string(&server_public_key)?;
        let preshared_key = match preshared_key {
            Some(key) => Some(KeyBytes::from_string(&key)?),
            None => None,
        };
        let tunnel = Arc::new(Mutex::new(Tunn::new(
            private_key.0.into(),
            server_public_key.0.into(),
            preshared_key.map(|key| key.0),
            keep_alive,
            index,
            None,
        )));

        Ok(Self(tunnel))
    }

    #[must_use]
    pub fn tick(&self) -> TunnelResult {
        let mut dst = vec![0; MIN_BUFFER_SIZE];
        match self.0.lock() {
            Ok(mut tunn) => tunn.update_timers(dst.as_mut_slice()).into(),
            _ => TunnelResult::Err(WireGuardError::LockFailed),
        }
    }

    #[must_use]
    pub fn force_handshake(&self) -> TunnelResult {
        let mut dst = vec![0; MIN_BUFFER_SIZE];
        match self.0.lock() {
            Ok(mut tunn) => tunn
                .format_handshake_initiation(dst.as_mut_slice(), true)
                .into(),
            _ => TunnelResult::Err(WireGuardError::LockFailed),
        }
    }

    #[must_use]
    pub fn read(&self, src: &[u8]) -> TunnelResult {
        let dst_len = (src.len() + 32).max(MIN_BUFFER_SIZE);
        let mut dst = vec![0; dst_len];
        match self.0.lock() {
            Ok(mut tunn) => tunn.decapsulate(None, src, dst.as_mut_slice()).into(),
            _ => TunnelResult::Err(WireGuardError::LockFailed),
        }
    }

    #[must_use]
    pub fn write(&self, src: &[u8]) -> TunnelResult {
        let dst_len = (src.len() + 32).max(MIN_BUFFER_SIZE);
        let mut dst = vec![0; dst_len];
        match self.0.lock() {
            Ok(mut tunn) => tunn.encapsulate(src, dst.as_mut_slice()).into(),
            _ => TunnelResult::Err(WireGuardError::LockFailed),
        }
    }

    #[must_use]
    pub fn stats(&self) -> TunnelStats {
        match self.0.lock() {
            Ok(tunn) => {
                let (time, tx_bytes, rx_bytes, ..) = tunn.stats();
                TunnelStats {
                    tx_bytes: tx_bytes as u64,
                    rx_bytes: rx_bytes as u64,
                    last_handshake: time.map_or(0, |dur| dur.as_secs()),
                }
            }
            _ => TunnelStats {
                tx_bytes: 0,
                rx_bytes: 0,
                last_handshake: 0,
            },
        }
    }
}
