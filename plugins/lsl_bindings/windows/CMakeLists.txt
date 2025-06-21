# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "lsl_bindings")
project(${PROJECT_NAME} LANGUAGES CXX)

set(LSL_SLIMARCHIVE ON CACHE BOOL "" FORCE)
set(LSL_SKIP_INSTALL ON CACHE INTERNAL "")

# Invoke the build for native code shared with the other target platforms.
# This can be changed to accommodate different builds.
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../src" "${CMAKE_CURRENT_BINARY_DIR}/shared")

# include_directories("${CMAKE_CURRENT_SOURCE_DIR}/../src/include")

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(lsl_bindings_bundled_libraries
  # Defined in ../src/CMakeLists.txt.
  # This can be changed to accommodate different builds.
  $<TARGET_FILE:lsl>
  PARENT_SCOPE
)
