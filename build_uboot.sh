#!/bin/bash

CUR_DIR=${PWD}
source ${CUR_DIR}/buildFuncDefine.sh
CPU_CORES=`grep -c processor /proc/cpuinfo`

# arm linaro
IMX6ULL_CROSS_TOOLCHAIN_VENDOR=linaro

IMX6ULL_CROSS_TOOLCHAIN_YEAR=2022
IMX6ULL_CROSS_TOOLCHAIN_MONTH=08

IMX6ULL_CROSS_TOOLCHAIN_GCC_MAJOR=12
IMX6ULL_CROSS_TOOLCHAIN_GCC_MINOR=1
IMX6ULL_CROSS_TOOLCHAIN_GCC_PATCH=1

IMX6ULL_CROSS_TOOLCHAIN_PATH=
IMX6ULL_CROSS_TOOLCHAIN_SUBFIX=
IMX6ULL_CROSS_TOOLCHAIN_PREFIX=

if [ "$IMX6ULL_CROSS_TOOLCHAIN_VENDOR" = "arm" ]; then
    IMX6ULL_CROSS_TOOLCHAIN_PREFIX=arm-none-linux-gnueabihf
    IMX6ULL_CROSS_TOOLCHAIN_SUBFIX=/opt/toolchain/gcc-arm-${IMX6ULL_CROSS_TOOLCHAIN_GCC_MAJOR}.${IMX6ULL_CROSS_TOOLCHAIN_GCC_MINOR}-${IMX6ULL_CROSS_TOOLCHAIN_YEAR}.${IMX6ULL_CROSS_TOOLCHAIN_MONTH}-x86_64
    IMX6ULL_CROSS_TOOLCHAIN_PATH=${IMX6ULL_CROSS_TOOLCHAIN_SUBFIX}-${IMX6ULL_CROSS_TOOLCHAIN_PREFIX}
else
    IMX6ULL_CROSS_TOOLCHAIN_PREFIX=arm-linux-gnueabihf
    IMX6ULL_CROSS_TOOLCHAIN_SUBFIX=/opt/toolchain/gcc-linaro-${IMX6ULL_CROSS_TOOLCHAIN_GCC_MAJOR}.${IMX6ULL_CROSS_TOOLCHAIN_GCC_MINOR}.${IMX6ULL_CROSS_TOOLCHAIN_GCC_PATCH}-${IMX6ULL_CROSS_TOOLCHAIN_YEAR}.${IMX6ULL_CROSS_TOOLCHAIN_MONTH}-x86_64
    IMX6ULL_CROSS_TOOLCHAIN_PATH=${IMX6ULL_CROSS_TOOLCHAIN_SUBFIX}_${IMX6ULL_CROSS_TOOLCHAIN_PREFIX}
fi

IMX6ULL_EMMC_DEFCONFIG=imx6ull_14x14_ddr512_emmc_defconfig
IMX6ULL_CROSS_COMPILE=${IMX6ULL_CROSS_TOOLCHAIN_PATH}/bin/${IMX6ULL_CROSS_TOOLCHAIN_PREFIX}-

function imx6ull_uboot()
{
    make ARCH=arm CROSS_COMPILE=${IMX6ULL_CROSS_COMPILE} ${IMX6ULL_EMMC_DEFCONFIG}
    if [ $? -ne 0 ]; then
        error_exit "配置uboot失败"
    fi

    if confirm "是否需要打开menuconfig进行参数配置?"; then
        make ARCH=arm CROSS_COMPILE=${IMX6ULL_CROSS_COMPILE} menuconfig
    fi

    print_info "开始构建uboot"

    make ARCH=arm CROSS_COMPILE=${IMX6ULL_CROSS_COMPILE} -j${CPU_CORES}
    if [ $? -ne 0 ]; then
        error_exit "构建uboot失败"
    fi

    print_info "uboot构建完成"
}

function clean()
{
    make ARCH=arm CROSS_COMPILE=${IMX6ULL_CROSS_COMPILE} distclean
}

function help()
{
    print_logo

    echo "Usage: $0 [OPTION]"
    echo "[OPTION]:"
    echo "============================================"
    echo "  -  clean          清理构建的工程"
    echo "  -  imx6ull_uboot  开始构建imx6ull uboot目标"
    echo "============================================"
}

if [ -z $1 ]; then
    help
else
    $1
fi