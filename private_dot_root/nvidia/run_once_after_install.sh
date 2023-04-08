#!/usr/bin/bash

source "$CHEZMOI_SOURCE_DIR/common.sh"

install NVIDIA \
    acpi_call \
    nvidia-dkms nvidia-utils nvidia-prime \
    cuda intel-compute-runtime
