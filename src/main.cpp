#include "config.hpp"

#include <CLI/App.hpp>
#include <CLI/CLI.hpp> // NOLINT misc-include-cleaner // needed for linking
#include <CLI/Error.hpp>
#include <CLI/Validators.hpp>
#include <SFML/Graphics/Color.hpp>
#include <SFML/Graphics/RenderWindow.hpp>
#include <SFML/System/Clock.hpp>
#include <SFML/Window/Event.hpp>
#include <SFML/Window/Joystick.hpp>
#include <SFML/Window/Keyboard.hpp>
#include <SFML/Window/VideoMode.hpp>
#include <fmt/core.h>
#include <imgui-SFML.h>
#include <imgui.h>
#include <spdlog/common.h>
#include <spdlog/spdlog.h>

#include <array>
#include <cstddef>
#include <cstdlib>
#include <stdexcept>
#include <string>
#include <tuple>

int main(int argc, char **argv)
{
    spdlog::set_level(spdlog::level::debug);

    constexpr unsigned int kDefaultScreenWidth{1'024};
    constexpr unsigned int kMinScreenWidth{640};
    constexpr unsigned int kMaxScreenWidth{1'920};
    constexpr unsigned int kDefaultScreenHeight{768};
    constexpr unsigned int kMinScreenHeight{320};
    constexpr unsigned int kMaxScreenHeight{1'080};
    constexpr float kDefaultScaleFactor{2.F};
    constexpr float kMinScaleFactor{0.5F};
    constexpr float kMaxScaleFactor{5.F};
    unsigned int screen_width{kDefaultScreenWidth};
    unsigned int screen_height{kDefaultScreenHeight};
    float scale_factor{kDefaultScaleFactor};

    try
    {
        CLI::App app{"C++ Weekly Game"};
        try
        {
            argv = app.ensure_utf8(argv);
            app.set_help_flag("--help",
                              std::string{"Print this help message and exit"});
            app.set_version_flag(
                "--version",
                fmt::format(
                    "{}.{}.{}",
                    cpp_weekly_game_project::cmake::project_version_major,
                    cpp_weekly_game_project::cmake::project_version_minor,
                    cpp_weekly_game_project::cmake::project_version_patch));
            app.add_option("-w,--width",
                           screen_width,
                           fmt::format("Screen width (default is {})",
                                       kDefaultScreenWidth))
                ->check(CLI::Bound(kMinScreenWidth, kMaxScreenWidth));
            app.add_option("-h,--height",
                           screen_height,
                           fmt::format("Screen height (default is {})",
                                       kDefaultScreenHeight))
                ->check(CLI::Bound(kMinScreenHeight, kMaxScreenHeight));
            app.add_option("-s,--scale-factor", scale_factor, "Scale factor")
                ->check(CLI::Bound(kMinScaleFactor, kMaxScaleFactor));

            CLI11_PARSE(app, argc, argv);
        }
        catch (CLI::CallForHelp &exception)
        {
            spdlog::info("Displaying help: {}", exception.what());
            return app.exit(exception);
        }
        catch (CLI::Success & /* exception */)
        {
            spdlog::info("Parsed CLI parameters successfully");
        }
        catch (CLI::ParseError &exception)
        {
            spdlog::error("Error parsing CLI parameters: {}", exception.what());
            return app.exit(exception);
        }
        catch (CLI::Error &exception)
        {
            spdlog::error("CLI Error: {}", exception.what());
            return app.exit(exception);
        }
    }
    catch (...)
    {
        spdlog::error("Unexpected exception");
        return EXIT_FAILURE;
    }

    constexpr unsigned int kFramerateLimit{60};
    sf::RenderWindow window{sf::VideoMode(screen_width, screen_height),
                            "ImGui + SFML"};
    window.setFramerateLimit(kFramerateLimit);
    std::ignore = ImGui::SFML::Init(window);

    ImGui::GetStyle().ScaleAllSizes(scale_factor);
    ImGui::GetIO().FontGlobalScale = scale_factor;

    constexpr std::array steps{"Getting Started",
                               "Finding Errors as soon as Possible",
                               "Handling Command Line Parameters",
                               "C++ 20 so far",
                               "Reading SFML Input States",
                               "Managing Game State",
                               "Making our Game Testable",
                               "Making Game State Allocator Aware",
                               "Add Logging to the Game Engine",
                               "Draw a Game Map",
                               "Dialog Trees",
                               "Porting from SFML to SDL"};
    std::array<bool, steps.size()> states{};

    sf::Clock delta_clock;
    while (window.isOpen())
    {
        for (auto event = sf::Event{}; window.pollEvent(event);)
        {
            ImGui::SFML::ProcessEvent(window, event);

            if (event.type == sf::Event::Closed)
            {
                window.close();
            }
            else if (event.type == sf::Event::JoystickConnected ||
                     event.type == sf::Event::JoystickDisconnected)
            {
                if (sf::Joystick::isConnected(0))
                {
                    spdlog::debug(
                        "Joystick {} {} {} with {} buttons connected",
                        sf::Joystick::getIdentification(0).name.toAnsiString(),
                        sf::Joystick::getIdentification(0).vendorId,
                        sf::Joystick::getIdentification(0).productId,
                        sf::Joystick::getButtonCount(0));
                }
            }
        }

        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Key::Escape))
        {
            break;
        }

        ImGui::SFML::Update(window, delta_clock.restart());

        ImGui::Begin("The Plan");

        try
        {
            for (size_t index{0}; auto &state : states)
            {
                ImGui::Checkbox(
                    fmt::format("{} : {}", index, steps.at(index)).c_str(),
                    &state);
                ++index;
            }
        }
        catch (std::out_of_range &exception)
        {
            spdlog::error("Error updating steps: {}", exception.what());
            return EXIT_FAILURE;
        }

        ImGui::End();

        window.clear(sf::Color::Black);
        ImGui::SFML::Render(window);
        window.display();
    }

    ImGui::SFML::Shutdown();

    return EXIT_SUCCESS;
}
