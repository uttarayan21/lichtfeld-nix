{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  freetype,
  llvmPackages,
}:

stdenv.mkDerivation rec {
  pname = "rmlui";
  version = "6.2";

  src = fetchFromGitHub {
    owner = "mikke89";
    repo = "RmlUi";
    tag = version;
    hash = "sha256-K/znksrli3/FQ+lHgZgMgefFrWAGbxKNvFIIqtybOMc=";
  };

  nativeBuildInputs = [cmake];

  buildInputs = [
    freetype
  ] ++ lib.optionals stdenv.cc.isClang [
    llvmPackages.libcxx
  ];

  cmakeFlags = [
    "-DBUILD_SAMPLES=OFF"
    "-DBUILD_TESTS=OFF"
  ];

  meta = with lib; {
    description = "HTML/CSS user interface library";
    homepage = "https://github.com/mikke89/RmlUi";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
