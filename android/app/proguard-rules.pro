# Flutter specific proguard rules

# Keep Flutter app
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Firebase if you're using it
# -keep class com.google.firebase.** { *; }

# Keep plugin classes
-keep class com.airfryerrecipes.app.** { *; }

# Kotlin specific
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Keep custom application class if you have one
-keep public class * extends android.app.Application

# Don't warn about Kotlin Intrinsics calls
-dontwarn kotlin.jvm.internal.Intrinsics

# Flutter WebRTC
-keep class org.webrtc.** { *; }

# SQLite
-keep class com.tekartik.sqflite.** { *; }