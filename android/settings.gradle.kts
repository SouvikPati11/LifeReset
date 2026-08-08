pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
    // Wires Firebase/Google Sign-In native config from google-services.json.
    // The build succeeds with the current file; Google Sign-In only starts
    // returning tokens once the app's SHA-1 is registered in the Firebase
    // Console and google-services.json is re-downloaded with a populated
    // oauth_client (see the README / task notes).
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")
