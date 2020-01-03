set(CMAKE_SYSTEM_NAME Android)
set(CMAKE_SYSTEM_VERSION 28)
set(CMAKE_ANDROID_STANDALONE_TOOLCHAIN <TOOLCHAIN_PATH>)
set(CMAKE_ANDROID_ARCH_ABI <ABI>)

# look up for cmake, header and so files in our output directory
set(CMAKE_FIND_ROOT_PATH <FIND_ROOT_PATH>)
# never lookup executables needed at build time in toolchain sysroot or the
# output directory
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# lookup required packages, include and so files only in the toolchain sysroot
# or the directory provided above
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
