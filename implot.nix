{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  imgui,
  vcpkg,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "implot";
  version = "0.16";

  src = fetchFromGitHub {
    owner = "epezent";
    repo = "implot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/wkVsgz3wiUVZBCgRl2iDD6GWb+AoHN+u0aeqHHgem0=";
  };

  cmakeRules = "${vcpkg.src}/ports/implot";
  postPatch = ''
    cp "$cmakeRules"/CMakeLists.txt ./
  '';

  nativeBuildInputs = [cmake];

  buildInputs = [imgui];

  meta = {
    description = "Advanced 2D Plotting for Dear ImGui";
    homepage = "https://github.com/epezent/implot";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
