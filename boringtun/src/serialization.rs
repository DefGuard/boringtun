use std::{fmt, str::FromStr};

use aead::OsRng;
use base64::prelude::*;
use x25519_dalek::StaticSecret;

const KEY_SIZE: usize = 32;

#[derive(uniffi::Object)]
pub struct KeyBytes(pub(crate) [u8; KEY_SIZE]);

#[derive(Debug, uniffi::Enum)]
pub enum KeyBytesError {
    IllegalCharacter,
    IllegalSize,
}

impl fmt::Display for KeyBytesError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{}",
            match self {
                Self::IllegalCharacter => "Illegal character in key",
                Self::IllegalSize => "Illegal key size",
            }
        )
    }
}

impl FromStr for KeyBytes {
    type Err = KeyBytesError;

    /// Can parse a secret key from a hex or base64 encoded string.
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut internal = [0u8; KEY_SIZE];

        match s.len() {
            64 => {
                // Try to parse as hex
                for i in 0..KEY_SIZE {
                    internal[i] = u8::from_str_radix(&s[i * 2..=i * 2 + 1], 16)
                        .map_err(|_| KeyBytesError::IllegalCharacter)?;
                }
            }
            43 | 44 => {
                // Try to parse as base64
                if let Ok(decoded_key) = BASE64_STANDARD.decode(s) {
                    if decoded_key.len() == internal.len() {
                        internal[..].copy_from_slice(&decoded_key);
                    } else {
                        return Err(KeyBytesError::IllegalCharacter);
                    }
                }
            }
            _ => return Err(KeyBytesError::IllegalSize),
        }

        Ok(KeyBytes(internal))
    }
}

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

    #[uniffi::constructor]
    pub fn from_string(s: &str) -> Result<Self, KeyBytesError> {
        Self::from_str(s)
    }

    #[uniffi::constructor]
    pub fn from_bytes(bytes: &[u8]) -> Result<Self, KeyBytesError> {
        let internal = bytes.try_into().map_err(|_| KeyBytesError::IllegalSize)?;
        Ok(Self(internal))
    }

    #[must_use]
    pub fn to_base64(&self) -> String {
        BASE64_STANDARD.encode(self.0)
    }

    #[must_use]
    pub fn to_lower_hex(&self) -> String {
        let mut hex = String::with_capacity(64);
        let to_char = |nibble: u8| -> char {
            (match nibble {
                0..=9 => b'0' + nibble,
                _ => nibble + b'a' - 10,
            }) as char
        };
        self.0.iter().for_each(|byte| {
            hex.push(to_char(*byte >> 4));
            hex.push(to_char(*byte & 0xf));
        });
        hex
    }
}
