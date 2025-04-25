#pragma once
#include <SDL3/SDL.h>
#include <SDL3_ttf/SDL_ttf.h>
#include <string>
#include "../utils/SDLDeleters.hpp"
#include "../utils/FontManager.hpp"

namespace Game {
namespace Graphics {

/**
 * @brief Manages text rendering using SDL_ttf
 */
class Text {
public:
    /**
     * @brief Create a new text object
     * @param renderer SDL renderer to use for rendering
     * @param fontName Name of the font file to use
     * @param fontSize Size of the font in points
     * @throw std::runtime_error if text creation fails
     */
    Text(SDL_Renderer* renderer, const std::string& fontName, int fontSize);

    /**
     * @brief Set the text content and color
     * @param text Text to render
     * @param color Color to use for rendering
     * @throw std::runtime_error if text rendering fails
     */
    void setText(const std::string& text, SDL_Color color);

    /**
     * @brief Render the text at the specified position
     * @param x X coordinate
     * @param y Y coordinate
     */
    void render(float x, float y);

    /**
     * @brief Get the dimensions of the rendered text
     * @param width Output parameter for text width
     * @param height Output parameter for text height
     */
    void getDimensions(int& width, int& height) const;

private:
    SDL_Renderer* renderer;
    Utils::FontPtr font;
    Utils::TexturePtr texture;
    int width = 0;
    int height = 0;
};

} // namespace Graphics
} // namespace Game
