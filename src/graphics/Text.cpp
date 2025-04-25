#include "Text.hpp"
#include <stdexcept>

namespace Game {
namespace Graphics {

Text::Text(SDL_Renderer* renderer, const std::string& fontName, int fontSize)
    : renderer(renderer) {
    font = Game::Utils::FontManager::getInstance().loadFont(fontName, fontSize);
}

void Text::setText(const std::string& text, SDL_Color color) {
    Utils::SurfacePtr surface(TTF_RenderText_Blended(font.get(), text.c_str(), text.length(), color));
    if (!surface) {
        throw std::runtime_error("Failed to render text surface: " + std::string(SDL_GetError()));
    }

    texture.reset(SDL_CreateTextureFromSurface(renderer, surface.get()));
    if (!texture) {
        throw std::runtime_error("Failed to create texture from text surface: " + std::string(SDL_GetError()));
    }

    width = surface->w;
    height = surface->h;
}

void Text::render(float x, float y) {
    SDL_FRect destRect = {
        x,
        y,
        static_cast<float>(width),
        static_cast<float>(height)
    };
    SDL_RenderTexture(renderer, texture.get(), nullptr, &destRect);
}

void Text::getDimensions(int& outWidth, int& outHeight) const {
    outWidth = width;
    outHeight = height;
}

} // namespace Graphics
} // namespace Game