{
  assimp,
  boost,
  cmake,
  cppzmq,
  cudaPackages,
  cudatoolkit,
  ffmpeg,
  freetype,
  glm,
  glslang,
  gtk3,
  imgui,
  imgui-sdl3,
  implot,
  lib,
  libarchive,
  libargs,
  libdeflate,
  libGL,
  libGLU,
  libwebp,
  libX11,
  lunasvg,
  nfd-src,
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
  shader-slang,
  spdlog,
  src,
  uv,
  vulkan-volk,
  vulkan-headers,
  vulkan-loader,
  vulkan-memory-allocator,
  wrapGAppsHook3,
  zeromq,
  zlib,
}:
pkgs.stdenv.mkDerivation {
  pname = "lichtfeld-studio";
  version = "0.5.3";
  src = src;
  hooks = [cmake];
  nativeBuildInputs = [cmake ninja pkg-config python313 glslang shader-slang cudaPackages.removeStubsFromRunpathHook wrapGAppsHook3];
  patches = [
    ./no_toolchain.patch
    ./add_zlib.patch
    ./fix_nvjpeg_dynamic.patch
  ];

  # Upstream force-points glslang_DIR at the vcpkg install tree, which makes
  # find_package(glslang CONFIG) miss the nixpkgs config.
  postPatch = ''
    grep -q 'set(glslang_DIR' src/visualizer/CMakeLists.txt
    sed -i '/set(glslang_DIR/,+1d' src/visualizer/CMakeLists.txt
  '';

  buildInputs = [
    assimp
    boost
    cppzmq
    cudaPackages.libnpp
    cudaPackages.libnvjpeg
    cudaPackages.libnvjpeg_2k
    cudatoolkit
    ffmpeg
    freetype
    glm
    glslang
    gtk3
    imgui
    imgui-sdl3
    implot
    libarchive
    libargs
    libdeflate
    libGL
    libGLU
    libwebp
    libX11
    lunasvg
    nlohmann_json
    onetbb
    openimageio
    openssl
    openusd
    plutovg
    sdl3
    spdlog
    uv
    vulkan-headers
    vulkan-loader
    vulkan-memory-allocator
    vulkan-volk
    zeromq
    zlib
    rmlui
    (python313.withPackages (ps:
      with ps; [
        nanobind
      ]))
  ];
  propagatedBuildInputs = [rmlui];
  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_CUDA_COMPILER" "${lib.getExe cudaPackages.cuda_nvcc}")
    (lib.cmakeFeature "CMAKE_PREFIX_PATH" "${pkgs.python313Packages.nanobind}/${pkgs.python313.sitePackages}/nanobind/cmake;${rmlui}/lib/cmake;${rmlui}/share/RmlUi/cmake;${pkgs.openusd}/cmake")
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_NVJPEG2K_HEADERS" "${nvjpeg2k-archive}")
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_NATIVEFILEDIALOG_EXTENDED" "${nfd-src}")
    (lib.cmakeBool "BUILD_PYTHON_STUBS" false)
    (lib.cmakeBool "CMAKE_SKIP_BUILD_RPATH" true)
    (lib.cmakeBool "CMAKE_BUILD_WITH_INSTALL_RPATH" false)
    (lib.cmakeBool "CMAKE_INSTALL_RPATH_USE_LINK_PATH" true)
    (lib.cmakeBool "CMAKE_POSITION_INDEPENDENT_CODE" true)
  ];

  preConfigure = ''
    cmakeFlagsArray+=(
      "-DCMAKE_CXX_FLAGS=-I${pkgs.python313}/include/python3.13 -I${imgui-sdl3}/include"
      "-DCMAKE_C_FLAGS=-I${imgui-sdl3}/include"
    )
  '';

  # freetype is pulled in via imgui's freetype backend but never lands on the
  # link line, so gui_manager.cpp's FT_* references go unresolved.
  NIX_LDFLAGS = "-L${openusd}/lib -lusd_ms -L${imgui-sdl3}/lib -limgui_impl_sdl3 -L${freetype}/lib -lfreetype";

  installPhase = ''
    runHook preInstall
    cmake --install . --prefix $out

    # Copy libraries not installed by cmake
    cp liblfs_rmlui.so $out/lib/ 2>/dev/null || true

    # OpenMesh is added EXCLUDE_FROM_ALL, so it ships no install rules even
    # though the executable links against it.
    cp -P Build/lib/libOpenMesh*.so* $out/lib/

    runHook postInstall
  '';

  # CMake bakes the OpenMesh build-tree path into the RPATH; swap it for $out/lib
  # before the fixup phase shrinks RPATHs and audits for /build references.
  preFixup = ''
    for f in $out/bin/LichtFeld-Studio $out/lib/*.so*; do
      [ -f "$f" ] || continue
      rpath=$(patchelf --print-rpath "$f" 2>/dev/null) || continue
      case "$rpath" in
        *"$NIX_BUILD_TOP"*) ;;
        *) continue ;;
      esac
      cleaned=$(printf '%s' "$rpath" | tr ':' '\n' | grep -v "^$NIX_BUILD_TOP" | paste -sd:)
      patchelf --set-rpath "$cleaned''${cleaned:+:}$out/lib" "$f"
    done
  '';

  postFixup = ''
    wrapProgram $out/bin/LichtFeld-Studio \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [cudaPackages.libnpp cudaPackages.libnvjpeg cudaPackages.libnvjpeg_2k vulkan-loader]}"
  '';
}
