# Add project-specific ProGuard rules here.
# Flutter's default rules cover the engine; add rules below only if you
# hit obfuscation issues with specific plugins (e.g. reflection-based ones).

-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Hive
-keep class * extends com.hivedb.** { *; }
-keepclassmembers class * extends hive.HiveObject { *; }
