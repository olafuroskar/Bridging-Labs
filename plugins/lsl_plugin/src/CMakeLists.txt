# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(lsl_plugin_library VERSION 0.0.1 LANGUAGES C)

add_library(lsl_plugin SHARED
  "lsl_plugin.c"
)

set_target_properties(lsl_plugin PROPERTIES
  PUBLIC_HEADER lsl_plugin.h
  OUTPUT_NAME "lsl_plugin"
)

target_compile_definitions(lsl_plugin PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(lsl_plugin PRIVATE "-Wl,-z,max-page-size=16384")
endif()
