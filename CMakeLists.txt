cmake_minimum_required(VERSION 3.15)
project(live555 VERSION 2026.02.13 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source code root
set(LIVE555_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/live)

# Build options
option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(LIVE555_NO_OPENSSL "Disable OpenSSL support" ON)

# Windows: export all symbols from DLLs (LIVE555 has no dllexport annotations)
if(BUILD_SHARED_LIBS AND WIN32)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

# Platform-specific settings
if(WIN32)
    add_definitions(-DNO_OPENSSL=1)
    add_definitions(-DSOCKLEN_T=int)
    add_definitions(-DNO_GETIFADDRS=1)
    add_definitions(-DNO_STD_LIB=1)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    add_definitions(-D_WINSOCK_DEPRECATED_NO_WARNINGS)
elseif(UNIX)
    add_definitions(-DNO_OPENSSL=1)
    add_definitions(-DSOCKLEN_T=socklen_t)
    add_definitions(-DBSD=1)
    add_definitions(-D_LARGEFILE_SOURCE=1)
    add_definitions(-D_FILE_OFFSET_BITS=64)

    # Ensure 64-bit build
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m64")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -m64")

    # Shared library settings
    if(BUILD_SHARED_LIBS)
        set(CMAKE_POSITION_INDEPENDENT_CODE ON)
    endif()

    # Find pthreads
    find_package(Threads REQUIRED)
endif()

# Include directories
set(GROUPSOCK_INCLUDE ${LIVE555_SOURCE_DIR}/groupsock/include)
set(USAGE_ENV_INCLUDE ${LIVE555_SOURCE_DIR}/UsageEnvironment/include)
set(BASIC_USAGE_ENV_INCLUDE ${LIVE555_SOURCE_DIR}/BasicUsageEnvironment/include)
set(LIVEMEDIA_INCLUDE ${LIVE555_SOURCE_DIR}/liveMedia/include)

# ============== UsageEnvironment Library ==============
set(USAGE_ENV_SOURCES
    ${LIVE555_SOURCE_DIR}/UsageEnvironment/UsageEnvironment.cpp
    ${LIVE555_SOURCE_DIR}/UsageEnvironment/HashTable.cpp
    ${LIVE555_SOURCE_DIR}/UsageEnvironment/strDup.cpp
    # BasicHashTable implements HashTable::Iterator::create() — required by HashTable.cpp
    ${LIVE555_SOURCE_DIR}/BasicUsageEnvironment/BasicHashTable.cpp
)

add_library(UsageEnvironment ${USAGE_ENV_SOURCES})
target_include_directories(UsageEnvironment PUBLIC ${USAGE_ENV_INCLUDE} ${GROUPSOCK_INCLUDE} ${BASIC_USAGE_ENV_INCLUDE})

# ============== groupsock Library ==============
set(GROUPSOCK_SOURCES
    ${LIVE555_SOURCE_DIR}/groupsock/GroupsockHelper.cpp
    ${LIVE555_SOURCE_DIR}/groupsock/GroupEId.cpp
    ${LIVE555_SOURCE_DIR}/groupsock/Groupsock.cpp
    ${LIVE555_SOURCE_DIR}/groupsock/NetInterface.cpp
    ${LIVE555_SOURCE_DIR}/groupsock/NetAddress.cpp
    ${LIVE555_SOURCE_DIR}/groupsock/inet.c
    ${LIVE555_SOURCE_DIR}/groupsock/IOHandlers.cpp
)

add_library(groupsock ${GROUPSOCK_SOURCES})
target_include_directories(groupsock PUBLIC ${GROUPSOCK_INCLUDE} ${USAGE_ENV_INCLUDE})
target_link_libraries(groupsock PUBLIC UsageEnvironment)
if(WIN32)
    target_link_libraries(groupsock PUBLIC ws2_32)
endif()

# ============== BasicUsageEnvironment Library ==============
set(BASIC_USAGE_ENV_SOURCES
    ${LIVE555_SOURCE_DIR}/BasicUsageEnvironment/BasicUsageEnvironment.cpp
    ${LIVE555_SOURCE_DIR}/BasicUsageEnvironment/BasicUsageEnvironment0.cpp
    ${LIVE555_SOURCE_DIR}/BasicUsageEnvironment/BasicTaskScheduler.cpp
    ${LIVE555_SOURCE_DIR}/BasicUsageEnvironment/BasicTaskScheduler0.cpp
    ${LIVE555_SOURCE_DIR}/BasicUsageEnvironment/DelayQueue.cpp
)

add_library(BasicUsageEnvironment ${BASIC_USAGE_ENV_SOURCES})
target_include_directories(BasicUsageEnvironment PUBLIC ${BASIC_USAGE_ENV_INCLUDE} ${USAGE_ENV_INCLUDE} ${GROUPSOCK_INCLUDE})
target_link_libraries(BasicUsageEnvironment PUBLIC UsageEnvironment groupsock)

# ============== liveMedia Library ==============
file(GLOB LIVEMEDIA_SOURCES
    "${LIVE555_SOURCE_DIR}/liveMedia/*.cpp"
    "${LIVE555_SOURCE_DIR}/liveMedia/*.c"
)

add_library(liveMedia ${LIVEMEDIA_SOURCES})
target_include_directories(liveMedia PUBLIC
    ${LIVEMEDIA_INCLUDE}
    ${GROUPSOCK_INCLUDE}
    ${USAGE_ENV_INCLUDE}
    ${BASIC_USAGE_ENV_INCLUDE}
    ${LIVE555_SOURCE_DIR}/liveMedia
)
target_link_libraries(liveMedia PUBLIC BasicUsageEnvironment groupsock UsageEnvironment)
if(UNIX)
    target_link_libraries(liveMedia PUBLIC Threads::Threads)
endif()

# ============== Install Configuration ==============
install(TARGETS UsageEnvironment groupsock BasicUsageEnvironment liveMedia
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY ${USAGE_ENV_INCLUDE}/ DESTINATION include/UsageEnvironment FILES_MATCHING PATTERN "*.hh")
install(DIRECTORY ${GROUPSOCK_INCLUDE}/ DESTINATION include/groupsock FILES_MATCHING PATTERN "*.hh" PATTERN "*.h")
install(DIRECTORY ${BASIC_USAGE_ENV_INCLUDE}/ DESTINATION include/BasicUsageEnvironment FILES_MATCHING PATTERN "*.hh")
install(DIRECTORY ${LIVEMEDIA_INCLUDE}/ DESTINATION include/liveMedia FILES_MATCHING PATTERN "*.hh")

message(STATUS "LIVE555 Streaming Media configured for build")
message(STATUS "  Source dir: ${LIVE555_SOURCE_DIR}")
message(STATUS "  Platform: ${CMAKE_SYSTEM_NAME}")
message(STATUS "  OpenSSL disabled: ${LIVE555_NO_OPENSSL}")
message(STATUS "  Shared libs: ${BUILD_SHARED_LIBS}")
