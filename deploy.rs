#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! toml = "0.8"
//! ```

use std::fs;
use std::path::Path;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Read manifest
    let manifest_path = "chips_manifest.toml";
    let manifest_content = fs::read_to_string(manifest_path)?;
    let manifest: toml::Table = toml::from_str(&manifest_content)?;

    let deploy_table = manifest
        .get("deploy")
        .ok_or("Missing [deploy] section in chips_manifest.toml")?
        .as_table()
        .ok_or("[deploy] must be a table")?;

    let destination = deploy_table
        .get("destination")
        .ok_or("Missing 'destination' in [deploy]")?
        .as_str()
        .ok_or("'destination' must be a string")?;

    let folders: Vec<&str> = deploy_table
        .get("folders")
        .ok_or("Missing 'folders' in [deploy]")?
        .as_array()
        .ok_or("'folders' must be an array")?
        .iter()
        .map(|v| v.as_str().unwrap_or(""))
        .collect();

    println!("Deploying to: {}", destination);

    // Clean destination
    if Path::new(destination).exists() {
        println!("Cleaning existing deployment directory...");
        fs::remove_dir_all(destination)?;
    }

    // Create destination
    fs::create_dir_all(destination)?;
    println!("Created fresh deployment directory");

    // Copy folders
    for folder in folders {
        let source_path = Path::new(folder);
        if !source_path.exists() {
            eprintln!("Warning: folder '{}' not found, skipping", folder);
            continue;
        }

        let dest_path = Path::new(destination).join(folder);
        copy_dir_all(source_path, &dest_path)?;
        println!("Deployed: {}", folder);
    }

    println!("Deployment complete!");
    Ok(())
}

fn copy_dir_all(src: &Path, dst: &Path) -> std::io::Result<()> {
    fs::create_dir_all(&dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let ty = entry.file_type()?;
        let path = entry.path();
        let file_name = entry.file_name();
        let dst_path = dst.join(&file_name);

        if ty.is_dir() {
            copy_dir_all(&path, &dst_path)?;
        } else {
            fs::copy(&path, &dst_path)?;
        }
    }
    Ok(())
}
