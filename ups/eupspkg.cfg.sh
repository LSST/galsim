export SFDPREFIX=/astro/users/danielsf/lsstsw5/lsstsw/stack/Linux64/tmv/tickets.DM-1763-g2e109ef5d1
export SCONSFLAGS=$SCONSFLAGS" USE_UNKNOWN_VARS=true TMV_DIR="$TMV_DIR" PREFIX="$PREFIX" EXTRA_LIB_PATH="$SFD"/lib EXTRA_INCLUDE_PATH="$SFDPREFIX"/include"

build(){
    echo 'SFD TMV_DIR'
    echo $TMV_DIR
    echo 'SFD DYLD_LIBRARY_PATH'
    echo $DYLD_LIBRARY_PATH
    echo 'SFDPREFIX'
    echo $SFDPREFIX

    default_build
}
