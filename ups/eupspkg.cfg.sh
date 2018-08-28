TAP_TAR_OPTIONS="--exclude ups"
SCONSFLAGS+=" PREFIX=$PREFIX PYPREFIX=$PREFIX/lib/python"
SCONSFLAGS+=" TMV_DIR=$TMV_DIR EXTRA_LIB_PATH=$TMV_DIR/lib EXTRA_INCLUDE_PATH=$TMV_DIR/include"
SCONSFLAGS+=" USE_UNKNOWN_VARS=true"
export SCONSFLAGS

if [[ $OSTYPE == darwin* ]]; then
	# Add DYLD_LIBRARY_PATH to SCONSFLAGS (deriving it from LSST_LIBRARY_PATH).
	# This is required for OS X >=10.11 compatibility as SIP tends to wipe out
	# DYLD_LIBRARY_PATH
	export SCONSFLAGS+=" DYLD_LIBRARY_PATH='$LSST_LIBRARY_PATH'"

	# Detect broken libpython*.dylib install name on OS X. We do this
	# by checking whether the install name in libpython*.dylib begins
	# with / (absolute) or @ (in which case it's most likely a @rpath).
	# Note that $LIBPYTHON_DYLIB may not exist (e.g., if Python lib has
	# been built as a framework -- like /usr/bin/python)
	LIBPYTHON_DYLIB=$(python -c "import sysconfig, os.path; print(os.path.join(*sysconfig.get_config_vars('LIBDIR', 'LDLIBRARY')))")
	if [[ -f "$LIBPYTHON_DYLIB" ]]; then
		LIBPYTHON_DYLIB_INSTNAME=$(otool -X -D "$LIBPYTHON_DYLIB")
		if [[ ! $LIBPYTHON_DYLIB_INSTNAME =~ [/@].* ]]; then
			BROKEN_LIBPYTHON_DYLIB=1
		fi
	fi

	if [[ $BROKEN_LIBPYTHON_DYLIB = 1 ]]; then
		# Add the Python library directory to GalSim's DYLD_FALLBACK_LIBRARY_PATH, to enable
		# the build to pass successfully. We'll patch the resultant _galsim.so in the build() phase,
		# enabling it to find the correct libpython*.dylib w/o the need to set DYLD_FALLBACK_LIBRARY_PATH
		# at runtime
		DYLD_FALLBACK_LIBRARY_PATH=$(python -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))")
		export SCONSFLAGS+=" DYLD_FALLBACK_LIBRARY_PATH='$DYLD_FALLBACK_LIBRARY_PATH'"
	fi
fi

build()
{

        export SCONSFLAGS+=" EIGEN_DIR=$EIGEN_DIR/include"
        export SCONSFLAGS+=" PYBIND11_DIR=$PYBIND11_DIR"

	if [[ ! -z $LIBPYTHON_DYLIB ]]; then
		echo "LIBPYTHON_DYLIB=$LIBPYTHON_DYLIB"
		echo "LIBPYTHON_DYLIB_INSTNAME=$LIBPYTHON_DYLIB_INSTNAME"
		echo "BROKEN_LIBPYTHON_DYLIB=$BROKEN_LIBPYTHON_DYLIB"
	fi

	default_build

	if [[ $BROKEN_LIBPYTHON_DYLIB ]]; then
		#
		# Fix the path to libpython*.dylib, as stored in _galsim.so, so that it can
		# find the correct Python library even if it's not on DYLD_LIBRARY_PATH at
		# runtime. We also need to define the @rpath; we hach this a little, by
		# assuming the library directory is in ../lib relative to where the Python
		# executable lives.
		#
		GALSIM_SO="galsim/_galsim.so"

		install_name_tool -change "$LIBPYTHON_DYLIB_INSTNAME" "@rpath/$LIBPYTHON_DYLIB_INSTNAME" "$GALSIM_SO"
		install_name_tool -add_rpath                          "@executable_path/../lib"          "$GALSIM_SO"
		
		echo "Patching linker information in $GALSIM_SO:"
		otool -L "$GALSIM_SO"
		echo "done."
	fi
}

install()
{
        default_install

	cp -r include "$PREFIX/"
        cd galsim
        # Grab version from python source.  Libs are only labeled with first two most major version numbers
        version=$( python -c "from _version import __version__ as version; print('.'.join(version.split('.')[:2]))" )
        cd -
	if [[ $OSTYPE == darwin* ]]; then
		curdir=$(pwd)
		cd $PREFIX/lib
		galsim_name=libgalsim.${version}.dylib
		rm libgalsim.dylib
		ln -s $galsim_name libgalsim.dylib
		install_name_tool -id $galsim_name $galsim_name
		install_name_tool -change $PREFIX/lib/$galsim_name @loader_path/../../$galsim_name python/galsim/_galsim.so
		cd $curdir
	fi
}
