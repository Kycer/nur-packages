{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  fontconfig,
  freetype,
  libgbm,
  libpulseaudio,
  libva,
  libxcb,
  libxkbcommon,
  openssl,
  pipewire,
}:

let
  assets = {
    x86_64-linux = {
      arch = "x86_64";
      hash = "sha256-GJhBDdmwAVjdyl6HEdgFnbsi13OvMiIZK1YDMt5k6s8=";
    };
    aarch64-linux = {
      arch = "aarch64";
      hash = "sha256-QTg/zRfF3Zfvn5Wi7p7c5XLIAgPNQg5/qn0ckhYI0C4=";
    };
  };
  asset = assets.${stdenv.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mark-shot";
  version = "0.2.5";

  src = fetchurl {
    url = "https://github.com/jswysnemc/mark-shot/releases/download/v${finalAttrs.version}/mark-shot-native-${finalAttrs.version}-linux-${asset.arch}.tar.gz";
    inherit (asset) hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    fontconfig
    freetype
    libgbm
    libva
    libxcb
    libxkbcommon
    openssl
    pipewire
    stdenv.cc.cc.lib
  ];

  # The media and OCR loaders open these libraries and GPU drivers at runtime.
  appendRunpaths = [
    "${lib.getLib libpulseaudio}/lib"
    "${stdenv.cc.cc.lib}/lib"
    "/run/opengl-driver/lib"
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp -r usr/lib usr/share "$out/"
    makeWrapper "$out/lib/mark-shot/mark-shot" "$out/bin/mark-shot" \
      --prefix PATH : ${lib.makeBinPath [ fontconfig ]}
    substituteInPlace "$out/share/applications/io.github.jswysnemc.MarkShot.desktop" \
      --replace-fail '/usr/bin/mark-shot' "$out/bin/mark-shot"

    runHook postInstall
  '';

  # Patching and stripping the media library changes the upstream checksum.
  postPhases = [ "updateMediaChecksums" ];
  updateMediaChecksums = ''
    (cd "$out/lib/mark-shot/media" && sha256sum libmarkshot-media.so MEDIA-SOURCES.tar.xz > SHA256SUMS)
  '';

  meta = {
    description = "Native screenshot, annotation and recording tool";
    homepage = "https://github.com/jswysnemc/mark-shot";
    license = with lib.licenses; [ mit asl20 ];
    mainProgram = "mark-shot";
    platforms = builtins.attrNames assets;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
