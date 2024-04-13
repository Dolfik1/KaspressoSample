{ pkgs, buildToolsVersion, cmakeVersion }:

with pkgs;
let
  jdk = openjdk17_headless;
  firebase-tools = nodePackages_latest.firebase-tools;
in
mkShell rec {
  nativeBuildInputs = [ androidsdk jdk ];
  buildInputs = [ apktool gradle_7 sdkmanager nixpkgs-fmt zlib yasm ccache firebase-tools coreutils rsync ];
  ANDROID_SDK_ROOT = "${androidsdk}/libexec/android-sdk";
  ANDROID_NDK_ROOT = "${ANDROID_SDK_ROOT}/ndk-bundle";

  GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_SDK_ROOT}/build-tools/${buildToolsVersion}/aapt2 -Pandroid.testoptions.manageddevices.emulator.gpu=swiftshader_indirect";

  shellHook = ''
    cmake_root="$(echo "$ANDROID_SDK_ROOT/cmake/${cmakeVersion}"*/)"
    export PATH="$cmake_root/bin:$PATH"
    export GRADLE_USER_HOME="/tmp"
    export ANDROID_SDK_HOME="/tmp/.android"
  '';
}
