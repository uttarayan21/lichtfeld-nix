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
  nvjpeg2k-archive,
}:
pkgs.stdenv.mkDerivation {
  pname = "lichtfeld-studio";
  version = "0.1.0";
  src = src;
  hooks = [cmake];
  nativeBuildInputs = [cmake ninja vcpkg glad pkgs.pkg-config pkgs.python313 pkgs.makeWrapper cudaPackages.removeStubsFromRunpathHook];
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
    cudaPackages.libnvjpeg_2k
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
    pkgs.glib
    pkgs.gsettings-desktop-schemas
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

  NIX_LDFLAGS = "-L${pkgs.openusd}/lib -lusd_ms -L${imgui-sdl3}/lib -limgui_impl_sdl3";
  
  installPhase = ''
    runHook preInstall
    cmake --install . --prefix $out
    
    # Copy libraries not installed by cmake
    cp liblfs_rmlui.so $out/lib/ 2>/dev/null || true
    
    runHook postInstall
  '';
  
  postFixup = ''
    wrapProgram $out/bin/LichtFeld-Studio \
      --set GSETTINGS_SCHEMA_DIR ${pkgs.gsettings-desktop-schemas}/share/glib-2.0/schemas \
      --prefix LD_LIBRARY_PATH : $out/lib:$out/lib/extensions
  '';
}
