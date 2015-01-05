#!/bin/bash

# TODO: Add fbx LD_FLAGS option for MinGW compillation
if [ $# -ne 2 ] ; then
  echo "Usage $0 [Release | Debug ARCH=32|64]" && exit 1
  echo "Example $0 Release 32"
fi

GP_DIR=/data/src/libs/gameplay/repo
FBX_SDK_DIR=/data/sdks/fbx/2014.2.1
T1=`date +%s`
ARCH=$2
BUILD=$1
MACH=`gcc -dumpmachine`
PREFIX=/usr/local$ARCH
BUILD_DIR=build$ARCH.${BUILD}.${MACH}
#PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:/usr/local/lib/pkgconfig"

if [ "$ARCH" == "32" ]
then
  export CPU_ARCH="i386"
  export RCFLAGS="pe-i386" # -F option to windres
  export WINDRES="windres -F pe-i386"
  export GARCH="x86"
  export LDFLAGS="-L$FBX_SDK_DIR/lib/gcc4/x86/release -L/usr/lib"
elif [ "$ARCH" == "64" ]
then
  export CPU_ARCH="x86_64"
  export RCFLAGS="pe-x86-64" # -F option to windres
  export WINDRES="windres -F pe-x86-64"
  export GARCH="x64"
  export LDFLAGS="-L$FBX_SDK_DIR/lib/gcc4/x64/release -L/usr/lib"
fi

OST=`echo $OSTYPE | awk -F"-" '{ print $1 }'`
GP_DEST=$GP_DIR/$OST/${GARCH}/$BUILD && mkdir -p $GP_DEST
GP_ENC_DEST=$GP_DIR/bin/$OST/${GARCH}/$BUILD && mkdir -p $GP_ENC_DEST
echo $GP_ENC_DEST

# Check if we run from MSYS and mount proper directories: /usr/local, /mingw
if [ "$MSYSTEM" == "MINGW32" -o "$MSYSTEM" == "MINGW64" ] ; then
#   umount /mingw
#   umount /usr/local
#   base=`env | grep msys | grep -v bin | awk -F= '{ print $2 }'`
#   mingw=`dirname $base`
#   mount $mingw /mingw
#   mount ${base}\\local /usr/local
   CMAKE_GEN="MSYS Makefiles"
   CPP_WINFLAGS="-DWIN32 -D_WIN32_WINNT=0x0501"
else
   CMAKE_GEN="Unix Makefiles"
   CPP_WINFLAGS=""
fi

if [ "$ARCH" == "64" ] ; then
   FPERM="-fpermissive" # DB: Otherwise 64 bit build fails
else
   FPERM=""
fi

#export CFLAGS="-m$ARCH -I$PREFIX/include -I$FBX_SDK_DIR/include"
#export CXXFLAGS="-m$ARCH -I$PREFIX/include -I$PREFIX/include/libpng16 -I$PREFIX/include/bullet -I$PREFIX/include/AL -I$PREFIX/include/GL -I$FBX_SDK_DIR/include $CPP_WINFLAGS -DUNICODE -Wall -Wno-unknown-pragmas -Wno-builtin-macro-redefined -Wno-unused-variable ${FPERM}"
export CFLAGS="-m$ARCH -I$FBX_SDK_DIR/include"
export CXXFLAGS="-m$ARCH -I$FBX_SDK_DIR/include $CPP_WINFLAGS -DUNICODE -Wall -Wno-unknown-pragmas -Wno-builtin-macro-redefined -Wno-unused-variable ${FPERM}"
#export LDFLAGS="-m$ARCH -L$PREFIX/lib $LDFLAGS"
export LDFLAGS="-m$ARCH $LDFLAGS"

#rm -rf $GP_DIR/$BUILD_DIR && 
mkdir $GP_DIR/$BUILD_DIR
pushd .
cd $GP_DIR/$BUILD_DIR

#cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=$BUILD -DOS_ARCH=$ARCH -G"$CMAKE_GEN" ..

# To compile gameplay lib use this cmake. Comment out samples and tools in main CMakeLists.txt:
#cmake -DCMAKE_BUILD_TYPE=$BUILD -DOS_ARCH=$ARCH -G"$CMAKE_GEN" ..

# To compile utilities under tools folder use this cmake:
#cmake -DCMAKE_BUILD_TYPE=$BUILD -DOS_ARCH=$ARCH -G"$CMAKE_GEN" -DCMAKE_EXE_LINKER_FLAGS="-static $LDFLAGS" ..

# To build sample applications use this cmake line:
cmake -DCMAKE_BUILD_TYPE=$BUILD -DOS_ARCH=$ARCH -G"$CMAKE_GEN" -DCMAKE_EXE_LINKER_FLAGS="$LDFLAGS" ..

make -j4 VERBOSE=1
ERROR=$?
if [ "$BUILD" == "Release" ]; then
  cp -u gameplay/libgameplay.a $PREFIX/lib/
else
  cp -u gameplay/libgameplay.a $PREFIX/lib/libgameplay_debug.a
fi
cp -u gameplay/libgameplay.a $GP_DEST/
cp -u tools/encoder/gameplay-encoder $GP_ENC_DEST/
cp -u tools/luagen/gameplay-luagen $GP_ENC_DEST/
popd
echo $GP_DEST
echo $GP_ENC_DEST

T2=`date +%s`
TIME=`echo "" | awk '{ printf("%.1f", (T2-T1)/60) }' T1=$T1 T2=$T2`
STEP="Finished in $TIME min. ERROR: $ERROR. You now can now use gameplay library in $PREFIX/lib"
echo $STEP
echo $LDFLAGS
