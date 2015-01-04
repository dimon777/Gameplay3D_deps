Gameplay3D_deps
===============

This repository is for Gameplay3d dependencies, along with compile procedure for Linux(gcc) and Windows7(MinGW multilib compiler). It may work on other O/S, but I only tested dependencies compillation on these two platforms.

  yasm
  libav
  zlib
  tinyxml
  pcre
  openal
  libogg
  libvorbis
  lua
  libpng
  glew
  freetype
  freeglut
  bullet

Conventions
===========
<lib>/x.xx	folder <-- Sources taken from Download page on the wesite for library
<lib>/repo	folder <-- Sources taken via git pull
/usr/local64	folder <-- Default isntallation locaton for dependencies for 64 bit deployments
/usr/local32	folder <-- Default isntallation locaton for dependencies for 32 bit deployments

Prerequisites
=============
dos2unix
CMake
MinGW+MSYS (Windows only)


Gotchas (Linux)
===============
Some libraries maybe already presented in your O/S. This may lead to some issues when compiling GP3d or its samples. Specifially on 64 bit ArchLinux, I've encountered error when building browser sample against custom build libpng. This is simply because browser sample has gtk dependency, whcih is installed on my O/S, which is in turn dependent on libpng isntalled on my O/S. When you compile this sample agaisnt your own compiled version of libpng, wit will likely fail. This is not a big deal really, and easy can be fixed by uninstalling your version of libpng.

Gotchas Windows + MinGW
=======================
There are many...
First of all, you need to download and install MinGW multilib compiler for intstance from here:

1) Get MinGW from here:
http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/4.8.2/threads-posix/sjlj/

2) Get MSYS from here:
http://sourceforge.net/projects/mingwbuilds/files/external-binary-packages/

And dump it inside c:\compiler\mingw32_sjlj folder like so:

c:\compiler\mingw32_sjlj	<-- MinGW goes here
			bin
			etc
			...
			msys	<-- MSYS goes here
			    bin
			    etc
			    ...


Gotchas Libraries
=================

Bullet
------
There is bug in Bullet "make install" where file src/BulletDynamics/ConstraintSolver/btFixedConstraint.h not copied over to include filder. This is done manually.


Glew and Freeglut
-----------------
On CentOS these libs require some rpms whcih are missing in default installs. You may want to uncomment relevant lines in the gp.deps.sh sections. On ArchLinux there are no such problem. Arch rules!!! ;)



Gameplay3D
----------

Correct CMake for luagen to refrect proper location for luagen tool
In tools/luagen/CMakeLists.txt change:

This: 
link_directories(
    ${CMAKE_SOURCE_DIR}/external-deps/lua/lib/linux/${ARCH_DIR}
    ${CMAKE_SOURCE_DIR}/external-deps/tinyxml2/lib/linux

To this:
link_directories(
    ${CMAKE_SOURCE_DIR}/external-deps/lua/lib/linux/${ARCH_DIR}
    ${CMAKE_SOURCE_DIR}/external-deps/tinyxml2/lib/linux/${ARCH_DIR}


ERROR when compiling samples:
undefined reference to `ov_open_callbacks'
In respective sample CMakeLists.txt add vorbisfile like so:
    ...
    vorbisfile
    vorbis
    ...

ERROR: gameplay not found during linking samples:
In samples/CMakeLists.txt change:
This:
link_directories(
    ${CMAKE_SOURCE_DIR}/external-deps/lua/lib/linux/${ARCH_DIR}

To this:
link_directories(
    ${PROJECT_BINARY_DIR}/gameplay
    ${CMAKE_SOURCE_DIR}/external-deps/lua/lib/linux/${ARCH_DIR}



Thanks,
Dimon
