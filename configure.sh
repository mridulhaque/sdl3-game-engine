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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install dependencies on Ubuntu/Debian
install_ubuntu_deps() {
    echo -e "${BLUE}Installing dependencies for Ubuntu/Debian...${NC}"
    
    # Check if running with sudo
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}This script needs sudo privileges to install packages.${NC}"
        sudo -v
    fi

    echo -e "${GREEN}Updating package lists...${NC}"
    sudo apt-get update

    echo -e "${GREEN}Installing build essentials and tools...${NC}"
    sudo apt-get install -y \
        build-essential \
        cmake \
        ninja-build \
        pkg-config \
        git \
        gcc \
        g++ \
        gdb

    echo -e "${GREEN}Installing Docker dependencies...${NC}"
    # Remove any conflicting packages first
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        sudo apt-get remove -y $pkg 2>/dev/null || true
    done

    # Install prerequisites
    sudo apt-get install -y ca-certificates curl

    # Set up Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update

    echo -e "${GREEN}Installing Docker Engine and related packages...${NC}"
    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    # Check if Docker is installed and running
    if ! systemctl is-active --quiet docker; then
        echo -e "${GREEN}Starting Docker service...${NC}"
        sudo systemctl start docker
    fi

    # Add user to docker group
    if ! groups $USER | grep -q docker; then
        echo -e "${GREEN}Adding user to docker group...${NC}"
        sudo usermod -aG docker $USER
        echo -e "${YELLOW}Please log out and back in for Docker group changes to take effect.${NC}"
    fi

    # Check if Docker installation is successful
    if docker run --rm hello-world &>/dev/null; then
        echo -e "${GREEN}Docker installation successful!${NC}"
    else
        echo -e "${RED}Docker installation verification failed. Please check the error messages above.${NC}"
        return 1
    fi

    # If Docker is requested with additional components
    if [ "$1" = "--with-docker" ]; then
        echo -e "${GREEN}Installing Docker Compose...${NC}"
        # Docker Compose is now included in docker-compose-plugin

        echo -e "${GREEN}Installing VSCode C++ extensions...${NC}"
        if command_exists code; then
            code --install-extension ms-vscode.cpptools
            code --install-extension ms-vscode.cmake-tools
        else
            echo -e "${YELLOW}VSCode not found. Please install VSCode extensions manually:${NC}"
            echo "1. C/C++ (ms-vscode.cpptools)"
            echo "2. CMake Tools (ms-vscode.cmake-tools)"
        fi
    fi
}

# Function to install dependencies on macOS
install_macos_deps() {
    echo -e "${BLUE}Installing dependencies for macOS...${NC}"

    # Check if Homebrew is installed
    if ! command_exists brew; then
        echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo -e "${GREEN}Installing build tools...${NC}"
    brew install \
        cmake \
        ninja \
        pkg-config \
        gcc

    echo -e "${GREEN}Installing SDL3 libraries...${NC}"
    brew install sdl3 sdl3_ttf sdl3_image

    echo -e "${GREEN}Installing VSCode C++ extensions...${NC}"
    if command_exists code; then
        code --install-extension ms-vscode.cpptools
        code --install-extension ms-vscode.cmake-tools
    else
        echo -e "${YELLOW}VSCode not found. Please install VSCode extensions manually:${NC}"
        echo "1. C/C++ (ms-vscode.cpptools)"
        echo "2. CMake Tools (ms-vscode.cmake-tools)"
    fi
}

# Function to verify installation
verify_installation() {
    echo -e "${BLUE}Verifying installation...${NC}"
    local missing_deps=()
    local os=$(detect_os)

    # Check build tools
    for cmd in cmake ninja pkg-config git gcc g++; do
        if ! command_exists "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done

    # Check SDL3 installation based on OS
    if [ "$os" = "macos" ]; then
        # Check Homebrew packages
        if ! brew list sdl3 &>/dev/null; then
            missing_deps+=("sdl3")
        fi
        if ! brew list sdl3_ttf &>/dev/null; then
            missing_deps+=("sdl3_ttf")
        fi
        if ! brew list sdl3_image &>/dev/null; then
            missing_deps+=("sdl3_image")
        fi

        # Verify pkg-config paths
        if ! pkg-config --exists sdl3; then
            echo -e "${YELLOW}Warning: SDL3 pkg-config file not found. You may need to set PKG_CONFIG_PATH.${NC}"
        fi
    else
        # Linux verification using pkg-config
        if ! pkg-config --exists sdl3; then
            missing_deps+=("libsdl3-dev")
        fi
        if ! pkg-config --exists sdl3_ttf; then
            missing_deps+=("libsdl3-ttf-dev")
        fi
        if ! pkg-config --exists sdl3_image; then
            missing_deps+=("libsdl3-image-dev")
        fi
    fi

    if [ ${#missing_deps[@]} -eq 0 ]; then
        echo -e "${GREEN}All dependencies are installed successfully!${NC}"
        return 0
    else
        echo -e "${RED}Missing dependencies: ${missing_deps[*]}${NC}"
        return 1
    fi
}

# Function to print usage
print_usage() {
    echo -e "${BLUE}Usage: $0 [options]${NC}"
    echo "Options:"
    echo "  -h, --help          Show this help message"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            print_usage
            exit 1
            ;;
    esac
done

# Main script
echo -e "${BLUE}Configuring development environment...${NC}"

# Detect OS
OS=$(detect_os)
echo -e "${GREEN}Detected operating system: $OS${NC}"

# Install dependencies based on OS
case $OS in
    "linux")
        install_ubuntu_deps
        ;;
    "macos")
        install_macos_deps
        ;;
    *)
        echo -e "${RED}Unsupported operating system: $OS${NC}"
        echo "This script supports Ubuntu/Debian Linux and macOS."
        exit 1
        ;;
esac

# Verify installation
verify_installation

echo -e "${BLUE}Configuration complete!${NC}"
echo -e "${GREEN}You can now build your project using:${NC}"
echo "  ./build.sh --clean --install --name your_game_name" 