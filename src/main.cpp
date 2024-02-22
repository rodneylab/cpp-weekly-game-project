#include <SFML/Graphics/Color.hpp>
#include <SFML/Graphics/RenderWindow.hpp>
#include <SFML/System/Clock.hpp>
#include <SFML/Window/Event.hpp>
#include <SFML/Window/Keyboard.hpp>
#include <SFML/Window/VideoMode.hpp>
#include <fmt/core.h>
#include <imgui-SFML.h>
#include <imgui.h>
#include <spdlog/spdlog.h>

#include <array>
#include <cstddef>
#include <cstdlib>
#include <exception>
#include <iterator>
#include <string>
#include <tuple>

int main([[maybe_unused]] int argc, [[maybe_unused]] const char **argv)
{
    constexpr unsigned int kScreenWidth{1024};
    constexpr unsigned int kScreenHeight{768};
    constexpr unsigned int kFramerateLimit{60};
    sf::RenderWindow window{sf::VideoMode(kScreenWidth, kScreenHeight),
                            "ImGui + SFML"};
    window.setFramerateLimit(kFramerateLimit);
    std::ignore = ImGui::SFML::Init(window);

    constexpr float scale_factor{2.F};
    ImGui::GetStyle().ScaleAllSizes(scale_factor);
    ImGui::GetIO().FontGlobalScale = scale_factor;

    constexpr std::size_t kNumSteps{12};
    std::array<bool, kNumSteps> states{};
    std::array<std::string, kNumSteps> steps{};
    try
    {
        steps = {"Getting Started",
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
    }
    catch (const std::exception &e)
    {
        spdlog::error("Error assigning step names: {}", e.what());
        return EXIT_FAILURE;
    }

    sf::Clock delta_clock;
    while (true)
    {
        for (auto event = sf::Event{}; window.pollEvent(event);)
        {
            ImGui::SFML::ProcessEvent(window, event);

            if (event.type == sf::Event::Closed)
            {
                window.close();
            }
        }

        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Key::Escape))
        {
            break;
        }

        ImGui::SFML::Update(window, delta_clock.restart());

        ImGui::Begin("The Plan");

        int index{0};
        for (const auto &step : steps)
        {
            ImGui::Checkbox(
                fmt::format("{} : {}", index, step).c_str(),
                static_cast<bool *>(std::next(begin(states), index)));
            ++index;
        }

        ImGui::End();

        window.clear(sf::Color::Black);
        ImGui::SFML::Render(window);
        window.display();
    }

    ImGui::SFML::Shutdown();

    return EXIT_SUCCESS;
}
