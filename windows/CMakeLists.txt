cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "tapsilat_plugin")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "tapsilat_plugin")

add_library(${PLUGIN_NAME} SHARED
  "tapsilat_plugin.cpp"
  "tapsilat_plugin_c_api.cpp"
)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_STANDARD 17
  CXX_STANDARD_REQUIRED YES
  OUTPUT_NAME "tapsilat"
)

target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

flutter_install_plugin_headers(${PLUGIN_NAME}
  "tapsilat_plugin.h"
  "tapsilat_plugin_c_api.h"
)
