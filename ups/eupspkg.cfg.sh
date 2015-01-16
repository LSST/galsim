export SCONSFLAGS=$SCONSFLAGS" USE_UNKNOWN_VARS=true TMV_DIR="$TMV_DIR" PREFIX="$PREFIX

build(){
    echo 'SFD TMV_DIR'
    echo $TMV_DIR
    echo 'SFD DYLD_LIBRARY_PATH'
    echo $DYLD_LIBRARY_PATH

    default_build
}
