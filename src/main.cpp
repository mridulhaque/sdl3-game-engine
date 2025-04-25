#include <SDL3/SDL.h>
#include <iostream>
#include "graphics/Window.hpp"
#include "graphics/Text.hpp"
#include "utils/FontManager.hpp"
#include "core/GameConfig.hpp"

using namespace Game;

int main(int argc, char* argv[]) {
    try {
        if (!SDL_Init(SDL_INIT_VIDEO)) {
            std::cerr << "Failed to initialize SDL: " << SDL_GetError() << std::endl;
            return EXIT_FAILURE;
        }

        // Initialize font manager
        Game::Utils::FontManager::getInstance().initialize();

        // Initialize game config
        Game::Core::GameConfig::getInstance().initialize("DX-Ball", 800, 600);

        // Create window and text
        Game::Graphics::Window window("DX-Ball", 800, 600);
        Game::Graphics::Text text(window.getRenderer(), "OpenSans-Regular.ttf", 36);

        // Set up text
        SDL_Color textColor = {255, 255, 255, 255}; // White color
        text.setText("Hello World!", textColor);

        // Main game loop
        bool running = true;
        SDL_Event event;

        while (running) {
            // Handle events
            while (SDL_PollEvent(&event)) {
                if (event.type == SDL_EVENT_QUIT) {
                    running = false;
                }
            }

            // Clear screen
            window.setClearColor(0, 0, 0, 255);
            window.clear();

            // Center and render text
            int windowWidth, windowHeight;
            window.getSize(windowWidth, windowHeight);

            int textWidth, textHeight;
            text.getDimensions(textWidth, textHeight);

            float textX = (windowWidth - textWidth) / 2.0f;
            float textY = (windowHeight - textHeight) / 2.0f;
            text.render(textX, textY);

            // Present rendered content
            window.present();
        }

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        SDL_Quit();
        return 1;
    }

    SDL_Quit();
    return 0;
} 