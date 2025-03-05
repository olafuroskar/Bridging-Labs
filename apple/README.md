# Lab Streaming Layer for Apple

To enable the use of LSL on Apple devices, iOS more specifcally, certain steps must be taken to generate a suitable library to use. The flutter plugin `lsl_plugin` uses a so called `vendored_framework` to get the compiled code from which the Dart bindings used in the plugin are generated.

This document describes the steps to generate the `vendored_framework` for the `lsl_plugin` plugin. In the `liblsl-1.16` is the latest version of `liblsl` with a few key modifications.

The inclusion of an `Info.plist` file and a modification of the `CMakeLists.txt` which is similar to what is described in the following diff file.

```diff
commit f8243f4d54929d531b49734b91683a538b837026
Author: Florin Pop <florin@ae.studio>
Date:   Wed Nov 22 07:10:26 2023 +0100

    Set bundle identifier and info.plist for Apple platforms

diff --git a/CMakeLists.txt b/CMakeLists.txt
index ac783f64..ac7a2e76 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -336,10 +336,6 @@ install(FILES

 include(cmake/LSLCMake.cmake)

-add_executable(lslver testing/lslver.c)
-target_link_libraries(lslver PRIVATE lsl)
-installLSLApp(lslver)
-
 if(LSL_TOOLS)
 	add_executable(blackhole testing/blackhole.cpp)
 	target_link_libraries(blackhole PRIVATE Threads::Threads)
@@ -347,6 +343,16 @@ if(LSL_TOOLS)
 	installLSLApp(blackhole)
 endif()

+if(APPLE)
+	set_target_properties(lsl PROPERTIES
+        MACOSX_BUNDLE TRUE
+        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
+        XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.my.bundle"
+		XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "XXX"
+		XCODE_ATTRIBUTE_CODE_SIGN_STYLE "Automatic"
+    )
+endif()
+
 set(LSL_INSTALL_ROOT ${CMAKE_CURRENT_BINARY_DIR})
 if(LSL_UNITTESTS)
 	add_subdirectory(testing)
diff --git a/Info.plist b/Info.plist
new file mode 100644
index 00000000..d16db365
--- /dev/null
+++ b/Info.plist
@@ -0,0 +1,22 @@
+<?xml version="1.0" encoding="UTF-8"?>
+<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
+<plist version="1.0">
+<dict>
+    <key>CFBundleExecutable</key>
+    <string>${EXECUTABLE_NAME}</string>
+    <key>CFBundleIdentifier</key>
+    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
+    <key>CFBundleInfoDictionaryVersion</key>
+    <string>6.0</string>
+    <key>CFBundleName</key>
+    <string>${PRODUCT_NAME}</string>
+    <key>CFBundlePackageType</key>
+    <string>APPL</string>
+    <key>CFBundleShortVersionString</key>
+    <string>1.0</string>
+    <key>CFBundleVersion</key>
+    <string>1</string>
+    <key>LSMinimumSystemVersion</key>
+    <string>${MACOSX_DEPLOYMENT_TARGET}</string>
+</dict>
+</plist>
```

Credit to github user `florin-pop` for [this comment](https://github.com/sccn/liblsl/issues/186#issuecomment-1824833598).
