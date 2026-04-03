{
  lib,
  stdenv,
  fetchFromGitHub,
  sdl3,
  imgui,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "imgui-sdl3";
  version = "docking";

  src = fetchFromGitHub {
    owner = "ocornut";
    repo = "imgui";
    rev = "docking";
    hash = "sha256-UwZ56S/pXIrix0syWEgoCL986deNoezS0OVesTJjNzI=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ sdl3 ];
  propagatedBuildInputs = [ imgui ];

  dontConfigure = true;
  
  buildPhase = ''
    $CXX -c backends/imgui_impl_sdl3.cpp \
      -I. \
      -I${imgui}/include \
      -I${sdl3}/include \
      -fPIC \
      -O3 \
      -o imgui_impl_sdl3.o
  '';

  installPhase = ''
    mkdir -p $out/lib $out/include
    ar rcs $out/lib/libimgui_impl_sdl3.a imgui_impl_sdl3.o
    cp backends/imgui_impl_sdl3.h $out/include/
  '';
  
  meta = with lib; {
    description = "Dear ImGui SDL3 backend";
    homepage = "https://github.com/ocornut/imgui";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
