#!/bin/bash

# Set project directory
PROJECT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

source ${PROJECT_DIR}/vars.sh

if [ -z "${1}" ]; then
     echo "Usage: bash work/rebase.sh <caf or ack>"
     exit 1
else
     if [ "${1}" = "caf" ]; then
          echo "What's your OEM kernel source?"
          read oem_kernel_src
          echo "What's your OEM kernel source branch?"
          read oem_kernel_brnch
          echo "What's your target CLO kernel tag?"
          read clo_kernel_tag
          echo "Do you have commit hash available for CLO tag?"
          echo "Type yes or no."
          read clo_commit
          if [ "$clo_commit" = "yes" ]; then
               echo "What's your targey commit hash?"
               read commit_hash
          else
               echo "Rebasing without commit hash."
          fi
          # Clone the OEM Kernel Source
          cd ${PROJECT_DIR}
          if [ ! -d "${OEM_KERNEL_DIR}" ]; then
               git clone --depth=1 --single-branch $oem_kernel_src -b $oem_kernel_brnch ${OEM_KERNEL_DIR}
          else
               echo "OEM kernel already exist!"
          fi
          # Get Kernel Version
          KERNEL_VERSION="$(cat ${OEM_KERNEL_DIR}/Makefile | grep VERSION | head -n 1 | sed "s|.*=||1" | sed "s| ||g" )"
          KERNEL_SUBVERSION="$(cat ${OEM_KERNEL_DIR}/Makefile | grep PATCHLEVEL | head -n 1 | sed "s|.*=||1" | sed "s| ||g" )"
          CLO_REPO_FULL="${CLO_REPO}/msm-${KERNEL_VERSION}.${KERNEL_SUBVERSION}.git"
          
          # Clone the CAF Kernel Source
          if [ ! -d "${CLO_KERNEL_DIR}" ]; then
               git clone --single-branch ${CLO_REPO_FULL} -b $clo_kernel_tag ${CLO_KERNEL_DIR}
          else
               echo "CLO kernel already exist!"
          fi
          cd "${OEM_KERNEL_DIR}"
          OEM_DIR_LIST=$(find -type d -printf "%P\n" | grep -v / | grep -v .git)
          cd ..
          if [ "$clo_commit" = "no" ]; then
               # Set up CLO Kernel
               cd ${CLO_KERNEL_DIR}
               git switch -c master
               for i in ${OEM_DIR_LIST}; do
                    rm -rf ${i}
               done
               # Start Rebasing
               cd ${PROJECT_DIR}
               cp -r ${OEM_KERNEL_DIR}/* ${CLO_KERNEL_DIR}/
               cd ${CLO_KERNEL_DIR}
               git add .
               git commit -sm "OEM: Import all OEM source modifications."
               git branch -M $clo_kernel_tag
          else
               # Start Rebasing
               cd ${CLO_KERNEL_DIR}
               git reset --hard $commit_hash
               git switch -c master
               for i in ${OEM_DIR_LIST}; do
                    rm -rf ${i}
               done
               # Start Rebasing
               cd ${PROJECT_DIR}
               cp -r ${OEM_KERNEL_DIR}/* ${CLO_KERNEL_DIR}/
               cd ${CLO_KERNEL_DIR}
               git add .
               git commit -sm "OEM: Import all OEM source modifications."
               git branch -M $clo_kernel_tag
          fi
     elif [ "${1}" = "ack" ]; then
          echo "What's your OEM kernel source?"
          read oem_kernel_src
          echo "What's your OEM kernel source branch?"
          read oem_kernel_brnch
          echo "What's your target ACK kernel branch?"
          read ack_kernel_tag
          # Clone the OEM Kernel Source
          cd ${PROJECT_DIR}
          if [ ! -d "${OEM_KERNEL_DIR}" ]; then
               git clone --depth=1 --single-branch $oem_kernel_scr -b $oem_kernel_brnch ${OEM_KERNEL_DIR}
          else
               echo "OEM kernel already exist!"
          fi
          # Clone the ACK Kernel Source
          if [ ! -d "${ACK_KERNEL_DIR}" ]; then
               git clone --single-branch ${ACK_REPO} -b $ack_kernel_tag ${ACK_KERNEL_DIR}
          else
               echo "ACK kernel already exist!"
          fi
          # Get the OEM Kernel's Version
          cd ${OEM_KERNEL_DIR}
          OEM_DIR_LIST=$(find -type d -printf "%P\n" | grep -v / | grep -v .git)
          OEM_KERNEL_VERSION=$(make kernelversion)
          cd ..
          # Hard Reset ACK to ${OEM_KERNEL_VERSION}
          cd ${ACK_KERNEL_DIR}
          OEM_KERNEL_RESET_HASH=$(git log --oneline $ack_kernel_tag Makefile | grep -i ${OEM_KERNEL_VERSION} | grep -i merge | cut -d ' ' -f1)
          git reset --hard ${OEM_KERNEL_RESET_HASH}
          cd ..
          # Start Rebasing
          cd ${ACK_KERNEL_DIR}
          git reset --hard $commit_hash
          git switch -c master
          for i in ${OEM_DIR_LIST}; do
               rm -rf ${i}
          done
          # Start Rebasing
          cd ${PROJECT_DIR}
          cp -r ${OEM_KERNEL_DIR}/* ${ACK_KERNEL_DIR}/
          cd ${ACK_KERNEL_DIR}
          git add .
          git commit -sm "OEM: Import all OEM source modifications."
          git branch -M $ack_kernel_tag
     else
          echo "Argument were not clo nor ack!"
     fi
fi