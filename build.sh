#!/bin/bash
trap 'echo now exiting on step: "$STEP"; exit' EXIT TERM QUIT INT

#. ~/.profile${1}

function dlfcn() {
if [ "$MSYSTEM" == "MINGW32" -o "$MSYSTEM" == "MINGW64" ] ; then
  STEP="dlfcn_win32/1.0.0/"
  pushd .; cd $STEP
  ./configure --cc="gcc -m$ARCH" --prefix=$PREFIX
  make clean && make && make install
  mkdir -p $PREFIX/lib/
  mkdir -p $PREFIX/include
# Because dlfcn doesn't care about --prefix:
  mv /mingw/lib/libdl.a $PREFIX/lib/
  mv /mingw/include/dlfcn.h $PREFIX/include
  popd
fi
}

function yasm() {
STEP="yasm/1.2.0"
pushd .; cd $STEP
./configure CC="gcc -m$ARCH" CXX="g++ -m$ARCH" --prefix=$PREFIX
make clean && make -j4 && make install
popd
}

function libav() {
STEP="libav/11.1"
pushd .; cd $STEP
./configure --cc="gcc -m$ARCH" --arch="$CPU_ARCH" --prefix=$PREFIX
make clean && make -r -j4 && make install
popd
}

function zlib() {
STEP="zlib/1.2.8"
pushd .; cd $STEP
rm -rf $BUILD_DIR && mkdir $BUILD_DIR && cd $BUILD_DIR
cmake -DCMAKE_RC_CFLAGS=$RCFLAGS -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=MinSizeRel -G"$CMAKE_GEN" ..
make && make install
popd
}

function tinyxml2() {
STEP="tinyxml2/2.0.2-115"
pushd .; cd $STEP
rm -rf $BUILD_DIR && mkdir $BUILD_DIR && cd $BUILD_DIR
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib -DCMAKE_BUILD_TYPE=MinSizeRel -G"$CMAKE_GEN" ..
make && make install LIBDIR=$PREFIX/lib
popd
}

function pcre() {
STEP="pcre/8.36"
pushd .; cd $STEP
rm -rf $BUILD_DIR && mkdir $BUILD_DIR && cd $BUILD_DIR
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=MinSizeRel -G"$CMAKE_GEN" ..
make && make install
popd
}

function openal() {
STEP="OpenAL/1.15.1"
pushd .; cd $STEP
rm -rf $BUILD_DIR && mkdir $BUILD_DIR && cd $BUILD_DIR
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DLIBTYPE="STATIC" -DEXAMPLES=OFF -DALSOFT_NO_CONFIG_UTIL=ON -DALSOFT_CONFIG=OFF -DALSOFT_EXAMPLES=OFF -DBUILD_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=MinSizeRel -G"$CMAKE_GEN" ..
#cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DLIBTYPE="STATIC" -DCMAKE_BUILD_TYPE=MinSizeRel -G"$CMAKE_GEN" ..
make && make install
popd
}

function libogg() {
STEP="libogg/1.3.2"
pushd .; cd $STEP
./configure WINDRES="$WINDRES" --prefix=$PREFIX
make clean && make -j4 && make install
popd
}

function libvorbis() {
STEP="libvorbis/1.3.4"
pushd .; cd $STEP
./configure WINDRES="$WINDRES" --prefix=$PREFIX
make clean && make -j4 && make install
popd
}


function lua() {
STEP="lua/5.2.3/"
pushd .; cd $STEP
make clean && make CC="gcc -m$ARCH" $LUA_BUILD && make install INSTALL_TOP=$PREFIX
popd
}

function libpng() {
STEP="libpng/1.6.16"
pushd .; cd $STEP
rm -rf $BUILD_DIR && mkdir $BUILD_DIR && cd $BUILD_DIR
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=MinSizeRel -G"$CMAKE_GEN" ..
make -j4
if [ "$MSYSTEM" == "MINGW32" -o "$MSYSTEM" == "MINGW64" ] ; then
   cp libpng16.dll.a libpng.dll.a
   cp libpng16.a libpng.a
   cp libpng16-config libpng-config
   cp libpng16.pc libpng.pc
fi
make install
popd
}

function glew() {
# http://stackoverflow.com/questions/15859031/glew-1-9-0-builds-a-64-bit-so-even-with-m32-argument
STEP="glew/1.10.0"
if [ "$MSYSTEM" == "MINGW32" -o "$MSYSTEM" == "MINGW64" ] ; then
   echo "" > /dev/null
else
echo ""
# For CentOS uncomment this line:   yum install -y libXi-devel.i686 libXi-devel.x86_64 libXmu-devel.i686 libXmu-devel.x86_64 libXext-devel.i686 libXext-devel.x86_64 libX11-devel.i686 libX11-devel.x86_64
fi
pushd .; cd $STEP
export GLEW_DEST=$PREFIX
make clean
#make CC="gcc -m$ARCH" LD="gcc -m$ARCH" LDFLAGS.SO="$LDFLAGS_SO" M_ARCH="$M_ARCH" all
make CC="gcc -m$ARCH" LD="gcc -m$ARCH" M_ARCH="$M_ARCH" all
#make CC="gcc -m$ARCH" LD="gcc -m$ARCH" all
make install LIBDIR=$PREFIX/lib
popd
}

function freetype() {
STEP="freetype/2.5.0"
pushd .; cd $STEP
./configure CC="gcc -m$ARCH" CXX='g++ -m$ARCH' --prefix=$PREFIX --without-bzip2
make clean && make && make install
popd
}

function freeglut() {
STEP="FreeGLUT/2.8.1"
pushd .; cd $STEP
# Uncomment this if on CentOS: yum install -y libXrandr.i686 libXrandr-devel.i686 libXxf86vm.i686 libXxf86vm-devel.i686
./configure CC="gcc -m$ARCH" CXX='g++ -m$ARCH' --prefix=$PREFIX
make clean && make && make install
popd
}

function bullet() {
#STEP="bullet/2.81-r2613/"
STEP="bullet/2.82-r2704"
pushd .; cd $STEP
chmod 755 autogen.sh
dos2unix autogen.sh
export USER=nonroot
./autogen.sh
./configure CC="gcc -m$ARCH" CXX="g++ -m$ARCH" CXXCPP="g++ -m$ARCH -E" --prefix=$PREFIX --disable-demos
make clean
make -j4 2>&1 | tee build_${ARCH}.log
make install
cp src/BulletDynamics/ConstraintSolver/btFixedConstraint.h $PREFIX/include/bullet/BulletDynamics/ConstraintSolver/
popd
}

if [ $# -eq 0 ]; then
  echo "Usage $0 <ARCH=32|64> <optional: module to compile>"
  echo "Example: $0 32 #will compile for 32 bit platform"
  echo "Example: $0 32 openal #will compile openal library only for 32 bit platform"
  exit 0
fi

T1=`date +%s`
ARCH=$1
MACH=`gcc -dumpmachine`
PREFIX=/usr/local$ARCH
BUILD_DIR=build.$ARCH.${MACH}
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:/usr/local/lib/pkgconfig"

export CFLAGS="-m$ARCH -I$PREFIX/include"
export CXXFLAGS="-m$ARCH -I$PREFIX/include"
export LDFLAGS="-m$ARCH -L$PREFIX/lib"
export PATH=$PREFIX/bin:$PATH
export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

if [ "$ARCH" == "32" ]
then
  export CPU_ARCH="i386"
  export RCFLAGS="pe-i386" # -F option to windres
  export WINDRES="windres -F pe-i386"
  LDFLAGS=$LDFLAGS:/usr/lib
elif [ "$ARCH" == "64" ]
then
  export CPU_ARCH="x86_64"
  export RCFLAGS="pe-x86-64" # -F option to windres
  export WINDRES="windres -F pe-x86-64"
fi

mkdir -p $PREFIX
touch $PREFIX/local$ARCH.dir

# Check if we run from MSYS and mount proper directories: /usr/local, /mingw
if [ "$MSYSTEM" == "MINGW32" -o "$MSYSTEM" == "MINGW64" ] ; then
#   umount /mingw
#   umount /usr/local
#   base=`env | grep msys | grep -v bin | awk -F= '{ print $2 }'`
#   mingw=`dirname $base`
#   mount $mingw /mingw
#   mount ${base}\\local$ARCH /usr/local
   CMAKE_GEN="MSYS Makefiles"
   LUA_BUILD="mingw"
   dlfcn # This only needed for win32/64
else
   CMAKE_GEN="Unix Makefiles"
   LUA_BUILD="linux"
fi

set -e

if [ $# -eq 2 ] ; then
  $2
else
  yasm
  libav
  zlib
  tinyxml2
# Uncomment below for MingGW on Windows platform:   
#  pcre
  openal
  libogg
  libvorbis
  lua
# Uncomment below for MingGW on Windows platform:
#  libpng
  glew
  freetype
  freeglut
  bullet
fi

T2=`date +%s`
TIME=`echo "" | awk '{ printf("%.1f", (T2-T1)/60) }' T1=$T1 T2=$T2`
STEP="Finished in $TIME min."
