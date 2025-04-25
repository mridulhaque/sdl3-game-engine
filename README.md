# SDL3 Game Engine

A modern C++ game engine built on top of SDL3, providing a robust foundation for 2D game development. This engine supports both macOS and Linux platforms.

## Features

- Cross-platform support (macOS and Linux)
- Modern C++17 codebase
- SDL3 integration with image and font support
- Docker support for Linux builds
- CMake-based build system
- Asset management system
- Automated development environment setup

## Recommended

- Docker (for Linux builds)
- VSCode with C++ extensions (recommended for development)

## Quick Start

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd sdl3-game-engine
   ```

2. Run the configuration script to set up your development environment:
   ```bash
   ./configure.sh
   ```
   This will:
   - Install all necessary dependencies
   - Set up Docker (on Linux)
   - Install recommended VSCode extensions
   - Verify the installation

3. Build your game:
   ```bash
   ./build.sh --name YourGameName
   ```

## Building the Project

### Native Build

1. Configure and build:
   ```bash
   ./build.sh --name YourGameName
   ```

   Additional options:
   - `-c, --clean`: Clean build directory before building
   - `-t, --type TYPE`: Set build type (Debug/Release) [default: Release]
   - `-i, --install`: Install to dist directory after building
   - `-o, --target-os OS`: Set target OS (linux/macos) [default: current OS]

### Docker Build (Linux only)

To build using Docker:
```bash
./build.sh --name YourGameName --docker
```

## Project Structure

```
sdl3-game-engine/
├── src/            # Source code
│   ├── assets/     # Game assets (images, fonts, etc.)
│   ├── *.cpp       # Source files
│   └── *.hpp       # Header files
├── build/          # Build directory
├── dist/           # Distribution directory
├── CMakeLists.txt  # CMake configuration
├── build.sh        # Build script
├── configure.sh    # Development environment setup script
└── Dockerfile      # Docker configuration
```

## Running the Game

After building, you should run the game from the `dist` directory where the assets are properly installed. To run it:

```bash
./dist/<platform>/YourGameName
```

Note: Do not run the game from the `build` directory as it won't have access to the required assets.

## Development

### Adding New Files

1. Place source files in the `src` directory
2. Place assets in the `src/assets` directory
3. The build system will automatically detect and include new files

### Code Style

The project uses modern C++17 features and follows these guidelines:
- Use smart pointers for memory management
- Follow RAII principles
- Use const correctness
- Prefer references over pointers when possible

## Troubleshooting

### Common Issues

1. **SDL3 not found**
   - Run `./configure.sh` to ensure all dependencies are properly installed
   - On macOS, verify Homebrew installation
   - On Linux, check package installation

2. **Build failures**
   - Try cleaning the build directory: `./build.sh --clean --name YourGameName`
   - Ensure all dependencies are installed by running `./configure.sh`
   - Check compiler version (C++17 support required)

3. **Docker build issues**
   - Run `./configure.sh` to ensure Docker is properly installed and configured
   - Check Docker permissions
   - Verify network connectivity for Docker