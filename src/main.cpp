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

#include <tuple>

int main([[maybe_unused]] int argc, [[maybe_unused]] const char **argv)
{

    spdlog::info("Hello, {}!", "World");

    fmt::print("Hello, from {}\n", "{fmt}");

    constexpr unsigned int kScreenWidth{1024};
    constexpr unsigned int kScreenHeight{768};
    constexpr unsigned int kFramerateLimit{60};
    sf::RenderWindow window(sf::VideoMode(kScreenWidth, kScreenHeight),
                            "ImGui + SFML");
    window.setFramerateLimit(kFramerateLimit);
    std::ignore = ImGui::SFML::Init(window);

    constexpr auto scale_factor{2.0};
    ImGui::GetStyle().ScaleAllSizes(scale_factor);
    ImGui::GetIO().FontGlobalScale = scale_factor;

    bool state{false};
    bool state1{false};
    bool state2{false};
    bool state3{false};
    bool state4{false};
    bool state5{false};
    bool state6{false};
    bool state7{false};
    bool state8{false};
    bool state9{false};
    bool state10{false};

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

        ImGui::Begin("The Plan", &state);
        ImGui::Checkbox("0 : The Plan", &state1);
        ImGui::Checkbox("1 : Getting Started", &state2);
        ImGui::Checkbox("2 : C++ 20 so Far", &state3);
        ImGui::Checkbox("3 : Reading SFML Input States", &state4);
        ImGui::Checkbox("4 : Managing Game State", &state5);
        ImGui::Checkbox("5 : Making Our Game Testable", &state6);
        ImGui::Checkbox("6 : Making Game State Allocator Aware", &state6);
        ImGui::Checkbox("7 : Add Logging to the Game Engine", &state7);
        ImGui::Checkbox("8 : Draw a Game Map", &state8);
        ImGui::Checkbox("9 : log Trees", &state9);
        ImGui::Checkbox("10 : Porting from SFML to SDL", &state10);

        ImGui::End();

        window.clear(sf::Color::Black);
        ImGui::SFML::Render(window);
        window.display();
    }

    ImGui::SFML::Shutdown();

    return 0;
}
