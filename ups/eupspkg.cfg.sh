export SCONSFLAGS=$SCONSFLAGS" USE_UNKNOWN_VARS=true TMV_DIR="$TMV_DIR" PREFIX="$PREFIX" PYPREFIX="$PREFIX"/lib/python EXTRA_LIB_PATH="$TMV_DIR"/lib EXTRA_INCLUDE_PATH="$TMV_DIR"/include"

pathToPython=$(which python)
export DYLD_FALLBACK_LIBRARY_PATH="${pathToPython%bin/python}/lib"

prep()
{
    default_prep

    # The patch file GalSimTable.patch will try to copy the existing
    # GalSim.table to galsim.table.  On Linux, this will result in
    # there being two .table files (GalSim.table and galsim.table).
    # In OSX, because OSX is case-insensitive, there will only be
    # one table file called GalSim.table.  We must now detect whether
    # or not we are in OSX.  If we are not in OSX, we must remove the
    # GalSim.table file, since it will confuse EUPS.
    if [[ $OSTYPE != darwin* ]]; then
        rm $PWD/ups/GalSim.table
    fi
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
