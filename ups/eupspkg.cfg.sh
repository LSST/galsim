#!/bin/bash

export SCONSFLAGS="${SCONSFLAGS} USE_UNKNOWN_VARS=true TMV_DIR=${TMV_DIR} PREFIX=${PREFIX} PYPREFIX=${PREFIX}/lib/python EXTRA_LIB_PATH=${TMV_DIR}/lib EXTRA_INCLUDE_PATH=${TMV_DIR}/include"

install()
{
    default_install
    cp -r include "$PREFIX"/

    if [[ $OSTYPE == darwin* ]]; then
        local pathToPython
        pathToPython=$(which python)
        install_name_tool -add_rpath "${pathToPython%bin/python}/lib" "$PREFIX"/lib/python/galsim/_galsim.so
        install_name_tool -change libpython2.7.dylib @rpath/libpython2.7.dylib "$PREFIX"/lib/python/galsim/_galsim.so
    fi
}
