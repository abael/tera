#!/bin/bash

set -e -u -E # this script will exit if any sub-command fails

########################################
# download & build depend software
########################################

WORK_DIR=$(cd $(dirname $0); pwd)
DEPS_SOURCE=$WORK_DIR/thirdsrc
DEPS_PREFIX=$WORK_DIR/thirdparty
DEPS_CONFIG="--prefix=${DEPS_PREFIX} --disable-shared --with-pic"
FLAG_DIR=$WORK_DIR/.build

export PATH=${DEPS_PREFIX}/bin:$PATH
mkdir -p ${DEPS_SOURCE} ${DEPS_PREFIX} ${FLAG_DIR}

if [ ! -f "$WORK_DIR/depends.mk" ]; then
    cp $WORK_DIR/depends.mk.template $WORK_DIR/depends.mk
fi

cd ${DEPS_SOURCE}

# boost
if [ ! -f "${FLAG_DIR}/boost_1_58_0" ] \
    || [ ! -d "${DEPS_PREFIX}/boost_1_58_0/boost" ]; then
    wget -O boost_1_58_0.tar.bz2 http://mirrors.163.com/gentoo/distfiles/boost_1_58_0.tar.bz2
    tar xjf boost_1_58_0.tar.bz2
    rm -rf ${DEPS_PREFIX}/boost_1_58_0
    mv boost_1_58_0 ${DEPS_PREFIX}
    touch "${FLAG_DIR}/boost_1_58_0"
fi

# protobuf
if [ ! -f "${FLAG_DIR}/protobuf_2_6_1" ] \
    || [ ! -f "${DEPS_PREFIX}/lib/libprotobuf.a" ] \
    || [ ! -d "${DEPS_PREFIX}/include/google/protobuf" ]; then
    # wget --no-check-certificate https://github.com/google/protobuf/releases/download/v2.6.1/protobuf-2.6.1.tar.gz
    rm -rf protobuf
    git clone --depth=1 https://github.com/00k/protobuf
    mv protobuf/protobuf-2.6.1.tar.gz .
    tar zxf protobuf-2.6.1.tar.gz
    cd protobuf-2.6.1
    ./configure ${DEPS_CONFIG}
    make -j4
    make install
    cd -
    touch "${FLAG_DIR}/protobuf_2_6_1"
fi

# snappy
if [ ! -f "${FLAG_DIR}/snappy_1_1_1" ] \
    || [ ! -f "${DEPS_PREFIX}/lib/libsnappy.a" ] \
    || [ ! -f "${DEPS_PREFIX}/include/snappy.h" ]; then
    # wget --no-check-certificate https://snappy.googlecode.com/files/snappy-1.1.1.tar.gz
    rm -rf snappy
    git clone --depth=1 https://github.com/00k/snappy
    mv snappy/snappy-1.1.1.tar.gz .
    tar zxf snappy-1.1.1.tar.gz
    cd snappy-1.1.1
    ./configure ${DEPS_CONFIG}
    make -j4
    make install
    cd -
    touch "${FLAG_DIR}/snappy_1_1_1"
fi

# sofa-pbrpc
if [ ! -f "${FLAG_DIR}/sofa-pbrpc_1_1_0" ] \
    || [ ! -f "${DEPS_PREFIX}/lib/libsofa-pbrpc.a" ] \
    || [ ! -d "${DEPS_PREFIX}/include/sofa/pbrpc" ]; then
    wget --no-check-certificate -O sofa-pbrpc-1.1.0.tar.gz https://github.com/baidu/sofa-pbrpc/archive/v1.1.0.tar.gz
    tar zxf sofa-pbrpc-1.1.0.tar.gz
    cd sofa-pbrpc-1.1.0
    sed -i '/BOOST_HEADER_DIR=/ d' depends.mk
    sed -i '/PROTOBUF_DIR=/ d' depends.mk
    sed -i '/SNAPPY_DIR=/ d' depends.mk
    echo "BOOST_HEADER_DIR=${DEPS_PREFIX}/boost_1_58_0" >> depends.mk
    echo "PROTOBUF_DIR=${DEPS_PREFIX}" >> depends.mk
    echo "SNAPPY_DIR=${DEPS_PREFIX}" >> depends.mk
    echo "PREFIX=${DEPS_PREFIX}" >> depends.mk
    make -j4
    make install
    cd ..
    touch "${FLAG_DIR}/sofa-pbrpc_1_1_0"
fi

# zookeeper
if [ ! -f "${FLAG_DIR}/zookeeper_3_4_9" ] \
    || [ ! -f "${DEPS_PREFIX}/lib/libzookeeper_mt.a" ] \
    || [ ! -d "${DEPS_PREFIX}/include/zookeeper" ]; then
    wget -O zookeeper-3.4.9.tar.gz http://mirrors.163.com/gentoo/distfiles/zookeeper-3.4.9.tar.gz
    tar zxf zookeeper-3.4.9.tar.gz
    cd zookeeper-3.4.9/src/c
    ./configure ${DEPS_CONFIG}
    make -j4
    make install
    cd -
    touch "${FLAG_DIR}/zookeeper_3_4_9"
fi

# cmake for gflags
if [ ! -f "${FLAG_DIR}/cmake_3_2_1" ] \
    || [ ! -f "${DEPS_PREFIX}/bin/cmake" ]; then
    wget --no-check-certificate -O CMake-3.2.1.tar.gz https://github.com/Kitware/CMake/archive/v3.2.1.tar.gz
    tar zxf CMake-3.2.1.tar.gz
    cd CMake-3.2.1
    ./configure --prefix=${DEPS_PREFIX}
    make -j4
    make install
    cd -
    touch "${FLAG_DIR}/cmake_3_2_1"
fi

# gflags
if [ ! -f "${FLAG_DIR}/gflags_2_1_1" ] \
    || [ ! -f "${DEPS_PREFIX}/lib/libgflags.a" ] \
    || [ ! -d "${DEPS_PREFIX}/include/gflags" ]; then
    wget --no-check-certificate -O gflags-2.1.1.tar.gz https://github.com/schuhschuh/gflags/archive/v2.1.1.tar.gz
    tar zxf gflags-2.1.1.tar.gz
    cd gflags-2.1.1
    cmake -DCMAKE_INSTALL_PREFIX=${DEPS_PREFIX} -DGFLAGS_NAMESPACE=google -DCMAKE_CXX_FLAGS=-fPIC
    make -j4
    make install
    cd -
    touch "${FLAG_DIR}/gflags_2_1_1"
fi

# glog
if [ ! -f "${FLAG_DIR}/glog_0_3_3" ] \
    || [ ! -f "${DEPS_PREFIX}/lib/libglog.a" ] \
    || [ ! -d "${DEPS_PREFIX}/include/glog" ]; then
    wget --no-check-certificate -O glog-0.3.3.tar.gz https://github.com/google/glog/archive/v0.3.3.tar.gz
    tar zxf glog-0.3.3.tar.gz
    cd glog-0.3.3
    ./configure ${DEPS_CONFIG} CPPFLAGS=-I${DEPS_PREFIX}/include LDFLAGS=-L${DEPS_PREFIX}/lib
    make -j4
    make install
    cd -
    touch "${FLAG_DIR}/glog_0_3_3"
fi

# gtest
if [ ! -f "${FLAG_DIR}/gtest_1_7_0" ] \
    || [ ! -f "${DEPS_PREFIX}/lib/libgtest.a" ] \
    || [ ! -d "${DEPS_PREFIX}/include/gtest" ]; then
    rm -rf ./googletest-release-1.7.0
    wget --no-check-certificate -O googletest-release-1.7.0.zip https://codeload.github.com/google/googletest/zip/release-1.7.0
    unzip googletest-release-1.7.0.zip
    cd googletest-release-1.7.0

    # XXX make gcc3 happy; what's the cmake way?
    sed -i 's/ -Wno-missing-field-initializers/ /' cmake/internal_utils.cmake

    mkdir tmpbuild
    cd tmpbuild
    cmake -DCMAKE_C_FLAGS="-fPIC" -DCMAKE_CXX_FLAGS="-fPIC" ..
    make
    cd ..
    cp -af tmpbuild/libgtest.a ${DEPS_PREFIX}/lib
    cp -af tmpbuild/libgtest_main.a ${DEPS_PREFIX}/lib
    cp -af include/gtest ${DEPS_PREFIX}/include
    cd ..
    touch "${FLAG_DIR}/gtest_1_7_0"
fi

# libunwind for gperftools
if [ ! -f "${FLAG_DIR}/libunwind_0_99_beta" ] \
    || [ ! -f "${DEPS_PREFIX}/lib/libunwind.a" ] \
    || [ ! -f "${DEPS_PREFIX}/include/libunwind.h" ]; then
    wget http://mirrors.163.com/gentoo/distfiles/libunwind-0.99.tar.gz
    tar xzf libunwind-0.99.tar.gz
    cd libunwind-0.99
    ./configure ${DEPS_CONFIG}
    make CFLAGS=-fPIC -j4
    make CFLAGS=-fPIC install
    cd -
    touch "${FLAG_DIR}/libunwind_0_99_beta"
fi

# gperftools (tcmalloc)
if [ ! -f "${FLAG_DIR}/gperftools_2_2_1" ] \
    || [ ! -f "${DEPS_PREFIX}/lib/libtcmalloc_minimal.a" ]; then
    # wget --no-check-certificate https://googledrive.com/host/0B6NtGsLhIcf7MWxMMF9JdTN3UVk/gperftools-2.2.1.tar.gz
    rm -rf gperftools
    git clone --depth=1 https://github.com/00k/gperftools
    mv gperftools/gperftools-2.2.1.tar.gz .
    tar zxf gperftools-2.2.1.tar.gz
    cd gperftools-2.2.1
    ./configure ${DEPS_CONFIG} CPPFLAGS=-I${DEPS_PREFIX}/include LDFLAGS=-L${DEPS_PREFIX}/lib
    make -j4
    make install
    cd -
    touch "${FLAG_DIR}/gperftools_2_2_1"
fi

# ins
if [ ! -f "${FLAG_DIR}/ins_0_14" ] \
    || [ ! -f "${DEPS_PREFIX}/lib/libins_sdk.a" ] \
    || [ ! -f "${DEPS_PREFIX}/include/ins_sdk.h" ]; then
    wget --no-check-certificate -O ins-0.14.tar.gz https://github.com/baidu/ins/archive/0.14.tar.gz
    tar zxf ins-0.14.tar.gz
    cd ins-0.14
    sed -i "s|^PREFIX=.*|PREFIX=${DEPS_PREFIX}|" Makefile
    sed -i "s|^PROTOC=.*|PROTOC=${DEPS_PREFIX}/bin/protoc|" Makefile
    BOOST_PATH=${DEPS_PREFIX}/boost_1_58_0 make install_sdk
    make -j4 install_sdk
    cd -
    touch "${FLAG_DIR}/ins_0_14"
fi

cd ${WORK_DIR}

########################################
# config depengs.mk
########################################

sed -i "s:^SOFA_PBRPC_PREFIX=.*:SOFA_PBRPC_PREFIX=$DEPS_PREFIX:" depends.mk
sed -i "s:^PROTOBUF_PREFIX=.*:PROTOBUF_PREFIX=$DEPS_PREFIX:" depends.mk
sed -i "s:^SNAPPY_PREFIX=.*:SNAPPY_PREFIX=$DEPS_PREFIX:" depends.mk
sed -i "s:^ZOOKEEPER_PREFIX=.*:ZOOKEEPER_PREFIX=$DEPS_PREFIX:" depends.mk
sed -i "s:^GFLAGS_PREFIX=.*:GFLAGS_PREFIX=$DEPS_PREFIX:" depends.mk
sed -i "s:^GLOG_PREFIX=.*:GLOG_PREFIX=$DEPS_PREFIX:" depends.mk
sed -i "s:^GTEST_PREFIX=.*:GTEST_PREFIX=$DEPS_PREFIX:" depends.mk
sed -i "s:^GPERFTOOLS_PREFIX=.*:GPERFTOOLS_PREFIX=$DEPS_PREFIX:" depends.mk
sed -i "s:^BOOST_INCDIR=.*:BOOST_INCDIR=$DEPS_PREFIX/boost_1_58_0:" depends.mk
sed -i "s:^INS_PREFIX=.*:INS_PREFIX=$DEPS_PREFIX:" depends.mk

########################################
# build tera
########################################

make -j4
