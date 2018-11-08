use std::process::Command;

fn main() {
    // Rerun the build script when files in the resources folder are changed.
    println!("cargo:rerun-if-changed=data");
    println!("cargo:rerun-if-changed=data/*");

    println!("Run glib-compile-resources...");
    let out = Command::new("glib-compile-resources")
        .args(&["--generate", "resources.xml"])
        .current_dir("data")
        .status()
        .expect("failed to generate resources");
    assert!(out.success());
}

