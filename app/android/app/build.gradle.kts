plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java . util . Properties
        import java . io . FileInputStream

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

var flutterVersionCode = localProperties.getProperty("flutter.versionCode")?.toInt()
if (flutterVersionCode == null) {
    flutterVersionCode = 1
}

var flutterVersionName = localProperties.getProperty("flutter.versionName")
if (flutterVersionName == null) {
    flutterVersionName = "1.0"
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "health.studyu.app"
    compileSdk = maxOf(flutter.compileSdkVersion, 37)
    compileSdkMinor = 0
    // Start flutter_local_notifications
    // compileSdk = 35
    // End flutter_local_notifications
    //compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Start flutter_local_notifications
        // Flag to enable support for the new language APIs
        isCoreLibraryDesugaringEnabled = true
        // End flutter_local_notifications
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    defaultConfig {
        // Start flutter_local_notifications
        multiDexEnabled = true
        // End flutter_local_notifications
        applicationId = "health.studyu.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // minSdk = maxOf(flutter.minSdkVersion, 23)
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig =
                if (keystorePropertiesFile.exists())
                    signingConfigs.getByName("release")
                else signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Start flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Fix crash on Android 12L / 13 using workaround
    // See https://github.com/flutter/flutter/issues/110658#issuecomment-1320834920
    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
    // End flutter_local_notifications
}
