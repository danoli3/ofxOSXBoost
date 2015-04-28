#===============================================================================
# Filename:  boost.sh
# Author:    Pete Goodliffe, Daniel Rosser
# Copyright: (c) Copyright 2009 Pete Goodliffe, 2013 Daniel Rosser
# Licence:   Please feel free to use this, with attribution
# Modified version ## for ofxOSXBoost
#===============================================================================
#
# Builds a Boost framework for the OSX.
# Creates a set of universal libraries that can be used on OSX (i386, x86_64)
#
# To configure the script, define:
#    BOOST_LIBS:        which libraries to build
#    OSX_SDKVERSION: OSX SDK version (e.g. 10.10)
#
# Then go get the source tar.bz of the boost you want to build, shove it in the
# same directory as this script, and run "./boost.sh". Grab a cuppa. And voila.
#===============================================================================

#!/bin/sh
here="`dirname \"$0\"`"
echo "cd-ing to $here"
cd "$here" || exit 1

CPPSTD=c++11    #c++89, c++99, c++14
STDLIB=libc++   # libstdc++
COMPILER=clang++

BOOST_V1=1.58.0
BOOST_V2=1_58_0

CURRENTPATH=`pwd`
LOGDIR="$CURRENTPATH/build/logs/"

OSX_SDKVERSION=`xcrun -sdk macosx --show-sdk-version`
DEVELOPER=`xcode-select -print-path`
XCODE_ROOT=`xcode-select -print-path`

if [ ! -d "$DEVELOPER" ]; then
  echo "xcode path is not set correctly $DEVELOPER does not exist (most likely because of xcode > 4.3)"
  echo "run"
  echo "sudo xcode-select -switch <xcode path>"
  echo "for default installation:"
  echo "sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer"
  exit 1
fi

case $DEVELOPER in  
     *\ * )
           echo "Your Xcode path contains whitespaces, which is not supported."
           exit 1
          ;;
esac

case $CURRENTPATH in  
     *\ * )
           echo "Your path contains whitespaces, which is not supported by 'make install'."
           exit 1
          ;;
esac

: ${BOOST_LIBS:="random regex graph random chrono thread signals filesystem system date_time"}
: ${OSX_SDKVERSION:=`xcrun -sdk macosx --show-sdk-version`}
: ${EXTRA_CPPFLAGS:="-DBOOST_AC_USE_PTHREADS -DBOOST_SP_USE_PTHREADS -std=$CPPSTD -stdlib=$STDLIB"}

# The EXTRA_CPPFLAGS definition works around a thread race issue in
# shared_ptr. I encountered this historically and have not verified that
# the fix is no longer required. Without using the posix thread primitives
# an invalid compare-and-swap ARM instruction (non-thread-safe) was used for the
# shared_ptr use count causing nasty and subtle bugs.
#
# Should perhaps also consider/use instead: -BOOST_SP_USE_PTHREADS

: ${TARBALLDIR:=`pwd`/..}
: ${SRCDIR:=`pwd`/../build/src}
: ${OSXBUILDDIR:=`pwd`/../build/libs/boost/lib}
: ${OSXINCLUDEDIR:=`pwd`/../build/libs/boost/include/boost}
: ${PREFIXDIR:=`pwd`/../build/osx/prefix}
: ${COMPILER:="clang++"}
: ${OUTPUT_DIR:=`pwd`/../libs/boost/}
: ${OUTPUT_DIR_LIB:=`pwd`/../libs/boost/lib/osx/}
: ${OUTPUT_DIR_SRC:=`pwd`/../libs/boost/include/boost}

: ${BOOST_VERSION:=$BOOST_V1}
: ${BOOST_VERSION2:=$BOOST_V2}

BOOST_TARBALL=$TARBALLDIR/boost_$BOOST_VERSION2.tar.bz2
BOOST_SRC=$SRCDIR/boost_${BOOST_VERSION2}
BOOST_INCLUDE=$BOOST_SRC/boost



#===============================================================================
OSX_DEV_CMD="xcrun --sdk macosx"

COMBINED_LIB=$OSXBUILDDIR/lib_boost.a

#===============================================================================


#===============================================================================
# Functions
#===============================================================================

abort()
{
    echo
    echo "Aborted: $@"
    exit 1
}

doneSection()
{
    echo
    echo "================================================================="
    echo "Done"
    echo
}

#===============================================================================

cleanEverythingReadyToStart()
{
    echo Cleaning everything before we start to build...

    rm -rf osx-build
    rm -rf $OSXBUILDDIR
    rm -rf $PREFIXDIR
    rm -rf $IOSINCLUDEDIR
    rm -rf $TARBALLDIR/build
    rm -rf $LOGDIR

    doneSection
}

postcleanEverything()
{
	echo Cleaning everything after the build...

	rm -rf osx-build
	rm -rf $PREFIXDIR
    rm -rf $OSXBUILDDIR/osx/i386/obj
	rm -rf $OSXBUILDDIR/osx/x86_64/obj
    rm -rf $TARBALLDIR/build
    rm -rf $LOGDIR
	doneSection
}

prepare()
{

    mkdir -p $LOGDIR
    mkdir -p $OUTPUT_DIR
    mkdir -p $OUTPUT_DIR_SRC
    mkdir -p $OUTPUT_DIR_LIB

}

#===============================================================================

downloadBoost()
{
    if [ ! -s $TARBALLDIR/boost_${BOOST_VERSION2}.tar.bz2 ]; then
        echo "Downloading boost ${BOOST_VERSION}"
        curl -L -o $TARBALLDIR/boost_${BOOST_VERSION2}.tar.bz2 http://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/boost_${BOOST_VERSION2}.tar.bz2/download
    fi

    doneSection
}

#===============================================================================

unpackBoost()
{
    [ -f "$BOOST_TARBALL" ] || abort "Source tarball missing."

    echo Unpacking boost into $SRCDIR...

    [ -d $SRCDIR ]    || mkdir -p $SRCDIR
    [ -d $BOOST_SRC ] || ( cd $SRCDIR; tar xfj $BOOST_TARBALL )
    [ -d $BOOST_SRC ] && echo "    ...unpacked as $BOOST_SRC"

    doneSection
}

#===============================================================================

updateBoost()
{
    echo Updating boost into $BOOST_SRC...

    cp $BOOST_SRC/tools/build/example/user-config.jam $BOOST_SRC/tools/build/example/user-config.jam.bk

    doneSection
}

#===============================================================================

#===============================================================================

bootstrapBoost()
{
    cd $BOOST_SRC

    BOOST_LIBS_COMMA=$(echo $BOOST_LIBS | sed -e "s/ /,/g")
    echo "Bootstrapping (with libs $BOOST_LIBS_COMMA)"
    ./bootstrap.sh --with-libraries=$BOOST_LIBS_COMMA

    doneSection
}


buildBoostForOSX()
{
    cd $BOOST_SRC

    set +e    
    echo "------------------"
    LOG="$LOGDIR/build-osx-stage.log"
    echo "Running bjam for osx-build stage"
    echo "To see status in realtime check:"
    echo " ${LOG}"
    echo "Please stand by..."

    ./b2 -j16 --build-dir=osx-build --stagedir=osx-build/stage --prefix=$PREFIXDIR toolset=clang cxxflags="-std=$CPPSTD -stdlib=$STDLIB -arch i386 -arch x86_64" linkflags="-stdlib=$STDLIB" link=static threading=multi stage > "${LOG}" 2>&1
    if [ $? != 0 ]; then 
        echo "Problem while Building osx-build stage - Please check ${LOG}"
        exit 1
    else 
        echo "osx-build stage successful"
    fi

    echo "------------------"
    LOG="$LOGDIR/build-osx-install.log"
    echo "Running bjam for osx-build install"
    echo "To see status in realtime check:"
    echo " ${LOG}"
    echo "Please stand by..."
    ./b2 -j16 --build-dir=osx-build --stagedir=osx-build/stage --prefix=$PREFIXDIR toolset=clang cxxflags="-std=$CPPSTD -stdlib=$STDLIB -arch i386 -arch x86_64" linkflags="-stdlib=$STDLIB" link=static threading=multi install > "${LOG}" 2>&1
    if [ $? != 0 ]; then 
        echo "Problem while Building osx-build install - Please check ${LOG}"
        exit 1
    else 
        echo "osx-build install successful"
    fi

    doneSection
}


#===============================================================================

scrunchAllLibsTogetherInOneLibPerPlatform()
{
    cd $BOOST_SRC

    mkdir -p $OSXBUILDDIR/osx/i386/obj
    mkdir -p $OSXBUILDDIR/osx/x86_64/obj

    ALL_LIBS=""

    echo Splitting all existing fat binaries...

    for NAME in $BOOST_LIBS; do
        ALL_LIBS="$ALL_LIBS libboost_$NAME.a"

		$OSX_DEV_CMD lipo "osx-build/stage/lib/libboost_$NAME.a" -thin i386 -o $OSXBUILDDIR/osx/i386/libboost_$NAME.a
		$OSX_DEV_CMD lipo "osx-build/stage/lib/libboost_$NAME.a" -thin x86_64 -o $OSXBUILDDIR/osx/x86_64/libboost_$NAME.a
  
    done

    echo "Decomposing each architecture's .a files"

    for NAME in $ALL_LIBS; do
        echo Decomposing $NAME...
        (cd $OSXBUILDDIR/osx/i386/obj; ar -x ../$NAME );
		(cd $OSXBUILDDIR/osx/x86_64/obj; ar -x ../$NAME );
    done

    echo "Linking each architecture into an uberlib ($ALL_LIBS => libboost.a )"

    rm $OSXBUILDDIR/osx/*/libboost.a
    
    echo ...i386
    (cd $OSXBUILDDIR/osx/i386;  $SIM_DEV_CMD ar crus libboost.a obj/*.o; )
    echo ...x86_64
    (cd $OSXBUILDDIR/osx/x86_64;  $SIM_DEV_CMD ar crus libboost.a obj/*.o; )

    echo "Making fat lib for iOS Boost $BOOST_VERSION"
    lipo -c $OSXBUILDDIR/osx/i386/libboost.a \
            $OSXBUILDDIR/osx/x86_64/libboost.a \
            -output $OUTPUT_DIR_LIB/boost.a

    echo "Completed Fat Lib"
    echo "------------------"

}

#===============================================================================
buildIncludes()
{
    
    mkdir -p $OSXINCLUDEDIR
    echo "------------------"
    echo "Copying Includes to Final Dir $OUTPUT_DIR_SRC"
    LOG="$LOGDIR/buildIncludes.log"
    set +e

    cp -r $PREFIXDIR/include/boost/*  $OUTPUT_DIR_SRC/ > "${LOG}" 2>&1
    if [ $? != 0 ]; then 
        echo "Problem while copying includes - Please check ${LOG}"
        exit 1
    else 
        echo "Copy of Includes successful"
    fi
    echo "------------------"

    doneSection
}

#===============================================================================
# Execution starts here
#===============================================================================

mkdir -p $OSXBUILDDIR

cleanEverythingReadyToStart #may want to comment if repeatedly running during dev

echo "BOOST_VERSION:     $BOOST_VERSION"
echo "BOOST_LIBS:        $BOOST_LIBS"
echo "BOOST_SRC:         $BOOST_SRC"
echo "OSXBUILDDIR:       $OSXBUILDDIR"
echo "PREFIXDIR:         $PREFIXDIR"
echo "OSX_SDKVERSION:    $OSX_SDKVERSION"
echo "XCODE_ROOT:        $XCODE_ROOT"
echo "COMPILER:          $COMPILER"
echo

downloadBoost
unpackBoost
prepare
bootstrapBoost
updateBoost
buildBoostForOSX
scrunchAllLibsTogetherInOneLibPerPlatform
buildIncludes


postcleanEverything

echo "Completed successfully"

#===============================================================================
