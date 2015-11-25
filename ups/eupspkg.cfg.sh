
pathToPython=$(which python)
export DYLD_FALLBACK_LIBRARY_PATH="${pathToPython%bin/python}/lib"

export DYLD_FALLBACK_LIBRARY_PATH=/Users/noldor/physics/buildGalSimElCapitan/lsstsw/stack/DarwinX86/boost/1.59.lsst5/lib/:$DYLD_FALLBACK_LIBRARY_PATH

export SCONSFLAGS=$SCONSFLAGS" USE_UNKNOWN_VARS=true TMV_DIR="$TMV_DIR" PREFIX="$PREFIX" PYPREFIX="$PREFIX"/lib/python EXTRA_LIB_PATH="$TMV_DIR"/lib EXTRA_INCLUDE_PATH="$TMV_DIR"/include FLAGS='-Wl,-rpath="$DYLD_FALLBACK_LIBRARY_PATH"'"

build(){
    echo 'sfd dyld'
    echo $DYLD_FALLBACK_LIBRARY_PATH
    echo 'done with sfd dyld'
    #sfd
    default_build
}

install()
{
    default_install
    cp -r include $PREFIX/

    if [[ $OSTYPE == darwin* ]]; then
        install_name_tool -add_rpath $DYLD_FALLBACK_LIBRARY_PATH "$PREFIX"/lib/python/galsim/_galsim.so
        install_name_tool -change libpython2.7.dylib @rpath/libpython2.7.dylib "$PREFIX"/lib/python/galsim/_galsim.so
    fi
}
