{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  assets = {
    x86_64-linux = {
      target = "linux_amd64";
      hash = "sha256-7sSpEHZyRyv50nxu+Zg2OcgabHtqWKtYmGiFTKg1jLQ=";
    };
    aarch64-linux = {
      target = "linux_arm64";
      hash = "sha256-oTRUGFX91G+IQWSLlHgS4Y1r7HXL8eJHiIRN598PJi4=";
    };
    x86_64-darwin = {
      target = "darwin_amd64";
      hash = "sha256-ACDwlbLEPrkNUH9y0sHo+JS6MTYIaUu9E4rOinuD6ZU=";
    };
    aarch64-darwin = {
      target = "darwin_arm64";
      hash = "sha256-lb8Ae90ueWa2logFVRWdcMHCACWHZ+0hacO8etThHeo=";
    };
  };
  asset = assets.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sqlmux";
  version = "0.12.0";

  src = fetchurl {
    url = "https://github.com/kackerx/sqlmux/releases/download/v${finalAttrs.version}/sqlmux_${finalAttrs.version}_${asset.target}.tar.gz";
    inherit (asset) hash;
  };
  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 sqlmux "$out/bin/sqlmux"
    install -Dm644 LICENSE "$out/share/licenses/sqlmux/LICENSE"
    runHook postInstall
  '';

  meta = {
    description = "Tmux-style terminal database client with Vim keybindings";
    homepage = "https://github.com/kackerx/sqlmux";
    license = lib.licenses.mit;
    mainProgram = "sqlmux";
    platforms = builtins.attrNames assets;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
