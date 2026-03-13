# live555-unreal — LIVE555 Build for Unreal Engine

## Project Overview

LIVE555 Streaming Media is a C++ library for real-time multimedia streaming over IP networks (RTP/RTSP/RTCP). It provides infrastructure for streaming video and audio using standard protocols.

**Version**: 2026.02.13
**License**: LGPLv3 (see `live/COPYING.LESSER` and `live/COPYING`)
**Official Site**: http://www.live555.com/liveMedia/

---

This guide explains how to build LIVE555 shared libraries (.dll/.so) for Windows and Linux, ready to use as an Unreal Engine third-party plugin.

## Files

| File | Description |
|------|-------------|
| `build_windows.bat` | Windows build script (VS 2022, x64, shared libs) |
| `build_linux.sh` | Linux build script (Ubuntu, x64, shared libs) |
| `CMakeLists.txt` | Cross-platform CMake configuration |
| `UnrealPlugins/` | Pre-organized headers and library folders for UE integration |

## Unreal Engine ThirdParty Structure

After building, copy `UnrealPlugins/ThirdParty/live555/` into your Unreal plugin:

```
YourPlugin/
└── Source/
    └── ThirdParty/
        └── live555/
            ├── include/
            │   ├── UsageEnvironment/          # .hh headers
            │   ├── groupsock/                 # .hh/.h headers
            │   ├── BasicUsageEnvironment/     # .hh headers
            │   └── liveMedia/                 # .hh headers
            └── lib/
                ├── Win64/                     # .dll + .lib (import libraries)
                └── Linux/                     # .so
```

---

## Windows Build (Visual Studio 2022)

### Prerequisites
- Visual Studio 2022 with C++ workload
- CMake (included with VS 2022)

### Build Steps

1. **Open "x64 Native Tools Command Prompt for VS 2022"**
   - Search in Start Menu: "x64 Native Tools Command Prompt"

2. **Navigate to Live555 folder**
   ```cmd
   cd path\to\Live555
   ```

3. **Run build script**
   ```cmd
   build_windows.bat
   ```
   For Debug build:
   ```cmd
   build_windows.bat Debug
   ```

4. **Output**
   - DLLs: `build_vs2022\Release\*.dll`
   - Import libraries: `build_vs2022\Release\*.lib`

5. **Copy to UnrealPlugins**
   ```cmd
   copy build_vs2022\Release\*.dll UnrealPlugins\ThirdParty\live555\lib\Win64\
   copy build_vs2022\Release\*.lib UnrealPlugins\ThirdParty\live555\lib\Win64\
   ```

### Manual Build (Alternative)
```cmd
mkdir build_vs2022
cd build_vs2022
cmake -G "Visual Studio 17 2022" -A x64 -DBUILD_SHARED_LIBS=ON ..
cmake --build . --config Release
```

---

## Linux Build (Ubuntu)

### Prerequisites
```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake
```

### Build Steps

1. **Copy the entire `Live555` folder to Linux**

2. **Navigate to folder**
   ```bash
   cd /path/to/Live555
   ```

3. **Make script executable**
   ```bash
   chmod +x build_linux.sh
   ```

4. **Run build script**
   ```bash
   ./build_linux.sh
   ```
   For Debug build:
   ```bash
   ./build_linux.sh Debug
   ```

5. **Copy to UnrealPlugins**
   ```bash
   mkdir -p UnrealPlugins/ThirdParty/live555/lib/Linux
   cp build_linux/*.so UnrealPlugins/ThirdParty/live555/lib/Linux/
   ```

### Manual Build (Alternative)
```bash
mkdir -p build_linux
cd build_linux
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON ..
make -j$(nproc)
```

---

## CMake Build Options

| Option | Default | Description |
|--------|---------|-------------|
| `BUILD_SHARED_LIBS` | ON | Build shared libraries (.so/.dll) |
| `LIVE555_NO_OPENSSL` | ON | Disable OpenSSL (simpler build) |
| `CMAKE_BUILD_TYPE` | Release | Build type (Release/Debug) |

---

## Testing

### Test with VLC
```
vlc rtsp://YOUR_IP:8554/stream
```

### Test with ffplay
```
ffplay rtsp://YOUR_IP:8554/stream
```

---

## Troubleshooting

### Windows: "'test' is not a member of 'std::atomic_flag'"
- Add `NO_STD_LIB=1` to preprocessor definitions

### Windows: DLL not found at runtime
- Ensure `.dll` files are in the same directory as your executable

### Linux: "undefined reference to 'pthread_create'"
- Link with `-lpthread`

### Linux: .so not found at runtime
- Set `LD_LIBRARY_PATH` or use `rpath` in your linker settings
