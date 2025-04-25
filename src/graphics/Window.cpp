#include "Window.hpp"

namespace Game {
namespace Graphics {

Window::Window(const std::string& title, int width, int height) {
    window.reset(SDL_CreateWindow(title.c_str(), width, height, SDL_WINDOW_RESIZABLE));
    if (!window) {
        throw std::runtime_error("Failed to create window: " + std::string(SDL_GetError()));
    }

    renderer.reset(SDL_CreateRenderer(window.get(), nullptr));
    if (!renderer) {
        throw std::runtime_error("Failed to create renderer: " + std::string(SDL_GetError()));
    }
}

void Window::getSize(int& width, int& height) const {
    SDL_GetWindowSize(window.get(), &width, &height);
}

void Window::clear() {
    SDL_RenderClear(renderer.get());
}

void Window::present() {
    SDL_RenderPresent(renderer.get());
}

void Window::setClearColor(Uint8 r, Uint8 g, Uint8 b, Uint8 a) {
    SDL_SetRenderDrawColor(renderer.get(), r, g, b, a);
}

} // namespace Graphics
} // namespace Game 