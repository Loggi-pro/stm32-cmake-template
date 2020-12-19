PROJECT(${PROJECT_NAME})
CMAKE_MINIMUM_REQUIRED(VERSION 3.19)
FIND_PACKAGE(CMSIS REQUIRED)
FIND_PACKAGE(STM32HAL COMPONENTS gpio tim pcd pwr adc dma rtc uart i2c flash REQUIRED)
add_stm_executable(${PROJECT_NAME} ${MCU} src/main.cpp)
target_include_directories(${PROJECT_NAME}.elf PUBLIC ${CMAKE_SOURCE_DIR}/src;${CMAKE_SOURCE_DIR}/src/)
add_library(project_options INTERFACE)
target_compile_features(project_options INTERFACE cxx_std_17)
set_project_options(project_options)
add_library(project_warnings INTERFACE)
set_project_warnings(project_warnings)


target_link_libraries(${PROJECT_NAME}.elf PRIVATE project_options project_warnings)
add_cmsis_library(${PROJECT_NAME})
add_hal_library(${PROJECT_NAME})

configure_cpptools(${PROJECT_NAME} ${CPPTOOL_PATH})