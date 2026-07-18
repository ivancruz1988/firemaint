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
    // AGP se mantiene en la ultima 8.x a proposito: file_picker 11.0.2 (ultima
    // version publicada) solo aplica el plugin de Kotlin cuando detecta AGP < 9,
    // por lo que con AGP 9 sus fuentes .kt no se compilan y falla el registro de
    // plugins (`cannot find symbol FilePickerPlugin`). Revisar al actualizar
    // file_picker: si soporta AGP 9, se puede volver a subir.
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")
