#!/bin/bash

# Clear previous build
rm -rf ./build

# Set package variables
PACKAGE_NAME="gitman"
VERSION="1.0"
ARCH="amd64"
MAINTAINER="Lucian Blazek <lucian.blazek@gmail.com>"
DESCRIPTION="Git branch management tool for syncing and cleaning branches."

# Create the directory structure for the .deb package
BUILD_DIR="./build/${PACKAGE_NAME}_${VERSION}_${ARCH}"
BIN_DIR="${BUILD_DIR}/usr/local/bin"
DEBIAN_DIR="${BUILD_DIR}/DEBIAN"

# Clean up previous build if it exists
rm -rf "$BUILD_DIR"

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