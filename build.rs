fn main() {
    println!("cargo:rustc-link-arg=-Tbuild/linker_scripts/mono_boot.ld");
    println!("cargo:rustc-linker=arm-none-eabi-ld");
    println!("cargo::rerun-if-changed=build.rs");
    println!("cargo::rerun-if-changed=src/foo.txt");
}
