#!/bin/bash
# LIVE555 Linux Build Script (x64) - Dynamic Libraries (.so)
# Usage: ./build_linux.sh [Debug|Release]

set -e

# Configuration
BUILD_TYPE="${1:-Release}"
BUILD_DIR="build_linux"

# Check architecture
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
    echo "Warning: This script is designed for x86_64 (64-bit) systems."
    echo "Current architecture: $ARCH"
fi

echo ""
echo "========================================"
echo "LIVE555 Linux Build (x64) - Shared Libraries"
echo "Build Type: $BUILD_TYPE"
echo "Architecture: $ARCH"
echo "========================================"
echo ""

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure with CMake (shared libraries for LGPLv3 compliance)
cmake -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
      -DBUILD_SHARED_LIBS=ON \
      -DLIVE555_NO_OPENSSL=ON \
      ..

# Build
make -j$(nproc)

echo ""
echo "========================================"
echo "Build successful! (x64)"
echo "Libraries are in: $(pwd)"
echo "========================================"
echo ""
echo "Output files:"
ls -la *.so 2>/dev/null || echo "  (no .so files found)"
echo ""
echo "Verify 64-bit:"
file *.so 2>/dev/null | head -1 || echo "  (cannot verify)"
echo ""
echo "To copy to UnrealPlugins:"
echo "  mkdir -p ../UnrealPlugins/ThirdParty/live555/lib/Linux"
echo "  cp *.so ../UnrealPlugins/ThirdParty/live555/lib/Linux/"
