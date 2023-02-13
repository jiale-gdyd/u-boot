#!/bin/bash

CUR_DIR=${PWD}
CPU_CORES=`grep -c processor /proc/cpuinfo`

IMX6ULL_CROSS_TOOLCHAIN_PREFIX=arm-none-linux-gnueabihf
IMX6ULL_CROSS_TOOLCHAIN_SUBFIX=/opt/toolchain/gcc-arm-10.3-2021.07-x86_64
IMX6ULL_CROSS_TOOLCHAIN_PATH=${IMX6ULL_CROSS_TOOLCHAIN_SUBFIX}-${IMX6ULL_CROSS_TOOLCHAIN_PREFIX}

IMX6ULL_EMMC_DEFCONFIG=imx6ull_14x14_ddr512_emmc_defconfig

function imx6ull_uboot()
{
    make ARCH=arm CROSS_COMPILE=${IMX6ULL_CROSS_TOOLCHAIN_PATH}/bin/${IMX6ULL_CROSS_TOOLCHAIN_PREFIX}- ${IMX6ULL_EMMC_DEFCONFIG}
    if [ $? -ne 0 ]; then
        echo "配置uboot失败"
        exit 127
    fi

    make ARCH=arm CROSS_COMPILE=${IMX6ULL_CROSS_TOOLCHAIN_PATH}/bin/${IMX6ULL_CROSS_TOOLCHAIN_PREFIX}- -j${CPU_CORES}
    if [ $? -ne 0 ]; then
        echo "构建uboot失败"
        exit 127
    fi

    echo "uboot构建完成"
}

function clean()
{
    make ARCH=arm CROSS_COMPILE=${IMX6ULL_CROSS_TOOLCHAIN_PATH}/bin/${IMX6ULL_CROSS_TOOLCHAIN_PREFIX}- distclean
}

function help()
{
    echo "Usage: $0 [OPTION]"
    echo "[OPTION]:"
    echo "================================="
    echo "  -  clean          清理构建的工程"
    echo "  -  imx6ull_uboot  开始构建uboot"
    echo "================================="
}

if [ -z $1 ]; then
    help
else
    $1
fi