export SCONSFLAGS=$SCONSFLAGS" USE_UNKNOWN_VARS=true TMV_DIR=/astro/users/danielsf/lsstsw5/lsstsw/stack/Linux64/tmv/tickets.DM-1763-g2e109f5d1/ PREFIX="$PREFIX

build(){
    echo 'SFD TMV_DIR'
    echo $TMV_DIR
    echo 'SFD DYLD_LIBRARY_PATH'
    echo $DYLD_LIBRARY_PATH

    default_build
}
