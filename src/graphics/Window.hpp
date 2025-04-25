#pragma once

#include <SDL3/SDL.h>
#include <memory>
#include "../core/GameConfig.hpp"

namespace Game {
namespace Graphics {

/**
 * @brief Manages the game window and renderer
 */
class Window {
public:
    /**
     * @brief Create a new window using game configuration
     * @throw std::runtime_error if window creation fails
     */
    Window(const std::string& title, int width, int height);
    
    ~Window() = default;
    
    Window(const Window&) = delete;
    Window& operator=(const Window&) = delete;
    Window(Window&&) = default;
    Window& operator=(Window&&) = default;

    /**
     * @brief Get the SDL renderer
     * @return Raw pointer to the SDL renderer
     */
    SDL_Renderer* getRenderer() const { return renderer.get(); }

    /**
     * @brief Get the window dimensions
     * @param width Output parameter for window width
     * @param height Output parameter for window height
     */
    void getSize(int& width, int& height) const;

    /**
     * @brief Clear the window with the current draw color
     */
    void clear();

    /**
     * @brief Present the rendered content to the screen
     */
    void present();

    /**
     * @brief Set the color for clear operations
     * @param r Red component (0-255)
     * @param g Green component (0-255)
     * @param b Blue component (0-255)
     * @param a Alpha component (0-255)
     */
    void setClearColor(Uint8 r, Uint8 g, Uint8 b, Uint8 a);

private:
    struct SDLWindowDeleter {
        void operator()(SDL_Window* w) { SDL_DestroyWindow(w); }
    };
    
    struct SDLRendererDeleter {
        void operator()(SDL_Renderer* r) { SDL_DestroyRenderer(r); }
    };
    
    std::unique_ptr<SDL_Window, SDLWindowDeleter> window;
    std::unique_ptr<SDL_Renderer, SDLRendererDeleter> renderer;
};

} // namespace Graphics
} // namespace Game