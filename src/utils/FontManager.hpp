#pragma once

#include <SDL3/SDL.h>
#include <SDL3_ttf/SDL_ttf.h>
#include <string>
#include <vector>
#include <filesystem>
#include <stdexcept>
#include <algorithm>
#include <unordered_map>
#include "SDLDeleters.hpp"

namespace Game {
namespace Utils {

/**
 * @brief Manages font loading and caching for the game
 * 
 * This class is responsible for:
 * - Loading and managing fonts from the assets directory
 * - Caching font locations for quick access
 * - Providing a singleton interface for font management
 */
class FontManager {
public:
    /**
     * @brief Get the singleton instance of FontManager
     * @return Reference to the FontManager instance
     */
    static FontManager& getInstance() {
        static FontManager instance;
        return instance;
    }

    /**
     * @brief Initialize the font manager and SDL_ttf
     * @throw std::runtime_error if initialization fails
     */
    void initialize() {
        if (!TTF_Init()) {
            throw std::runtime_error("SDL_ttf could not initialize! SDL_Error: " + std::string(SDL_GetError()));
        }
        initialized = true;
        updateFontCache();
    }

    /**
     * @brief Load a font with the specified name and size
     * @param fontName Name of the font file to load
     * @param fontSize Size of the font in points
     * @return Smart pointer to the loaded font
     * @throw std::runtime_error if font cannot be loaded
     */
    FontPtr loadFont(const std::string& fontName, int fontSize) {
        if (!initialized) {
            throw std::runtime_error("FontManager not initialized!");
        }

        auto fontPath = findFontPath(fontName);
        if (fontPath.empty()) {
            updateFontCache();
            fontPath = findFontPath(fontName);
            if (fontPath.empty()) {
                throw std::runtime_error("Could not find font: " + fontName);
            }
        }

        FontPtr font(TTF_OpenFont(fontPath.c_str(), fontSize));
        if (!font) {
            throw std::runtime_error("Failed to load font! SDL_Error: " + std::string(SDL_GetError()));
        }

        return font;
    }

    /**
     * @brief Get a list of all available fonts
     * @return Vector of font filenames
     */
    std::vector<std::string> getAvailableFonts() const {
        std::vector<std::string> fontNames;
        for (const auto& pair : fontCache) {
            fontNames.push_back(pair.first);
        }
        return fontNames;
    }

    /**
     * @brief Shutdown the font manager and cleanup resources
     */
    void shutdown() {
        if (initialized) {
            TTF_Quit();
            initialized = false;
        }
    }

    ~FontManager() {
        shutdown();
    }

private:
    FontManager() = default;
    bool initialized = false;
    std::unordered_map<std::string, std::string> fontCache;

    /**
     * @brief Update the cache of available fonts
     */
    void updateFontCache() {
        fontCache.clear();
        
        const std::vector<std::filesystem::path> baseSearchPaths = {
            std::filesystem::current_path() / "assets",
            std::filesystem::current_path() / "src" / "assets",
            std::filesystem::current_path().parent_path() / "assets",
            std::filesystem::current_path().parent_path() / "src" / "assets"
        };

        const std::vector<std::string> fontExtensions = {
            ".ttf", ".otf", ".ttc"
        };

        for (const auto& basePath : baseSearchPaths) {
            if (!std::filesystem::exists(basePath)) {
                continue;
            }

            try {
                for (const auto& entry : std::filesystem::recursive_directory_iterator(basePath)) {
                    if (!entry.is_regular_file()) {
                        continue;
                    }

                    auto extension = entry.path().extension().string();
                    std::transform(extension.begin(), extension.end(), extension.begin(), ::tolower);

                    if (std::find(fontExtensions.begin(), fontExtensions.end(), extension) != fontExtensions.end()) {
                        fontCache[entry.path().filename().string()] = entry.path().string();
                    }
                }
            } catch (const std::filesystem::filesystem_error& e) {
                SDL_LogWarn(SDL_LOG_CATEGORY_APPLICATION, 
                    "Error searching directory %s: %s", 
                    basePath.string().c_str(), 
                    e.what());
            }
        }
    }

    /**
     * @brief Find the path to a font file
     * @param fontName Name of the font file to find
     * @return Full path to the font file, or empty string if not found
     */
    std::string findFontPath(const std::string& fontName) const {
        auto it = fontCache.find(fontName);
        return (it != fontCache.end()) ? it->second : "";
    }

    FontManager(const FontManager&) = delete;
    FontManager& operator=(const FontManager&) = delete;
};

} // namespace Utils
} // namespace DXBall
