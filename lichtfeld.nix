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
  imgui-sdl3,
  imgui,
  implot,
}:
pkgs.stdenv.mkDerivation {
  pname = "lichtfeld-studio";
  version = "0.1.0";
  src = src;
  hooks = [cmake];
  nativeBuildInputs = [cmake ninja vcpkg glad pkgs.pkg-config pkgs.python313];
  patches = [
    ./no_toolchain.patch
    ./add_zlib.patch
    ./fix_nvjpeg_dynamic.patch
    ./fix_glad2_api.patch
  ];
  buildInputs = [
    cudatoolkit
    cudaPackages.libnpp
    cudaPackages.libnvjpeg
    imgui
    imgui-sdl3
    implot
    openimageio
    pkgs.assimp
    pkgs.ffmpeg
    pkgs.freetype
    pkgs.glm
    pkgs.libGLU
    pkgs.libarchive
    pkgs.libargs
    pkgs.libGL
    pkgs.libwebp
    pkgs.libX11
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
  propagatedBuildInputs = [ glad ];
  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_CUDA_COMPILER" "${lib.getExe cudaPackages.cuda_nvcc}")
    (lib.cmakeFeature "CMAKE_PREFIX_PATH" "${glad}/lib/cmake;${pkgs.python313Packages.nanobind}/${pkgs.python313.sitePackages}/nanobind/cmake")
  ];
  
  preConfigure = ''
    cmakeFlagsArray+=(
      "-DCMAKE_CXX_FLAGS=-I${glad}/include -I${pkgs.python313}/include/python3.13 -I${imgui-sdl3}/include"
      "-DCMAKE_C_FLAGS=-I${glad}/include -I${imgui-sdl3}/include"
    )
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp -r * $out/bin/
  '';
}
