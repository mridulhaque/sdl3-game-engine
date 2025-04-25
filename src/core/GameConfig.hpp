#pragma once

#include <string>
#include <filesystem>

namespace Game {
namespace Core {

/**
 * @brief Configuration settings for the game
 * 
 * This class holds all configurable settings for the game.
 * It uses the singleton pattern to ensure consistent configuration across the game.
 */
class GameConfig {
public:
    static GameConfig& getInstance() {
        static GameConfig instance;
        return instance;
    }

    /**
     * @brief Initialize game configuration with default values
     */
    void initialize(const std::string& gameName = "Game",
                   int windowWidth = 800,
                   int windowHeight = 600) {
        this->gameName = gameName;
        this->windowWidth = windowWidth;
        this->windowHeight = windowHeight;
    }

    // Game identity
    const std::string& getGameName() const { return gameName; }
    
    // Window settings
    int getWindowWidth() const { return windowWidth; }
    int getWindowHeight() const { return windowHeight; }
    
    // Asset paths
    std::filesystem::path getAssetsPath() const {
        return std::filesystem::current_path() / "assets";
    }
    
    std::filesystem::path getFontsPath() const {
        return getAssetsPath() / "fonts";
    }
    
    std::filesystem::path getTexturesPath() const {
        return getAssetsPath() / "textures";
    }
    
    std::filesystem::path getSoundsPath() const {
        return getAssetsPath() / "sounds";
    }

private:
    GameConfig() = default;
    GameConfig(const GameConfig&) = delete;
    GameConfig& operator=(const GameConfig&) = delete;

    std::string gameName = "Game";
    int windowWidth = 800;
    int windowHeight = 600;
};

} // namespace Core
} // namespace Game