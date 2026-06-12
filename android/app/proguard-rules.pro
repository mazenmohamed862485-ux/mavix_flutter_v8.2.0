# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep model classes (Gson/JSON deserialization)
-keep class com.mazencoach.mavix.** { *; }

# Sqflite
-keep class com.tekartik.sqflite.** { *; }

# Suppress warnings
-dontwarn io.flutter.**
-dontwarn okhttp3.**
-dontwarn okio.**
