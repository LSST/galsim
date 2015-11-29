
pathToPython=$(which python)
pythonLibPath="${pathToPython%bin/python}/lib"
export LSST_LIBRARY_PATH=$pythonLibPath:$LSST_LIBRARY_PATH

export SCONSFLAGS=$SCONSFLAGS" USE_UNKNOWN_VARS=true TMV_DIR="$TMV_DIR" PREFIX="$PREFIX" PYPREFIX="$PREFIX"/lib/python  EXTRA_INCLUDE_PATH="$TMV_DIR"/include:"$BOOST_DIR"/include BOOST_DIR="$BOOST_DIR" FFTW_DIR="$FFTW_DIR" EXTRA_LIB_PATH="$LSST_LIBRARY_PATH" PYTHON="$pathToPython

build(){

    if [[ $OSTYPE == darwin* ]]; then
        declare -a arr
        arr=( $(otool -L $BOOST_DIR/lib/libboost_python.dylib) )
        echo 'sfd id'
        init_id=${arr[1]}
        echo $init_id
        install_name_tool -id $BOOST_DIR/lib/libboost_python.dylib $BOOST_DIR/lib/libboost_python.dylib
    fi

    default_build

    if [[ $OSTYPE == darwin* ]]; then
        install_name_tool -id $init_id $BOOST_DIR/lib/libboost_python.dylib
    fi

}

install()
{
    default_install
    cp -r include $PREFIX/

    if [[ $OSTYPE == darwin* ]]; then
        install_name_tool -add_rpath $pythonLibPath "$PREFIX"/lib/python/galsim/_galsim.so
        install_name_tool -change libpython2.7.dylib @rpath/libpython2.7.dylib "$PREFIX"/lib/python/galsim/_galsim.so
    fi
}
