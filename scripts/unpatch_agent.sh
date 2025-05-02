#!/bin/bash

cd /

# Set environment variables
export PATH="/usr/lib/llvm-11/bin:${PATH}"
export LLVM_CONFIG="/usr/lib/llvm-11/bin/llvm-config"

# Apply patches to specific files
patch -R /app/Micro-XRCE-DDS/build/agent/src/cpp/types/XRCETypes.cpp < /app/patches/XRCETypes.cpp.patch
patch -R /app/Micro-XRCE-DDS/build/agent/src/agent/include/uxr/agent/message/InputMessage.hpp < /app/patches/InputMessage.hpp.patch

# Build Micro-XRCE-DDS-unpatched-agent
cd /app/Micro-XRCE-DDS/build && \
cmake .. -DUXRCE_BUILD_EXAMPLES=ON && \
make && \
make install && \
cd app
