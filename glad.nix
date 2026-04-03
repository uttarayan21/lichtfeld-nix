{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}: stdenv.mkDerivation rec {
  pname = "glad";
  version = "2.0.8";

  src = fetchFromGitHub {
    owner = "Dav1dde";
    repo = "glad";
    tag = "v${version}";
    hash = "sha256-aWqqOtNbaWMIKN1KAnXfTbDOgcZ87XaXwVGVgePzLDE=";
  };

  buildInputs = [python3 python3.pkgs.jinja2 python3.pkgs.ply];

  installPhase = ''
    mkdir -p $out/lib/cmake/glad
    mkdir -p $out/share/glad
    
    cp -r glad $out/share/glad/
    
    cp cmake/GladConfig.cmake $out/lib/cmake/glad/gladConfig.cmake
    cp cmake/CMakeLists.txt $out/lib/cmake/glad/
    
    sed -i 's|''${CMAKE_CURRENT_LIST_DIR}/\.\./|'"$out"'/share/glad/|g' $out/lib/cmake/glad/gladConfig.cmake
    sed -i 's|''${CMAKE_CURRENT_LIST_DIR}|'"$out"'/lib/cmake/glad|g' $out/lib/cmake/glad/CMakeLists.txt
  '';

  meta = with lib; {
    description = "Multi-Language Vulkan/GL/GLES/EGL/GLX/WGL Loader-Generator";
    homepage = "https://github.com/Dav1dde/glad";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
