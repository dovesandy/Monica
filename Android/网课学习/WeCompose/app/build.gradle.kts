plugins {
  alias(libs.plugins.android.application)
  alias(libs.plugins.compose)
  alias(libs.plugins.serialization)
}

kotlin {
  jvmToolchain(21)
}

android {
  namespace = "com.rengwuxian.wecompose"
  compileSdk = 36

  defaultConfig {
    applicationId = "com.rengwuxian.wecompose"
    minSdk = 24
    targetSdk = 36
    versionCode = 1
    versionName = "1.0"

    testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
  }

  buildTypes {
    release {
      isMinifyEnabled = false
      proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
    }
  }
}

dependencies {
  implementation(libs.bundles.kotlinx)
  implementation(libs.bundles.androidx)
//  implementation(platform(libs.compose.bom))
  implementation(platform(libs.compose.bom.alpha))
  implementation(libs.bundles.compose)
  implementation(libs.bundles.nav3)

  debugImplementation(libs.bundles.compose.debug)

  testImplementation(libs.bundles.test)
  androidTestImplementation(libs.bundles.test.android)
}