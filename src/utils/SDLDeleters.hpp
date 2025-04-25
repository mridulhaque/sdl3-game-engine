#pragma once

#include <SDL3/SDL.h>
#include <SDL3_ttf/SDL_ttf.h>
#include <memory>

namespace Game {
namespace Utils {

/**
 * @brief Custom deleters for SDL resources
 * 
 * This namespace contains all the custom deleters used for SDL smart pointers
 * to ensure proper cleanup of SDL resources.
 */
namespace SDLDeleters {

/**
 * @brief Custom deleter for SDL_Window
 */
struct WindowDeleter {
    void operator()(SDL_Window* window) const {
        if (window) {
            SDL_DestroyWindow(window);
        }
    }
};

/**
 * @brief Custom deleter for SDL_Renderer
 */
struct RendererDeleter {
    void operator()(SDL_Renderer* renderer) const {
        if (renderer) {
            SDL_DestroyRenderer(renderer);
        }
    }
};

/**
 * @brief Custom deleter for SDL_Surface
 */
struct SurfaceDeleter {
    void operator()(SDL_Surface* surface) const {
        if (surface) {
            SDL_DestroySurface(surface);
        }
    }
};

/**
 * @brief Custom deleter for SDL_Texture
 */
struct TextureDeleter {
    void operator()(SDL_Texture* texture) const {
        if (texture) {
            SDL_DestroyTexture(texture);
        }
    }
};

/**
 * @brief Custom deleter for TTF_Font
 */
struct FontDeleter {
    void operator()(TTF_Font* font) const {
        if (font) {
            TTF_CloseFont(font);
        }
    }
};

} // namespace SDLDeleters

// Type aliases for commonly used SDL smart pointers
using WindowPtr = std::unique_ptr<SDL_Window, SDLDeleters::WindowDeleter>;
using RendererPtr = std::unique_ptr<SDL_Renderer, SDLDeleters::RendererDeleter>;
using SurfacePtr = std::unique_ptr<SDL_Surface, SDLDeleters::SurfaceDeleter>;
using TexturePtr = std::unique_ptr<SDL_Texture, SDLDeleters::TextureDeleter>;
using FontPtr = std::unique_ptr<TTF_Font, SDLDeleters::FontDeleter>;

} // namespace Utils
} // namespace DXBall
 