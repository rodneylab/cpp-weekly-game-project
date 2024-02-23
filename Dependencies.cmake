include(cmake/CPM.cmake)

# Done as a function so that updates to variables like
# CMAKE_CXX_FLAGS don't propagate out to other
# targets
function(cpp_weekly_game_project_setup_dependencies)

  # For each dependency, see if it's
  # already been provided to us by a parent project

  if(NOT TARGET fmtlib::fmtlib)
    cpmaddpackage("gh:fmtlib/fmt#e69e5f977d458f2650bb346dadf2ad30c5320281") # 10.x
  endif()

  if(NOT TARGET spdlog::spdlog)
    cpmaddpackage(
      NAME
      spdlog
      GIT_TAG
      7c02e204c92545f869e2f04edaab1f19fe8b19fd # v1.13.0
      GITHUB_REPOSITORY
      "gabime/spdlog"
      OPTIONS
      "SPDLOG_FMT_EXTERNAL ON")
  endif()

  if(NOT TARGET Catch2::Catch2WithMain)
    cpmaddpackage("gh:catchorg/Catch2#05e10dfccc28c7f973727c54f850237d07d5e10f") # v3.5.2
  endif()

  if(NOT TARGET CLI11::CLI11)
    cpmaddpackage("gh:CLIUtils/CLI11#f4d0731cebb123ff0ace712c099dffbcd2c58e5a") # v2.4.1
  endif()

  if(NOT TARGET ftxui::screen)
      cpmaddpackage("gh:ArthurSonzogni/FTXUI#cdf28903a7781f97ba94d30b79c3a4b0c97ccce7") # v5.0.0
  endif()

  if(NOT TARGET tools::tools)
    cpmaddpackage("gh:lefticus/tools#update_build_system")
  endif()

  cpmaddpackage("gh:SFML/SFML#5a74cf33e92008920bfd04698dbd6a7733e1c269") # 2.6.x

  FetchContent_Declare(
    ImGui
    GIT_REPOSITORY https://github.com/ocornut/imgui
    GIT_TAG 5b6f03213dde8c6ca9bea4707321cca79f2265ec) # v1.90.3
  FetchContent_MakeAvailable(ImGui)
  FetchContent_GetProperties(ImGui SOURCE_DIR IMGUI_DIR)

  add_library(
    imgui STATIC
    ${imgui_SOURCE_DIR}/imgui.cpp
    #${imgui_SOURCE_DIR}/imgui_demo.cpp # optionally comment this out
    ${imgui_SOURCE_DIR}/imgui_draw.cpp
    ${imgui_SOURCE_DIR}/imgui_widgets.cpp
    ${imgui_SOURCE_DIR}/imgui_tables.cpp)
  target_include_directories(imgui INTERFACE ${imgui_SOURCE_DIR})
  #target_compile_definitions(imgui PUBLIC -DIMGUI_DISABLE_OBSOLETE_FUNCTIONS) # optional imgui setting
  #set_target_properties(imgui PROPERTIES FOLDER third-party) # optional IDE dir

  set(IMGUI_SFML_FIND_SFML OFF)
  set(IMGUI_DIR ${imgui_SOURCE_DIR})
  cpmaddpackage("gh:SFML/imgui-sfml#bf9023d1bc6ec422769559a5eff60bd00597354f") # 2.6.x
endfunction()
