#!/bin/bash -e

if [ -z $BUILD_TYPE ]; then
    BUILD_TYPE=release
fi

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -z $BOOST_LIBRARYDIR ]; then
    BOOST_LIBRARYDIR=${ROOT_DIR}/../ofxiOSBoost/build/ios/prefix/lib
fi
if [ -z $BOOST_LIBRARYDIR_x86_64 ]; then
    BOOST_LIBRARYDIR_x86_64=${ROOT_DIR}/../ofxiOSBoost/build/libs/boost/lib/x86_64
fi
if [ -z $BOOST_INCLUDEDIR ]; then
    BOOST_INCLUDEDIR=${ROOT_DIR}/../ofxiOSBoost/build/ios/prefix/include
fi
if [ -z $OPENSSL_INCLUDE_DIR ]; then
    OPENSSL_INCLUDE_DIR=${ROOT_DIR}/../OpenSSL/include
fi
if [ -z $OPENSSL_ROOT_DIR ]; then
    OPENSSL_ROOT_DIR=${ROOT_DIR}/../OpenSSL
fi
if [ -z $INSTALL_PREFIX ]; then
    INSTALL_PREFIX=${ROOT_DIR}/bittube
fi

echo "Building IOS armv7"
rm -r bittube/build > /dev/null
mkdir -p bittube/build/release
pushd bittube/build/release
cmake -D IOS=ON -D ARCH=armv7 -D BOOST_LIBRARYDIR=${BOOST_LIBRARYDIR} -D BOOST_INCLUDEDIR=${BOOST_INCLUDEDIR} -D OPENSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR} -D OPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR} -D CMAKE_BUILD_TYPE=release -D STATIC=ON -D BUILD_GUI_DEPS=ON -D INSTALL_VENDORED_LIBUNBOUND=ON -D CMAKE_INSTALL_PREFIX=$INSTALL_PREFIX  ../..
make -j4 && make install
popd

echo "Building IOS arm64"
rm -r bittube/build > /dev/null
mkdir -p bittube/build/release
pushd bittube/build/release
cmake -D IOS=ON -D ARCH=arm64 -D BOOST_LIBRARYDIR=${BOOST_LIBRARYDIR} -D BOOST_INCLUDEDIR=${BOOST_INCLUDEDIR} -D OPENSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR} -D OPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR} -D CMAKE_BUILD_TYPE=release -D STATIC=ON -D BUILD_GUI_DEPS=ON -D INSTALL_VENDORED_LIBUNBOUND=ON -D CMAKE_INSTALL_PREFIX=$INSTALL_PREFIX  ../..
make -j4 && make install
popd

echo "Building IOS x86"
rm -r bittube/build > /dev/null
mkdir -p bittube/build/release
pushd bittube/build/release
cmake -D IOS=ON -D ARCH=x86_64 -D IOS_PLATFORM=SIMULATOR64 -D BOOST_LIBRARYDIR=${BOOST_LIBRARYDIR_x86_64} -D BOOST_INCLUDEDIR=${BOOST_INCLUDEDIR} -D OPENSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR} -D OPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR} -D CMAKE_BUILD_TYPE=release -D STATIC=ON -D BUILD_GUI_DEPS=ON -D INSTALL_VENDORED_LIBUNBOUND=ON -D CMAKE_INSTALL_PREFIX=$INSTALL_PREFIX  ../..
make  && make install
popd


echo "Creating fat library for armv7 and arm64"
pushd bittube
mkdir -p lib-ios
lipo -create lib-armv7/libwallet_merged.a lib-x86_64/libwallet_merged.a lib-arm64/libwallet_merged.a -output lib-ios/libwallet_merged.a
lipo -create lib-armv7/libunbound.a lib-x86_64/libunbound.a lib-armv8-a/libunbound.a -output lib-ios/libunbound.a
lipo -create lib-armv7/libepee.a lib-x86_64/libepee.a lib-arm64/libepee.a -output lib-ios/libepee.a
lipo -create lib-armv7/libeasylogging.a lib-x86_64/libeasylogging.a lib-armv8-a/libeasylogging.a -output lib-ios/libeasylogging.a
lipo -create lib-armv7/liblmdb.a lib-x86_64/liblmdb.a lib-armv8-a/liblmdb.a -output lib-ios/liblmdb.a
popd
