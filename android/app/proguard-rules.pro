# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Firebase (broad)
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Google Sign-In (explicit, prevents R8 stripping auth classes)
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Firestore / protobuf reflection
-keep class com.google.firebase.firestore.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn com.google.protobuf.**

# Crashlytics
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**
