# Use a base image with common development tools
FROM ubuntu:22.04

# Set environment variables (optional, but good practice)
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install necessary packages:
# - build-essential: for compiling C/C++ code
# - cmake: build system for Micro-XRCE-DDS
# - git: for cloning repositories
# - automake, libtool, flex, bison: dependencies for aflnet
# - libnl-3-dev, libnl-genl-3-dev: networking libraries for aflnet
# - wget: useful for downloading things if needed later
# - llvm, clang: compilers often used with AFL++ (aflnet's base)
# - python3, python3-pip, python3-dev: for Python dependencies and tools
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    automake \
    libtool \
    wireshark \
    libcap-dev \
    libgraphviz-dev \
    flex \
    bison \
    libnl-3-dev \
    libnl-genl-3-dev \
    wget \
    python3 \
    python3-pip \
    python3-dev \
    software-properties-common \
    gnupg && \
    wget -qO - https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/llvm.gpg] http://apt.llvm.org/focal/ llvm-toolchain-focal-11 main" > /etc/apt/sources.list.d/llvm.list && \
    apt-get update && \
    apt-get install -y clang-11 llvm-11 llvm-11-dev libclang-11-dev && \
    rm -rf /var/lib/apt/lists/*


# Set working directory inside the container
WORKDIR /app

# Clone the repositories
RUN git clone https://github.com/eProsima/Micro-XRCE-DDS/ Micro-XRCE-DDS
RUN git clone https://github.com/aflnet/aflnet/

# Patch Files in aflnet with patches that work with micro-XRCE-DDS
COPY ./patches /app/patches
RUN patch /app/aflnet/afl-fuzz.c < /app/patches/afl-fuzz.c.patch && \
    patch /app/aflnet/aflnet.h < /app/patches/aflnet.h.patch && \
    patch /app/aflnet/afl-replay.c < /app/patches/afl-replay.c.patch && \
    patch /app/aflnet/aflnet.c < /app/patches/aflnet.c.patch && \
    patch /app/aflnet/aflnet-replay.c < /app/patches/aflnet-replay.c.patch

ENV PATH="/usr/lib/llvm-11/bin:${PATH}"
ENV LLVM_CONFIG="/usr/lib/llvm-11/bin/llvm-config"

# Add LLVM-CONFIG to env vars
RUN export CC="clang-11"   && \
    export CXX="clang++-11"


# Build aflnet
RUN cd aflnet && make clean all && \
    cd llvm_mode && \
    make && \
    cd ../.. && \
    export AFLNET=$(pwd)/aflnet && \
    export WORKDIR=$(pwd) && \
    export PATH=$PATH:$AFLNET && \
    export AFL_PATH=$AFLNET 

# Patch Files in Micro-XRCE-DDS with Makefile made to instrument the binary for aflnet

RUN patch /app/Micro-XRCE-DDS/CMakeLists.txt < /app/patches/CMakeLists.txt.patch

# Build Micro-XRCE-DDS
RUN mkdir -p Micro-XRCE-DDS/build && \
    cd Micro-XRCE-DDS/build && \
    cmake .. -DUXRCE_BUILD_EXAMPLES=ON && \
    make && \
    make install && \
    cd ../..

COPY ./scripts /app/scripts
# Place script files to run fuzzying campains in the container
#
#
#
#

CMD ["/bin/bash"]
