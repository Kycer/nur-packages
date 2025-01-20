{ lib, stdenv, fetchurl, makeWrapper, ... }:

stdenv.mkDerivation rec {
  pname = "jetbrains-idea";
  version = "2024.3.2";

  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/idea/ideaIU-${version}.tar.gz";
    sha256 =
      "05f30fff53c1b73f9c261e812c236134e203bf7d847424a27d9409fd6b0b6fcb"; # 使用正确的 SHA256 值
  };

  nativeBuildInputs = [ makeWrapper ];

  unpackPhase = "true"; # IDEA 使用的是压缩包格式，不需要解压的标准步骤

  installPhase = ''
    echo "Source: $src"
    mkdir -p $out/idea
    tar -xzf $src -C $out

    wrapProgram $out/idea-IU-243.23654.117/bin/idea --set JAVA_HOME ${stdenv.cc.cc}/libexec/java

    ln -s $out/idea-IU-243.23654.117/bin/idea $out/bin/idea
  '';

}
