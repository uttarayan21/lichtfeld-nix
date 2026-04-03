addGladIncludePath() {
    export NIX_CFLAGS_COMPILE+=" -I$1/include"
    export NIX_CXXFLAGS_COMPILE+=" -I$1/include"
}

addGladIncludePath @out@
