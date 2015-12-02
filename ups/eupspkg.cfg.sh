pathToPython=$(which python)
pathToPythonLib="${pathToPython%bin/python}/lib"

export SCONSFLAGS=$SCONSFLAGS" USE_UNKNOWN_VARS=true TMV_DIR="$TMV_DIR\
" PREFIX="$PREFIX" PYPREFIX="$PREFIX"/lib/python EXTRA_LIB_PATH="$TMV_DIR\
"/lib EXTRA_INCLUDE_PATH="$TMV_DIR"/include"\
" FALLBACK="$pathToPythonLib

build(){

    install_name_tool -id @rpath/libpython2.7.dylib $pathToPythonLib/libpython2.7.dylib
    install_name_tool -add_rpath $pathToPythonLib $BOOST_DIR/lib/libboost_python.dylib

}

install()
{
    default_install
    cp -r include $PREFIX/

    if [[ $OSTYPE == darwin* ]]; then
        install_name_tool -add_rpath $pathToPythonLib "$PREFIX"/lib/python/galsim/_galsim.so
        install_name_tool -change libpython2.7.dylib @rpath/libpython2.7.dylib "$PREFIX"/lib/python/galsim/_galsim.so
    fi
}
