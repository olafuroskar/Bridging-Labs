-dontwarn org.joda.convert.FromString
-dontwarn org.joda.convert.ToString

# Prevent Muse SDK classes from being obfuscated
-keep class com.choosemuse.libmuse.** { *; }

# If the SDK uses reflection, disable warnings
-dontwarn com.choosemuse.libmuse.**
