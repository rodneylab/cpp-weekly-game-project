include(cmake/SystemLink.cmake)
include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)

macro(cpp_weekly_game_project_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    set(SUPPORTS_ASAN ON)
  endif()
endmacro()

macro(cpp_weekly_game_project_setup_options)
  option(cpp_weekly_game_project_ENABLE_HARDENING "Enable hardening" ON)
  option(cpp_weekly_game_project_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    cpp_weekly_game_project_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    cpp_weekly_game_project_ENABLE_HARDENING
    OFF)

  cpp_weekly_game_project_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR cpp_weekly_game_project_PACKAGING_MAINTAINER_MODE)
    option(cpp_weekly_game_project_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(cpp_weekly_game_project_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(cpp_weekly_game_project_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(cpp_weekly_game_project_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(cpp_weekly_game_project_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(cpp_weekly_game_project_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(cpp_weekly_game_project_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(cpp_weekly_game_project_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(cpp_weekly_game_project_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(cpp_weekly_game_project_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(cpp_weekly_game_project_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(cpp_weekly_game_project_ENABLE_PCH "Enable precompiled headers" OFF)
    option(cpp_weekly_game_project_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(cpp_weekly_game_project_ENABLE_IPO "Enable IPO/LTO" ON)
    option(cpp_weekly_game_project_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(cpp_weekly_game_project_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(cpp_weekly_game_project_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(cpp_weekly_game_project_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(cpp_weekly_game_project_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(cpp_weekly_game_project_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(cpp_weekly_game_project_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(cpp_weekly_game_project_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(cpp_weekly_game_project_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    #option(cpp_weekly_game_project_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    #option(cpp_weekly_game_project_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(cpp_weekly_game_project_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(cpp_weekly_game_project_ENABLE_PCH "Enable precompiled headers" OFF)
    option(cpp_weekly_game_project_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      cpp_weekly_game_project_ENABLE_IPO
      cpp_weekly_game_project_WARNINGS_AS_ERRORS
      cpp_weekly_game_project_ENABLE_USER_LINKER
      cpp_weekly_game_project_ENABLE_SANITIZER_ADDRESS
      cpp_weekly_game_project_ENABLE_SANITIZER_LEAK
      cpp_weekly_game_project_ENABLE_SANITIZER_UNDEFINED
      cpp_weekly_game_project_ENABLE_SANITIZER_THREAD
      cpp_weekly_game_project_ENABLE_SANITIZER_MEMORY
      cpp_weekly_game_project_ENABLE_UNITY_BUILD
      cpp_weekly_game_project_ENABLE_CLANG_TIDY
      cpp_weekly_game_project_ENABLE_CPPCHECK
      cpp_weekly_game_project_ENABLE_COVERAGE
      cpp_weekly_game_project_ENABLE_PCH
      cpp_weekly_game_project_ENABLE_CACHE)
  endif()

  cpp_weekly_game_project_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED
     AND (cpp_weekly_game_project_ENABLE_SANITIZER_ADDRESS
          OR cpp_weekly_game_project_ENABLE_SANITIZER_THREAD
          OR cpp_weekly_game_project_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(cpp_weekly_game_project_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(cpp_weekly_game_project_global_options)
  if(cpp_weekly_game_project_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    cpp_weekly_game_project_enable_ipo()
  endif()

  cpp_weekly_game_project_supports_sanitizers()

  if(cpp_weekly_game_project_ENABLE_HARDENING AND cpp_weekly_game_project_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN
       OR cpp_weekly_game_project_ENABLE_SANITIZER_UNDEFINED
       OR cpp_weekly_game_project_ENABLE_SANITIZER_ADDRESS
       OR cpp_weekly_game_project_ENABLE_SANITIZER_THREAD
       OR cpp_weekly_game_project_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message(
      "${cpp_weekly_game_project_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${cpp_weekly_game_project_ENABLE_SANITIZER_UNDEFINED}"
    )
    cpp_weekly_game_project_enable_hardening(cpp_weekly_game_project_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(cpp_weekly_game_project_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(cpp_weekly_game_project_warnings INTERFACE)
  add_library(cpp_weekly_game_project_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  cpp_weekly_game_project_set_project_warnings(
    cpp_weekly_game_project_warnings
    ${cpp_weekly_game_project_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(cpp_weekly_game_project_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    configure_linker(cpp_weekly_game_project_options)
  endif()

  include(cmake/Sanitizers.cmake)
  cpp_weekly_game_project_enable_sanitizers(
    cpp_weekly_game_project_options
    ${cpp_weekly_game_project_ENABLE_SANITIZER_ADDRESS}
    ${cpp_weekly_game_project_ENABLE_SANITIZER_LEAK}
    ${cpp_weekly_game_project_ENABLE_SANITIZER_UNDEFINED}
    ${cpp_weekly_game_project_ENABLE_SANITIZER_THREAD}
    ${cpp_weekly_game_project_ENABLE_SANITIZER_MEMORY})

  set_target_properties(cpp_weekly_game_project_options PROPERTIES UNITY_BUILD
                                                                   ${cpp_weekly_game_project_ENABLE_UNITY_BUILD})

  if(cpp_weekly_game_project_ENABLE_PCH)
    target_precompile_headers(
      cpp_weekly_game_project_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(cpp_weekly_game_project_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    cpp_weekly_game_project_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(cpp_weekly_game_project_ENABLE_CLANG_TIDY)
    cpp_weekly_game_project_enable_clang_tidy(cpp_weekly_game_project_options
                                              ${cpp_weekly_game_project_WARNINGS_AS_ERRORS})
  endif()

  if(cpp_weekly_game_project_ENABLE_CPPCHECK)
    cpp_weekly_game_project_enable_cppcheck(
      ${cpp_weekly_game_project_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(cpp_weekly_game_project_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    cpp_weekly_game_project_enable_coverage(cpp_weekly_game_project_options)
  endif()

  if(cpp_weekly_game_project_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(cpp_weekly_game_project_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(cpp_weekly_game_project_ENABLE_HARDENING AND NOT cpp_weekly_game_project_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN
       OR cpp_weekly_game_project_ENABLE_SANITIZER_UNDEFINED
       OR cpp_weekly_game_project_ENABLE_SANITIZER_ADDRESS
       OR cpp_weekly_game_project_ENABLE_SANITIZER_THREAD
       OR cpp_weekly_game_project_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    cpp_weekly_game_project_enable_hardening(cpp_weekly_game_project_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
