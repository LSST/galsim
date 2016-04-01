export SCONSFLAGS=$SCONSFLAGS" USE_UNKNOWN_VARS=true TMV_DIR="$TMV_DIR" PREFIX="$PREFIX" PYPREFIX="$PREFIX"/lib/python EXTRA_LIB_PATH="$TMV_DIR"/lib EXTRA_INCLUDE_PATH="$TMV_DIR"/include"

pathToPython=$(which python)
pathToPythonLib="${pathToPython%bin/python}/lib"
export DYLD_FALLBACK_LIBRARY_PATH=$pathToPythonLib

galsim_build_failure(){
    # Print an explanatory message of the install fails while
    # trying to apply the install_name_tool fix to libpython2.7.dylib
    #
    # $1 should be the full name of the libpython2.7.dylib we are
    # trying to build against
    #
    # $2 should be a string indicating the nature of the failure:
    # 'usr' if the build failed because libpython2.7.dylib appears
    #       to be in /usr/
    #  'install_name_tool' if the build failed when trying to run
    #       install_name_tool in libpython2.7.dylib

    echo " "
    echo "NOTE FROM LSST: this probably will not work"
    echo "It appears that your libpython2.7.dylib does not have"
    echo "a correct loader path."
    echo " "

    if [[ $2 == "usr" ]]; then
        echo "Unfortunately, the libpyton2.7.dylib you are"
        echo "building against appears to be in /usr/, so the"
        echo "eups distrib automatic build system is not going"
        echo "to try to fix it."

    elif [[ $2 == "install_name_tool" ]]; then
        echo "Unfortunately, attempting to run install_name_tool"
        echo "on the libpython2.7.dylib against which you are building"
        echo "failed.  You may not have adequate permissions"

    else
        echo "It is unclear what the problem is,"
        echo "but the eups distrib automatic build system cannot"
        echo "fix the loader path."
    fi

    echo " "
    echo "FYI: you are trying to build against"
    echo $1
    echo " "

    echo "We will proceed with the build.  If it fails"
    echo "on GalSim, try consulting"
    echo "http://stackoverflow.com/questions/23771608/trouble-installing-galsim-on-osx-with-anaconda"
    echo "for a likely fix."
    echo " "
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

                    galsim_build_failure $pythonLib "usr"

                else
                    install_name_tool -id @rpath/libpython2.7.dylib $pythonLib \
                    || galsim_build_failure $pythonLib "install_name_tool"
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
