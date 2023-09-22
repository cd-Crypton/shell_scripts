#!/bin/bash

# Set project directory
PROJECT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

# Clang URL - Change the version, depends on your kernel source.
CLANG_TAR_URL="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master-kernel-build-2021/clang-r416183b.tar.gz"

# Utilities URL x86_x64 - Change it depends on your preference.
GAS_UTILS="https://android.googlesource.com/platform/prebuilts/gas/linux-x86"
GCC_64="https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9"
GCC_32="https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9"
UTILS_BRANCH="master-kernel-build-2021"

# AnyKernel3 Repo (Change it if you have different repo) - Credits to osm0sis
AK3="https://github.com/cd-Crypton/AnyKernel3"
AK3_BRANCH="FOR-ALL"

# Variables
CLO_REPO="https://git.codelinaro.org/clo/la/kernel"
ACK_REPO="https://android.googlesource.com/kernel/common"

# Directory variables
KERNEL_DIR="build_kernel" # for build.sh
OEM_KERNEL_DIR="oem_kernel" # for rebase.sh
CLO_VENDOR_DIR="clo_vendor" # for rebase.sh
CLO_KERNEL_DIR="clo_kernel" # for rebase.sh
ACK_KERNEL_DIR="ack_kernel" # for rebase.sh