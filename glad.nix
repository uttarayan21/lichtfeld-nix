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

  buildPhase = ''
    python3 -m glad --api gl:core=4.6 --out-path out --reproducible c
  '';

  installPhase = ''
    mkdir -p $out/lib/cmake/glad
    mkdir -p $out/include
    mkdir -p $out/src
    
    cp -r out/include/glad $out/include/
    cp -r out/include/KHR $out/include/
    cp out/src/gl.c $out/src/
    
    cat > $out/lib/cmake/glad/gladConfig.cmake << 'EOF'
add_library(glad::glad STATIC IMPORTED)
set_target_properties(glad::glad PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "@out@/include"
  IMPORTED_LOCATION "@out@/lib/libglad.a"
)
EOF
    
    substituteInPlace $out/lib/cmake/glad/gladConfig.cmake --subst-var out
    
    cc -c $out/src/gl.c -o gl.o -I$out/include -fPIC
    ar rcs $out/lib/libglad.a gl.o
  '';

  meta = with lib; {
    description = "Multi-Language Vulkan/GL/GLES/EGL/GLX/WGL Loader-Generator";
    homepage = "https://github.com/Dav1dde/glad";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
