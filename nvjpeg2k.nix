{pkgs}:
pkgs.stdenv.mkDerivation {
  pname = "nvjpeg2k-archive";
  version = "0.9.0.43";
  src = pkgs.fetchurl {
    url = "https://developer.download.nvidia.com/compute/nvjpeg2000/redist/libnvjpeg_2k/linux-x86_64/libnvjpeg_2k-linux-x86_64-0.9.0.43-archive.tar.xz";
    hash = "sha256-HSb2KnFB6BxgQ0KmEN64rY0Q4cCMtZWYiB3CAeWfIaM=";
  };
  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
}
