{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glfw,
  libGL,
  sdl3,
  vcpkg,
}: let
  vcpkgSource = vcpkg.src;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "imgui";
    version = "docking";

    src = fetchFromGitHub {
      owner = "ocornut";
      repo = "imgui";
      rev = "docking";
      hash = "sha256-vyK+HfV7q/ZXnM+Cm/gt1UCgs4fFeq+1oH2/zSlC6PE=";
    };

    cmakeRules = "${vcpkgSource}/ports/imgui";

    postPatch = ''
      cp "$cmakeRules"/{CMakeLists.txt,*.cmake.in} ./
    '';

    nativeBuildInputs = [cmake];

    propagatedBuildInputs = [libGL glfw sdl3];

    cmakeFlags = [
      (lib.cmakeBool "IMGUI_BUILD_GLFW_BINDING" true)
      (lib.cmakeBool "IMGUI_BUILD_OPENGL3_BINDING" true)
      (lib.cmakeBool "IMGUI_BUILD_SDL3_BINDING" true)
      (lib.cmakeBool "IMGUI_BUILD_SDL3_RENDERER_BINDING" true)
    ];

    meta = {
      description = "Bloat-free Graphical User interface for C++ with minimal dependencies (docking branch)";
      homepage = "https://github.com/ocornut/imgui";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  })
