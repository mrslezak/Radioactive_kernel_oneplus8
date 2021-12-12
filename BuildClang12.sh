#!/bin/bash
rm .version

clear
cd /home/user/Radioactive_kernel_oneplus8/
#cp Makefile.clang11 Makefile

rm -rf out-clang12
mkdir out-clang12

# Resources
THREAD="-j8"
KERNEL="Image"
DTBIMAGE="dtb"

export CLANG_PATH=/home/user/toolchains/proton-clang/bin/
export PATH=${CLANG_PATH}:${PATH}
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=/home/user/toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android- CC=clang CXX=clang++
export CROSS_COMPILE_ARM32=/home/user/toolchains/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
export KBUILD_COMPILER_STRING=$(/home/user/toolchains/proton-clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
export CXXFLAGS="$CXXFLAGS -fPIC"
export DTC_EXT=dtc

DEFCONFIG="radioactive_defconfig"

# Paths
KERNEL_DIR=`pwd`
ZIMAGE_DIR="/home/user/Radioactive_kernel_oneplus8/out-clang12/arch/arm64/boot/"

# Kernel Details
VER="-2.3.1"

# Vars
BASE_AK_VER="RadioActive-WL-295_UC-920-GPU"
AK_VER="$BASE_AK_VER$VER"
export LOCALVERSION=~`echo $AK_VER`
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=MattoftheDead
export KBUILD_BUILD_HOST=DebianWSL2

DATE_START=$(date +"%s")

echo -e "${green}"
echo "-------------------"
echo "Making Kernel:"
echo "-------------------"
echo -e "${restore}"

echo
make CC="ccache clang" CXX="ccache clang++" O=out-clang12 $DEFCONFIG
make CC="ccache clang" CXX="ccache clang++" O=out-clang12 $THREAD 2>&1 | tee kernel.log

echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
cd $ZIMAGE_DIR
ls -a

# Make a dtb file
#find ~/op8T_2.1.4_radioactive_GPUOC/out-clang/arch/arm64/boot/dts/vendor/qcom -name '*.dtb' -exec cat {} + > ~/op8/out-clang/arch/arm64/boot/dtb
cd /home/user/Radioactive_kernel_oneplus8/out-clang12/arch/arm64/boot/
cat dts/vendor/qcom/kona.dtb dts/vendor/qcom/kona-v2.dtb dts/vendor/qcom/kona-v2.1.dtb > dtb
ls -a

# Put dtb and Image.gz in an AnyKernel3 zip archive and flash from TWRP
AK_ZIP="$AK_VER.zip"
cp dtb /home/user/AnyKernel3/
cp Image.gz /home/user/AnyKernel3/
cd /home/user/AnyKernel3/
rm Image
zip -r9 ${AK_ZIP} .
ls *.zip
mv ${AK_ZIP} /home/user/
