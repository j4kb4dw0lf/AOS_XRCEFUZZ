#!/bin/bash

# Set environment variables
export PATH="/usr/lib/llvm-11/bin:${PATH}"
export LLVM_CONFIG="/usr/lib/llvm-11/bin/llvm-config"

# Apply patches to specific files
patch /app/Micro-XRCE-DDS-Agent/src/cpp/types/XRCETypes.cpp < /app/patches/XRCETypes.cpp.patch
patch /app/Micro-XRCE-DDS-Agent/include/uxr/agent/message/InputMessage.hpp < /app/patches/InputMessage.hpp.patch

# Build Micro-XRCE-DDS-patched-agent
cd /app/Micro-XRCE-DDS-Agent/build && \
cmake .. && \
make && \
make install && \
cd ../..