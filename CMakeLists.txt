cmake_minimum_required(VERSION 3.15)

# Game name is required
if(NOT DEFINED GAME_NAME)
    message(FATAL_ERROR "GAME_NAME is required. Please specify -DGAME_NAME=YourGameName")
endif()

project(${GAME_NAME} VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set default build type to Release if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
endif()

# Detect platform
if(APPLE)
    set(PLATFORM "macos")
elseif(UNIX AND NOT APPLE)
    set(PLATFORM "linux")
else()
    set(PLATFORM "unknown")
endif()

# Set installation prefix to platform-specific dist directory
set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/dist/${PLATFORM} CACHE PATH "Installation prefix" FORCE)

# Find SDL3 and its available components
if(APPLE)
    # On macOS, we need to find SDL3 using pkg-config
    find_package(PkgConfig REQUIRED)
    
    # Add Homebrew's Cellar pkg-config paths
    set(ENV{PKG_CONFIG_PATH} "/opt/homebrew/Cellar/sdl3/3.2.10/lib/pkgconfig")
    pkg_check_modules(SDL3 REQUIRED sdl3)
    
    set(ENV{PKG_CONFIG_PATH} "/opt/homebrew/Cellar/sdl3_image/3.2.4/lib/pkgconfig")
    pkg_check_modules(SDL3_IMAGE REQUIRED sdl3-image)
    
    set(ENV{PKG_CONFIG_PATH} "/opt/homebrew/Cellar/sdl3_ttf/3.2.2/lib/pkgconfig")
    pkg_check_modules(SDL3_TTF REQUIRED sdl3-ttf)
    
    # Set explicit library paths
    set(SDL3_LIBRARY "/opt/homebrew/Cellar/sdl3/3.2.10/lib/libSDL3.0.dylib")
    set(SDL3_IMAGE_LIBRARY "/opt/homebrew/Cellar/sdl3_image/3.2.4/lib/libSDL3_image.0.2.4.dylib")
    set(SDL3_TTF_LIBRARY "/opt/homebrew/Cellar/sdl3_ttf/3.2.2/lib/libSDL3_ttf.0.2.2.dylib")
    
    # Set include directories
    set(SDL3_INCLUDE_DIRS "/opt/homebrew/Cellar/sdl3/3.2.10/include")
    set(SDL3_IMAGE_INCLUDE_DIRS "/opt/homebrew/Cellar/sdl3_image/3.2.4/include")
    set(SDL3_TTF_INCLUDE_DIRS "/opt/homebrew/Cellar/sdl3_ttf/3.2.2/include")
else()
    # On Linux, use the standard find_package with hints
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
    list(APPEND CMAKE_PREFIX_PATH "/usr/lib/cmake/SDL3")
    
    find_package(SDL3 REQUIRED)
    find_package(SDL3_image REQUIRED)
    find_package(SDL3_ttf REQUIRED)
    
    if(NOT TARGET SDL3::SDL3_image)
        add_library(SDL3::SDL3_image SHARED IMPORTED)
        set_target_properties(SDL3::SDL3_image PROPERTIES
            IMPORTED_LOCATION "/usr/lib/aarch64-linux-gnu/libSDL3_image.so"
            INTERFACE_INCLUDE_DIRECTORIES "/usr/include/SDL3"
        )
    endif()
    
    if(NOT TARGET SDL3::SDL3_ttf)
        add_library(SDL3::SDL3_ttf SHARED IMPORTED)
        set_target_properties(SDL3::SDL3_ttf PROPERTIES
            IMPORTED_LOCATION "/usr/lib/aarch64-linux-gnu/libSDL3_ttf.so"
            INTERFACE_INCLUDE_DIRECTORIES "/usr/include/SDL3"
        )
    endif()
endif()

# Add source files
file(GLOB_RECURSE SOURCES "src/*.cpp")
file(GLOB_RECURSE HEADERS "src/*.hpp" "src/*.h")

# Create executable
add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS})

# Configure compiler warnings
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    # Enable essential warnings
    target_compile_options(${PROJECT_NAME} PRIVATE
        -Wall
        -Wextra
        -Wpedantic
        
        # Disable specific warnings
        -Wno-old-style-cast     # Disable warnings about C-style casts (used in SDL)
        -Wno-unused-parameter   # Disable warnings about unused parameters
        -Wno-shadow            # Disable warnings about shadowing
        
        # Keep important warnings
        -Werror=return-type    # Treat missing return values as errors
        -Wuninitialized       # Warn about uninitialized variables
        -Wunused-variable     # Warn about unused variables
    )
endif()

# Link SDL3 and its available components
if(APPLE)
    # On macOS, link using explicit library paths and include directories
    target_link_libraries(${PROJECT_NAME} PRIVATE 
        ${SDL3_LIBRARY}
        ${SDL3_IMAGE_LIBRARY}
        ${SDL3_TTF_LIBRARY}
    )
    target_include_directories(${PROJECT_NAME} PRIVATE 
        ${SDL3_INCLUDE_DIRS}
        ${SDL3_IMAGE_INCLUDE_DIRS}
        ${SDL3_TTF_INCLUDE_DIRS}
    )
else()
    # On Linux, use the standard target-based linking
    target_link_libraries(${PROJECT_NAME} PRIVATE 
        SDL3::SDL3
        SDL3::SDL3_image
        SDL3::SDL3_ttf
    )
endif()

target_include_directories(${PROJECT_NAME} PRIVATE src)

# Copy assets to build directory
file(COPY src/assets DESTINATION ${CMAKE_BINARY_DIR})

# Install rules
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION .
    BUNDLE DESTINATION .
)

# Install assets
install(DIRECTORY src/assets
    DESTINATION assets
    PATTERN "CMakeLists.txt" EXCLUDE
) 