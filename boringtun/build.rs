fn main() {
    #[cfg(target_os = "macos")]
    println!("cargo:rustc-link-arg=-Wl,-install_name,@rpath/libboringtun.dylib");
    #[cfg(target_os = "macos")]
    println!("cargo:rustc-link-arg=-Wl,-undefined,dynamic_lookup");
}
