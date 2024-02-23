add_subdirectory(sample_library)
add_subdirectory(ftxui_sample)

add_executable(game main.cpp)
target_link_libraries(game PRIVATE cpp_weekly_game_project::cpp_weekly_game_project_options
                                   cpp_weekly_game_project::cpp_weekly_game_project_warnings)
target_include_directories(game PUBLIC "${CMAKE_BINARY_DIR}/configured_files/include/internal_use_only")
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

target_link_libraries(
  game
  PRIVATE CLI11
          fmt::fmt
          spdlog::spdlog
          sfml-graphics
          ImGui-SFML::ImGui-SFML)
