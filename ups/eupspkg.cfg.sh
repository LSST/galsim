export SCONSFLAGS=$SCONSFLAGS" USE_UNKNOWN_VARS=true TMV_DIR="$TMV_DIR" PREFIX="$PREFIX" PYPREFIX="$PREFIX"/lib/python EXTRA_LIB_PATH="$TMV_DIR"/lib EXTRA_INCLUDE_PATH="$TMV_DIR"/include"

pathToPython=$(which python)
export DYLD_FALLBACK_LIBRARY_PATH="${pathToPython%bin/python}/lib"

# Work around the incorrect install name of Anaconda's libpython2.7.dylib (part 1/2)
export DYLD_FALLBACK_LIBRARY_PATH="$CONDA_DEFAULT_ENV/lib"

install()
{
    default_install
    cp -r include $PREFIX/

    if [[ $OSTYPE == darwin* ]]; then
        # Work around the incorrect install name of Anaconda's libpython2.7.dylib (part 2/2)
        echo "Fixing @rpath in _galsim.so"
        install_name_tool -change libpython2.7.dylib @rpath/libpython2.7.dylib "$PREFIX"/lib/python/galsim/_galsim.so
    fi

    if [[ $OSTYPE == darwin* ]]; then
        install_name_tool -add_rpath $DYLD_FALLBACK_LIBRARY_PATH "$PREFIX"/lib/python/galsim/_galsim.so
        install_name_tool -change libpython2.7.dylib @rpath/libpython2.7.dylib "$PREFIX"/lib/python/galsim/_galsim.so
    fi
}
