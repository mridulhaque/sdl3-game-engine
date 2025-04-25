#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to detect the operating system
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        *)          echo "unknown";;
    esac
}

# Build configuration
BUILD_TYPE="Release"
BUILD_DIR="build"
DIST_DIR="dist"
CLEAN_BUILD=false
USE_DOCKER=false
INSTALL=false
GAME_NAME=""
TARGET_OS=$(detect_os)  # Default to current OS

# Function to print usage
print_usage() {
    echo -e "${BLUE}Usage: $0 [options] --name GAME_NAME${NC}"
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -c, --clean         Clean build directory before building"
    echo "  -d, --docker        Use Docker for building"
    echo "  -t, --type TYPE     Set build type (Debug/Release) [default: Release]"
    echo "  -i, --install       Install to dist directory after building"
    echo "  -n, --name NAME     Set the game name (required)"
    echo "  -o, --target-os OS  Set target OS (linux/macos) [default: current OS]"
    echo "      --platform OS   Alias for --target-os"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_usage
            exit 0
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -d|--docker)
            USE_DOCKER=true
            shift
            ;;
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -i|--install)
            INSTALL=true
            shift
            ;;
        -n|--name)
            GAME_NAME="$2"
            shift 2
            ;;
        -o|--target-os|--platform)
            TARGET_OS="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            print_usage
            exit 1
            ;;
    esac
done

# Check if game name is provided
if [ -z "$GAME_NAME" ]; then
    echo -e "${RED}Error: Game name is required${NC}"
    print_usage
    exit 1
fi

# Validate target OS
if [ "$TARGET_OS" != "linux" ] && [ "$TARGET_OS" != "macos" ]; then
    echo -e "${RED}Error: Invalid target OS. Must be 'linux' or 'macos'${NC}"
    exit 1
fi

# Function to get number of CPU cores
get_cpu_count() {
    if [ "$(detect_os)" = "macos" ]; then
        sysctl -n hw.ncpu
    else
        nproc
    fi
}

# Function to check dependencies
check_dependencies() {
    local os=$(detect_os)
    local missing_deps=()

    if [ "$os" = "macos" ]; then
        # Check for brew
        if ! command -v brew &> /dev/null; then
            echo -e "${YELLOW}Warning: Homebrew not found. You may need to install it to get SDL3.${NC}"
        fi
        # Check for SDL3
        if ! pkg-config --exists sdl3 &> /dev/null; then
            echo -e "${RED}SDL3 not found. Please install it using: brew install sdl3${NC}"
            exit 1
        fi
    elif [ "$os" = "linux" ]; then
        # Check for essential build tools
        for cmd in cmake make g++; do
            if ! command -v $cmd &> /dev/null; then
                missing_deps+=($cmd)
            fi
        done
        if [ ${#missing_deps[@]} -ne 0 ]; then
            echo -e "${RED}Missing dependencies: ${missing_deps[*]}${NC}"
            echo "On Ubuntu/Debian, run: sudo apt-get install build-essential cmake"
            exit 1
        fi
        # Check for SDL3
        if ! pkg-config --exists sdl3 &> /dev/null; then
            echo -e "${RED}SDL3 not found. Please install it using: sudo apt-get install libsdl3-dev${NC}"
            exit 1
        fi
    fi
}

# Function to clean build directory
clean_build() {
    if [ -d "$BUILD_DIR" ]; then
        echo -e "${YELLOW}Cleaning build directory...${NC}"
        rm -rf "$BUILD_DIR"
    fi
    if [ -d "$DIST_DIR" ]; then
        echo -e "${YELLOW}Cleaning dist directory...${NC}"
        rm -rf "$DIST_DIR"
    fi
}

# Function to build natively
build_native() {
    local os=$(detect_os)
    echo -e "${GREEN}Building ${GAME_NAME} natively for ${os}...${NC}"
    check_dependencies
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    cmake -DCMAKE_BUILD_TYPE="$BUILD_TYPE" -DGAME_NAME="$GAME_NAME" ..
    make -j$(get_cpu_count)
    cd ..
}

# Function to build using Docker
build_docker() {
    echo -e "${GREEN}Building ${GAME_NAME} using Docker for Linux...${NC}"
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Docker not found. Please install Docker first.${NC}"
        exit 1
    fi
    
    # Build the Docker image if it doesn't exist
    if ! docker image inspect sdl3-game-builder &> /dev/null; then
        docker build -t sdl3-game-builder .
    fi
    
    # Create build directory if it doesn't exist
    mkdir -p "$BUILD_DIR"
    
    # Run the build in Docker with the workspace mounted
    docker run --rm \
        -v "$(pwd):/workspace" \
        sdl3-game-builder \
        -c "mkdir -p $BUILD_DIR && \
            cd $BUILD_DIR && \
            cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DGAME_NAME=$GAME_NAME .. && \
            make -j\$(nproc)"
}

# Function to install to dist directory
install_to_dist() {
    local os=$TARGET_OS
    echo -e "${GREEN}Installing ${GAME_NAME} to dist/${os} directory...${NC}"
    
    if [ "$USE_DOCKER" = true ] && [ "$TARGET_OS" = "linux" ]; then
        # Create dist directory if it doesn't exist
        mkdir -p "dist/${os}"
        
        # Copy the binary and assets from the Docker container
        docker run --rm \
            -v "$(pwd):/workspace" \
            sdl3-game-builder \
            -c "cd /workspace/build && \
                make install && \
                cp -r assets /workspace/dist/${os}/"
    else
        cd "$BUILD_DIR"
        make install
        cd ..
    fi
    
    echo -e "${GREEN}Installation complete! Game is available in ./dist/${os}/${NC}"
}

# Main build process
echo -e "${GREEN}Starting build process for ${GAME_NAME}...${NC}"
echo -e "${GREEN}Target OS: ${TARGET_OS}${NC}"

# Clean build directory if requested
if [ "$CLEAN_BUILD" = true ]; then
    clean_build
fi

# Determine build method
if [ "$USE_DOCKER" = true ] && [ "$TARGET_OS" = "linux" ]; then
    build_docker
else
    if [ "$USE_DOCKER" = true ] && [ "$TARGET_OS" = "macos" ]; then
        echo -e "${YELLOW}Warning: Docker builds not supported for macOS target. Using native build instead.${NC}"
    fi
    build_native
fi

# Install if requested
if [ "$INSTALL" = true ]; then
    install_to_dist
fi

# Verify build success
if [ -f "$BUILD_DIR/$GAME_NAME" ]; then
    chmod +x "$BUILD_DIR/$GAME_NAME"
    echo -e "${GREEN}Build complete! Binary is available at ./$BUILD_DIR/$GAME_NAME${NC}"
else
    echo -e "${RED}Error: Build failed - binary not found${NC}"
    exit 1
fi 