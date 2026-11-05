import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

// 发布签名材料不入库：
// - 本机用 `dart run tool/signing.dart` 生成 signing/keystore.properties 与 .jks；
// - CI 从仓库 Secrets 解码（见 .github/workflows/release.yml）。
// 缺失时 release 构建直接失败，而不是静默用 debug 签名发出去。
val repoRoot: File = project.rootProject.projectDir.parentFile
val keystoreFile = File(repoRoot, "signing/keystore.properties")
val hasReleaseSigning = keystoreFile.isFile
val keystoreProperties = Properties().apply {
    if (hasReleaseSigning) {
        // 属性文件可能带 UTF-8 BOM；直接 load 会把 BOM 当成第一个键的一部分。
        val text = keystoreFile.readText(Charsets.UTF_8).removePrefix("\uFEFF")
        text.reader().use { load(it) }
    }
}

android {
    namespace = "top.talyra42.tpl_starter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "top.talyra42.tpl_starter"
        // minSdk 26：Keystore 包裹密钥、BiometricPrompt、SAF 与通知权限在 26 上都可用。
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = File(
                    repoRoot,
                    keystoreProperties.getProperty("storeFile"),
                )
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                null
            }
            // 发布构建：R8 代码压缩 + 资源裁剪。
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

// 没签名时不要悄悄产出未签名 APK：直接失败并给出下一步命令。
tasks.matching {
    it.name.startsWith("assembleRelease") || it.name.startsWith("bundleRelease")
}.configureEach {
    doFirst {
        check(hasReleaseSigning) {
            "缺少签名配置 signing/keystore.properties；先运行：dart run tool/signing.dart"
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
