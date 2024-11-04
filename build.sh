#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found!"
  exit 1
fi

# Now, the variables from .env are available in the script
# Clear previous build
rm -rf ./build
rm -rf ./debian-repo/dists/stable/main/binary-amd64

# Create the directory structure for the .deb package
BUILD_DIR="./build/${PACKAGE_NAME}_${VERSION}_${ARCH}"
BIN_DIR="${BUILD_DIR}/usr/local/bin"
DEBIAN_DIR="${BUILD_DIR}/DEBIAN"

# Create necessary directories
mkdir -p "$BIN_DIR"
mkdir -p "$DEBIAN_DIR"

# Copy the script to the bin directory and rename to "gitman" in the package
cp src/gitman.sh "$BIN_DIR/gitman"
chmod +x "$BIN_DIR/gitman"  # Ensure the script is executable

# Create the control file with package metadata
cat <<EOL > "${DEBIAN_DIR}/control"
Package: $PACKAGE_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Essential: no
Maintainer: $MAINTAINER
Description: $DESCRIPTION
EOL

echo "Control file created with package metadata."

# Build the .deb package
dpkg-deb --build "$BUILD_DIR"
echo "Package built successfully: ${BUILD_DIR}.deb"

# Set up debian-repo directory structure
REPO_DIR="./debian-repo"
PACKAGE_DIR="./dists/stable/main/binary-amd64"
REPO_PACKAGE_DIR="./debian-repo/dists/stable/main/binary-amd64"
mkdir -p "$REPO_PACKAGE_DIR"

# Copy the .deb package to debian-repo
cp "${BUILD_DIR}.deb" "$REPO_PACKAGE_DIR"

# Generate Packages and Packages.gz files
cd "$REPO_DIR"
dpkg-scanpackages . /dev/null > "$PACKAGE_DIR"/Packages
cd "$PACKAGE_DIR"
gzip -k -f Packages

# Create Release file with more comprehensive metadata
cat <<EOL > Release
Archive: stable
Component: main
Origin: GitHub
Label: $PACKAGE_NAME
Architecture: $ARCH
Version: $VERSION
Suite: stable
Codename: stable
Date: $(date -Ru)
EOL

echo "debian-repo prepared successfully with Packages, Packages.gz, and Release files."
