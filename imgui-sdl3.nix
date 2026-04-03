{
  lib,
  stdenv,
  fetchFromGitHub,
  sdl3,
}:

stdenv.mkDerivation rec {
  pname = "imgui-sdl3";
  version = "0";

  src = fetchFromGitHub {
    owner = "ocornut";
    repo = "imgui";
    rev = "docking";
    hash = "sha256-UwZ56S/pXIrix0syWEgoCL986deNoezS0OVesTJjNzI=";
  };

  buildInputs = [ sdl3 ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/include
    cp backends/imgui_impl_sdl3.h $out/include/
  '';
  
  meta = with lib; {
    description = "Dear ImGui SDL3 backend headers";
    homepage = "https://github.com/ocornut/imgui";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
