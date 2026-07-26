import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Carga las credenciales de firma desde android/key.properties (no versionado).
// Ver android/key.properties.example para generar el keystore y crear ese archivo.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val tieneKeystoreDeRelease = keystorePropertiesFile.exists()
if (tieneKeystoreDeRelease) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.firemaint.firemaint"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.firemaint.firemaint"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (tieneKeystoreDeRelease) {
            create("release") {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Usa el keystore de release si android/key.properties existe;
            // si no, cae al keystore de debug para que `flutter run --release`
            // siga funcionando en desarrollo. NO distribuir un APK/AAB firmado
            // asi: generar un keystore real antes de publicar. Ver
            // android/key.properties.example.
            signingConfig = if (tieneKeystoreDeRelease) {
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
