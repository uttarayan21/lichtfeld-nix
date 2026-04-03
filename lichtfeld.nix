{
  cmake,
  cudaPackages,
  cudatoolkit,
  glad,
  lib,
  ninja,
  pkgs,
  rmlui,
  src,
  vcpkg,
  openimageio,
}:
pkgs.stdenv.mkDerivation {
  pname = "lichtfeld-studio";
  version = "0.1.0";
  src = src;
  hooks = [cmake];
  nativeBuildInputs = [cmake ninja vcpkg glad pkgs.pkg-config pkgs.perl];
  patches = [
    ./no_toolchain.patch
    ./add_zlib.patch
  ];
  buildInputs = [
    cudatoolkit
    glad
    openimageio
    pkgs.assimp
    pkgs.ffmpeg
    pkgs.freetype
    pkgs.glm
    pkgs.imgui
    pkgs.implot
    pkgs.libarchive
    pkgs.libargs
    pkgs.libGL
    pkgs.libwebp
    pkgs.lunasvg
    pkgs.nativefiledialog-extended
    pkgs.nlohmann_json
    pkgs.onetbb
    pkgs.openssl
    pkgs.openusd
    pkgs.plutovg
    (pkgs.python313.withPackages (ps:
      with ps; [
        nanobind
      ]))
    pkgs.sdl3
    pkgs.spdlog
    rmlui
    pkgs.uv
    pkgs.zlib
  ];
  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_CUDA_COMPILER" "${lib.getExe cudaPackages.cuda_nvcc}")
    (lib.cmakeFeature "CMAKE_PREFIX_PATH" "${glad}/lib/cmake;${pkgs.python313Packages.nanobind}/${pkgs.python313.sitePackages}/nanobind/cmake")
    (lib.cmakeBool "BUILD_NVJPEG_EXT" false)
    (lib.cmakeBool "BUILD_NVJPEG2K_EXT" false)
  ];
  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out/bin/
  '';
}
