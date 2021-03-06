#!/bin/sh
pushd src >/dev/null

if [ ! -d "Python-${VERSION}" ]; then

# Control will enter here if $DIRECTORY doesn't exist.
tar -xf "Python-${VERSION}.tar.xz" || exit 1

pushd "Python-${VERSION}" >/dev/null

# Build host components.
AR=ar AS=as CC=gcc CFLAGS= CPP=cpp CPPFLAGS= CXX=g++ CXXFLAGS= LD=ld LDFLAGS= RANLIB=ranlib ./configure --disable-ossaudiodev || exit 1
AR=ar AS=as CC=gcc CFLAGS= CPP=cpp CPPFLAGS= CXX=g++ CXXFLAGS= LD=ld LDFLAGS= RANLIB=ranlib make BUILDPYTHON=hostpython hostpython PGEN=Parser/hostpgen Parser/hostpgen || exit 1
make distclean || exit 1

# Apply patches and build target Python.
cat > config.site <<-SITE
	ac_cv_file__dev_ptmx=no
	ac_cv_file__dev_ptc=no
SITE
ln -sf "${TOOL_PREFIX}/sysroot/usr/include/"{linux,sys}"/soundcard.h"


patch -p1  < "${FILESDIR}/${PACKAGE}-cross-compile.patch" || exit 1
patch -p1  < "${FILESDIR}/${PACKAGE}-python-misc.patch" || exit 1
patch -p1  < "${FILESDIR}/${PACKAGE}-android-locale.patch" || exit 1
patch -Ep1 < "${FILESDIR}/${PACKAGE}-android-libmpdec.patch" || exit 1
patch -p1  < "${FILESDIR}/${PACKAGE}-android-misc.patch" || exit 1
patch -p1  < "${FILESDIR}/${PACKAGE}-android-print.patch" || exit 1 
patch -p1  < "${FILESDIR}/${PACKAGE}-android-print-fatalerror.patch" || exit 1 
patch -p1  < "${FILESDIR}/${PACKAGE}-accept4.patch" || exit 1
patch -p1  < "${FILESDIR}/115-optional-ossaudiodev.patch" || exit 1


else

pushd "Python-${VERSION}" >/dev/null

fi

./configure CROSS_COMPILE_TARGET=yes HOSTPYTHON="$(pwd)/hostpython" CONFIG_SITE=config.site --prefix="${PREFIX}" --host="${TARGET}" --build="${HOST}" --disable-ipv6 --enable-shared --disable-ossaudiodev --without-ensurepip || exit 1


make CROSS_COMPILE_TARGET=yes HOSTPYTHON="$(pwd)/hostpython" HOSTPGEN="$(pwd)/Parser/hostpgen" || exit 1
make CROSS_COMPILE_TARGET=yes HOSTPYTHON="$(pwd)/hostpython" HOSTPGEN="$(pwd)/Parser/hostpgen" install || exit 1

popd >/dev/null
popd >/dev/null
