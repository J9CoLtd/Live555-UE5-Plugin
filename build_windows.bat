@echo off
REM LIVE555 Windows Build Script for Visual Studio 2022 - Dynamic Libraries (.dll)
REM Run this from "x64 Native Tools Command Prompt for VS 2022"

setlocal

REM Configuration
set BUILD_TYPE=Release
set BUILD_DIR=build_vs2022

REM Parse arguments
if "%1"=="Debug" set BUILD_TYPE=Debug
if "%1"=="Release" set BUILD_TYPE=Release

echo.
echo ========================================
echo LIVE555 Windows Build - Shared Libraries
echo Build Type: %BUILD_TYPE%
echo ========================================
echo.

REM Create build directory
if not exist %BUILD_DIR% mkdir %BUILD_DIR%
cd %BUILD_DIR%

REM Configure with CMake (shared libraries for LGPLv3 compliance)
cmake -G "Visual Studio 17 2022" -A x64 ^
    -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
    -DBUILD_SHARED_LIBS=ON ^
    -DLIVE555_NO_OPENSSL=ON ^
    ..

if errorlevel 1 (
    echo CMake configuration failed!
    exit /b 1
)

REM Build
cmake --build . --config %BUILD_TYPE% --parallel

if errorlevel 1 (
    echo Build failed!
    exit /b 1
)

echo.
echo ========================================
echo Build successful!
echo Libraries are in: %CD%\%BUILD_TYPE%
echo ========================================
echo.
echo Output files (.dll and .lib import libraries):
dir /b %BUILD_TYPE%\*.dll 2>nul
dir /b %BUILD_TYPE%\*.lib 2>nul
echo.
echo For Unreal Engine, copy:
echo   - %CD%\%BUILD_TYPE%\*.dll to your plugin's Binaries/Win64/
echo   - %CD%\%BUILD_TYPE%\*.lib to your plugin's ThirdParty/lib/Win64/
echo   - Header directories to your plugin's ThirdParty/include/

endlocal
