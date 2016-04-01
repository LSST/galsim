export SCONSFLAGS=$SCONSFLAGS" USE_UNKNOWN_VARS=true TMV_DIR="$TMV_DIR" PREFIX="$PREFIX" PYPREFIX="$PREFIX"/lib/python EXTRA_LIB_PATH="$TMV_DIR"/lib EXTRA_INCLUDE_PATH="$TMV_DIR"/include"

pathToPython=$(which python)
pathToPythonLib="${pathToPython%bin/python}/lib"
export DYLD_FALLBACK_LIBRARY_PATH=$pathToPythonLib

galsim_build_failure(){
    echo " "
    echo "WARNING: this probably will not work"
    echo "It appears that your libpython2.7.dylib does not have"
    echo "a correct loader path."
    echo "Unfortunately, the libpyton2.7.dylib you are"
    echo "building against (i.e."
    echo $1
    echo ") appears to be in /usr/, so the eups distrib"
    echo "automatic build system is not going to try to fix"
    echo "it.  We will proceed with the build.  If it fails"
    echo "on GalSim, try consulting"
    echo "http://stackoverflow.com/questions/23771608/trouble-installing-galsim-on-osx-with-anaconda"
    echo "for a likely fix."
}

build()
{

    # test to see if we are running on OSX
    if [[ $OSTYPE == darwin* ]]; then
        version=${OSTYPE#darwin}

        # now, test to see if we are in El Capitan (or later)
        if [[ $version -ge 15 ]]; then

            # now investigate whether the libpython2.7.dylib has an appropriate
            # loader address
            pythonLib=$pathToPythonLib/libpython2.7.dylib
            selfAddress=$(otool -D $pythonLib)
            selfAddressStripped=$(echo "${selfAddress#$pythonLib:}" | tr -d [:space:])

            if [[ $selfAddressStripped == "libpython2.7.dylib" ]]; then

                if [[ $pythonLib == *"/usr/"* ]]; then

                    # we are using a library in /usr/
                    # we will not try to fix it

                    galsim_build_failure $pythonLib

                else
                    install_name_tool -id @rpath/libpython2.7.dylib $pythonLib
                fi
            fi
        fi
    fi

    scons DYLD_LIBRARY_PATH=$LSST_LIBRARY_PATH DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH -j$NJOBS prefix="$PREFIX" version="$VERSION" cc="$CC"

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
