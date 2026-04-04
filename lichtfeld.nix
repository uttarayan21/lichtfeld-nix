{
  assimp,
  cmake,
  cudaPackages,
  cudatoolkit,
  ffmpeg,
  freetype,
  glad,
  glm,
  imgui,
  imgui-sdl3,
  implot,
  lib,
  libarchive,
  libargs,
  libGL,
  libGLU,
  libwebp,
  libX11,
  lunasvg,
  nativefiledialog-extended,
  ninja,
  nlohmann_json,
  nvjpeg2k-archive,
  onetbb,
  openimageio,
  openssl,
  openusd,
  pkg-config,
  pkgs,
  plutovg,
  python313,
  rmlui,
  sdl3,
  spdlog,
  src,
  uv,
  wrapGAppsHook3,
  zlib,
}:
pkgs.stdenv.mkDerivation {
  pname = "lichtfeld-studio";
  version = "0.1.0";
  src = src;
  hooks = [cmake];
  nativeBuildInputs = [cmake ninja glad pkg-config python313 cudaPackages.removeStubsFromRunpathHook wrapGAppsHook3];
  patches = [
    ./no_toolchain.patch
    ./add_zlib.patch
    ./fix_nvjpeg_dynamic.patch
    ./fix_glad2_api.patch
  ];
  buildInputs = [
    assimp
    cudaPackages.libnpp
    cudaPackages.libnvjpeg
    cudaPackages.libnvjpeg_2k
    cudatoolkit
    ffmpeg
    freetype
    glm
    imgui
    imgui-sdl3
    implot
    libarchive
    libargs
    libGL
    libGLU
    libwebp
    libX11
    lunasvg
    nativefiledialog-extended
    nlohmann_json
    onetbb
    openimageio
    openssl
    openusd
    plutovg
    sdl3
    spdlog
    uv
    zlib
    rmlui
    (python313.withPackages (ps:
      with ps; [
        nanobind
      ]))
  ];
  propagatedBuildInputs = [glad rmlui];
  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_CUDA_COMPILER" "${lib.getExe cudaPackages.cuda_nvcc}")
    (lib.cmakeFeature "CMAKE_PREFIX_PATH" "${glad}/lib/cmake;${pkgs.python313Packages.nanobind}/${pkgs.python313.sitePackages}/nanobind/cmake;${rmlui}/lib/cmake;${rmlui}/share/RmlUi/cmake;${pkgs.openusd}/cmake")
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_NVJPEG2K_HEADERS" "${nvjpeg2k-archive}")
    (lib.cmakeBool "BUILD_PYTHON_STUBS" false)
    (lib.cmakeBool "CMAKE_SKIP_BUILD_RPATH" true)
    (lib.cmakeBool "CMAKE_BUILD_WITH_INSTALL_RPATH" false)
    (lib.cmakeBool "CMAKE_INSTALL_RPATH_USE_LINK_PATH" true)
    (lib.cmakeBool "CMAKE_POSITION_INDEPENDENT_CODE" true)
  ];

  preConfigure = ''
    cmakeFlagsArray+=(
      "-DCMAKE_CXX_FLAGS=-I${glad}/include -I${pkgs.python313}/include/python3.13 -I${imgui-sdl3}/include"
      "-DCMAKE_C_FLAGS=-I${glad}/include -I${imgui-sdl3}/include"
    )
  '';

  NIX_LDFLAGS = "-L${openusd}/lib -lusd_ms -L${imgui-sdl3}/lib -limgui_impl_sdl3";

  installPhase = ''
    runHook preInstall
    cmake --install . --prefix $out

    # Copy libraries not installed by cmake
    cp liblfs_rmlui.so $out/lib/ 2>/dev/null || true

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/LichtFeld-Studio \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [cudaPackages.libnpp cudaPackages.libnvjpeg cudaPackages.libnvjpeg_2k]}"
  '';
}
