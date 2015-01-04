#!/bin/bash

function mk_dir() {
  mkdir -p $GP_DIR/external-deps/$1/lib/$2/x86
  mkdir -p $GP_DIR/external-deps/$1/lib/$2/x64
  mkdir -p $GP_DIR/external-deps/$1/include
}

if [ $# -ne 2 ]; then
  echo "Usage $0 <32|64|arm> <Gameplay3D source dir>"
  echo "Example: $0 64 /data/src/libs/gameplay/repo"
  exit 0
fi

ARCH=$1
[[ "$ARCH" == "32" ]] && A="x86"
[[ "$ARCH" == "64" ]] && A="x64"
[[ "$ARCH" == "ARM" ]] && A="arm"

GP_DIR=$2
[ ! -d $GP_DIR ] && echo "GP3d direcotory not there..." && exit 1

OST=`echo $OSTYPE | awk -F"-" '{ print $1 }'`

mk_dir zlib $OST
mk_dir tinyxml2 $OST
mk_dir png $OST
mk_dir openal $OST
mk_dir oggvorbis $OST
mk_dir lua $OST
mk_dir glew $OST
mk_dir freetype2 $OST
mk_dir bullet $OST

# zlib
cp /usr/local$ARCH/include/z*.h $GP_DIR/external-deps/zlib/include/
cp /usr/local$ARCH/lib/libz.a $GP_DIR/external-deps/zlib/lib/$OST/$A/

# tinyxml2
cp /usr/local$ARCH/include/tinyxml2.h $GP_DIR/external-deps/tinyxml2/include/
cp /usr/local$ARCH/lib/libtinyxml2.a $GP_DIR/external-deps/tinyxml2/lib/$OST/$A/

#png
cp /usr/local$ARCH/include/libpng16/*.h $GP_DIR/external-deps/png/include/
cp /usr/local$ARCH/lib/libpng16.a $GP_DIR/external-deps/png/lib/$OST/$A/libpng.a

#openal
cp -r /usr/local$ARCH/include/AL $GP_DIR/external-deps/openal/include/
cp /usr/local$ARCH/lib/libopenal.a $GP_DIR/external-deps/openal/lib/$OST/$A/

#oggvorbis
cp -r /usr/local$ARCH/include/ogg $GP_DIR/external-deps/oggvorbis/include/
cp -r /usr/local$ARCH/include/vorbis $GP_DIR/external-deps/oggvorbis/include/
cp /usr/local$ARCH/lib/libogg.a $GP_DIR/external-deps/oggvorbis/lib/$OST/$A/
cp /usr/local$ARCH/lib/libvorbis*.a $GP_DIR/external-deps/oggvorbis/lib/$OST/$A/

#lua
cp /usr/local$ARCH/include/lua* $GP_DIR/external-deps/lua/include/
cp /usr/local$ARCH/lib/liblua.a $GP_DIR/external-deps/lua/lib/$OST/$A/

#glew
mkdir $GP_DIR/external-deps/glew/include/GL
cp -r /usr/local$ARCH/include/GL/*ew.h $GP_DIR/external-deps/glew/include/GL
cp /usr/local$ARCH/lib/libGLEW.a $GP_DIR/external-deps/glew/lib/$OST/$A/

#freetype2
cp -r /usr/local$ARCH/include/freetype2/freetype $GP_DIR/external-deps/freetype2/include/
cp -r /usr/local$ARCH/include/ft2build.h $GP_DIR/external-deps/freetype2/include/
cp /usr/local$ARCH/lib/libfreetype.a $GP_DIR/external-deps/freetype2/lib/$OST/$A/

#bullet
cp -r /usr/local$ARCH/include/bullet/* $GP_DIR/external-deps/bullet/include/ 
cp /usr/local$ARCH/lib/libBullet*.a $GP_DIR/external-deps/bullet/lib/$OST/$A/
cp /usr/local$ARCH/lib/libLinearMath.a $GP_DIR/external-deps/bullet/lib/$OST/$A/
