export SCONSFLAGS=$SCONSFLAGS" USE_UNKNOWN_VARS=true TMV_DIR="$TMV_DIR\
" PREFIX="$PREFIX" PYPREFIX="$PREFIX"/lib/python EXTRA_LIB_PATH="$TMV_DIR\
"/lib EXTRA_INCLUDE_PATH="$TMV_DIR"/include"

pathToPython=$(which python)
pathToPythonLib="${pathToPython%bin/python}/lib"

build(){

    # If running on a Mac, use install_name_tool to rewrite
    # the loading addresses for libpython*dylib and
    # libboost_python.dylib to make
    # sure that they point to themselves.  Save the original
    # loading addresses so that this can be undone later.
    if [[ $OSTYPE == darwin* ]]; then

        # Loop over all libpython*.dylib to catch all versions
        declare -a pythonLibName
        declare -a pythonLibAddress
        declare -a python_arr
        declare -i ct

        ct=0
        for entry in $pathToPythonLib/libpython*.dylib
            do
                python_arr=( $(otool -L $entry) )
                pythonLibName[ct]=$entry
                pythonLibAddress[ct]=${python_arr[1]}
                ct+=1
                install_name_tool -id $entry $entry
            done

        boostLib=$BOOST_DIR/lib/libboost_python.dylib
        declare -a boost_arr
        boost_arr=( $(otool -L $boostLib) )
        init_boost_id=${boost_arr[1]}
        install_name_tool -id $boostLib $boostLib
    fi

    default_build

    # Undo the install_name_tool mangling.
    if [[ $OSTYPE == darwin* ]]; then
        install_name_tool -id $init_boost_id $boostLib

        declare -i ii
        for ((ii=0;ii<ct;ii++)) do
            install_name_tool -id ${pythonLibAddress[$ii]} ${pythonLibName[$ii]}
        done
    fi

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
