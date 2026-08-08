import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Applies the Firebase/Google-services config (see settings.gradle.kts).
    id("com.google.gms.google-services")
}

// ── Release signing ──────────────────────────────────────────────────────────
// The release build is signed with a dedicated release keystore so it always
// has a STABLE SHA-1/SHA-256 (required for Firebase Google Sign-In). The
// keystore + credentials are supplied either by a local `android/key.properties`
// file (git-ignored) or, in CI, by environment variables injected from GitHub
// Secrets. When neither is present (e.g. a fork PR with no secrets, or a plain
// local `flutter run`), the release build transparently falls back to the debug
// signing config so the build never breaks.
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) FileInputStream(f).use { load(it) }
}

fun signingValue(propKey: String, envKey: String): String? =
    keystoreProperties.getProperty(propKey) ?: System.getenv(envKey)

val releaseStorePath = signingValue("storeFile", "KEYSTORE_PATH")

android {
    namespace = "com.lifereset.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.lifereset.app"
        // minSdk 23 is required by the Firebase Auth / Firestore SDKs.
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            if (releaseStorePath != null) {
                storeFile = file(releaseStorePath)
                storePassword = signingValue("storePassword", "KEYSTORE_PASSWORD")
                keyAlias = signingValue("keyAlias", "KEY_ALIAS")
                keyPassword = signingValue("keyPassword", "KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            // Use the release keystore when it is configured (CI secrets or a
            // local key.properties); otherwise fall back to debug signing so
            // `flutter run --release` and secret-less CI builds still work.
            signingConfig = if (releaseStorePath != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
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
