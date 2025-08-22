// android/settings.gradle.kts

pluginManagement {
    // Read flutter.sdk from local.properties (or FLUTTER_SDK env)
    val props = java.util.Properties()
    val localPropsFile = File(settingsDir, "local.properties")
    if (localPropsFile.exists()) {
        localPropsFile.inputStream().use { props.load(it) }
    }
    val flutterSdk: String = props.getProperty("flutter.sdk")
        ?: System.getenv("FLUTTER_SDK")
        ?: throw GradleException("`flutter.sdk` not set in local.properties (or FLUTTER_SDK env).")

    // Allow Gradle to use Flutter's build logic
    includeBuild("$flutterSdk/packages/flutter_tools/gradle")

    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Not applied here; the :app module applies them
    id("com.android.application") version "8.7.0" apply(false)
    id("org.jetbrains.kotlin.android") version "1.9.24" apply(false)
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // Flutter's mirror for some artifacts
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

rootProject.name = "android"
include(":app") // ✅ Kotlin DSL (not "include ':app'")
