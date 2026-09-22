# HyperBid Flutter SDK ProGuard rules.
# Reference: SDK-Import-and-Initialization.md §4.3
#
# Wire this file into your release build, e.g. in android/app/build.gradle.kts:
#   buildTypes { getByName("release") {
#     proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"),
#                   "proguard-rules.pro")
#   } }

-keep class com.mcsdk.flutterbridge.** { *; }
-keepclassmembers class com.mcsdk.flutterbridge.** {
   public *;
}

# --- R8 full mode fix: WorkManager (bundled with ad-network SDKs) initializes
# its Room database via reflection; keep the generated _Impl or startup crashes
# with "Failed to create an instance of class androidx.work.impl.WorkDatabase".
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.work.impl.WorkManagerInitializer { <init>(); }
