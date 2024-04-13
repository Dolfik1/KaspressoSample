{
  description = "Android app flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    android = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, android }:
    let
      buildToolsVersion = "33.0.0";
      cmakeVersion = "3.18.1";
    in
    with flake-utils.lib; eachSystem [ system.x86_64-linux system.x86_64-darwin system.aarch64-linux system.aarch64-darwin ] (system:
      let
        pkgs = import nixpkgs {
          system = if system == "aarch64-darwin" then "x86_64-darwin" else system; # aarch64-darwin not supported for Android SDK
          config = {
            allowUnsupportedSystem = true;
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
          overlays = [
            (self: super: {
              androidsdk = android.sdk.${system} (sdkPkgs: with sdkPkgs; [
                build-tools-33-0-0
                cmdline-tools-latest
                emulator
                platform-tools
                platforms-android-33
                ndk-21-4-7075529
                cmake-3-18-1
              ]
              ++ super.lib.optionals (system == "aarch64-darwin") [
                system-images-android-33-google-atd-arm64-v8a
              ]
              ++ super.lib.optionals (system == "x86_64-darwin" || system == "x86_64-linux") [
                system-images-android-33-google-atd-x86-64
              ]);
            })
          ];
        };
      in
      {
        devShells.default = pkgs.callPackage ./shell.nix { inherit buildToolsVersion cmakeVersion; };
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
