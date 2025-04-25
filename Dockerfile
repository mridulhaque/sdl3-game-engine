# Base image for shared components
FROM ubuntu:24.04 as base

# Install common build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    git \
    gcc \
    g++ \
    wget \
    bash \
    libfreetype-dev \
    libgl1-mesa-dev \
    libgles2-mesa-dev \
    libasound2-dev \
    libpulse-dev \
    libaudio-dev \
    libx11-dev \
    libxext-dev \
    libxrandr-dev \
    libxcursor-dev \
    libxfixes-dev \
    libxi-dev \
    libxss-dev \
    libwayland-dev \
    libxkbcommon-dev \
    libdrm-dev \
    libgbm-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libwebp-dev \
    && rm -rf /var/lib/apt/lists/*

# Linux build stage
FROM base as linux-build

WORKDIR /tmp

# Build SDL3 from the latest stable release
RUN wget https://github.com/libsdl-org/SDL/releases/download/release-3.2.10/SDL3-3.2.10.tar.gz && \
    tar xzf SDL3-3.2.10.tar.gz && \
    cd SDL3-3.2.10 && \
    cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/usr && \
    cmake --build build && \
    cmake --install build && \
    cd .. && \
    rm -rf SDL3-3.2.10 SDL3-3.2.10.tar.gz

# Build SDL3_image from source
RUN git clone --depth 1 -b release-3.2.x https://github.com/libsdl-org/SDL_image.git && \
    cd SDL_image && \
    cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/usr -DSDL3_DIR=/usr/lib/cmake/SDL3 && \
    cmake --build build && \
    cmake --install build && \
    cd .. && \
    rm -rf SDL_image

# Build SDL3_ttf from source
RUN git clone --depth 1 -b release-3.2.x https://github.com/libsdl-org/SDL_ttf.git && \
    cd SDL_ttf && \
    cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/usr -DSDL3_DIR=/usr/lib/cmake/SDL3 && \
    cmake --build build && \
    cmake --install build && \
    cd .. && \
    rm -rf SDL_ttf

# Update library cache and pkg-config paths
RUN ldconfig && \
    echo "/usr/lib/cmake/SDL3" > /etc/ld.so.conf.d/sdl3.conf && \
    echo "/usr/lib/cmake/SDL3_image" >> /etc/ld.so.conf.d/sdl3.conf && \
    echo "/usr/lib/cmake/SDL3_ttf" >> /etc/ld.so.conf.d/sdl3.conf && \
    ldconfig

# Set working directory
WORKDIR /workspace

# Default to Linux build
FROM linux-build

# Set environment variables for CMake to find SDL3
ENV CMAKE_PREFIX_PATH=/usr

# Set the shell to bash
SHELL ["/bin/bash", "-c"]

# Set the entrypoint to bash
ENTRYPOINT ["/bin/bash"] 