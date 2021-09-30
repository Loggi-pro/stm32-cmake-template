CMAKE_MINIMUM_REQUIRED(VERSION 3.19)
PROJECT(stm32-template)
FIND_PACKAGE(CMSIS REQUIRED)
FIND_PACKAGE(STM32HAL COMPONENTS gpio tim pcd pwr adc dma rtc uart i2c flash REQUIRED)

if (VOID_LIB_PATH)
    FIND_PACKAGE(Void REQUIRED)
endif()

#configure
set(MCU STM32F303xC)
set(F_CPU 72000000)

#create executable
#if VOID_LIB_PATH - use main_void.cpp instead of main.cpp
add_stm_executable(stm32-template ${MCU} src/main$<$<BOOL:VOID_LIB_PATH>:_void>.cpp)
#target_compile_definitions(stm32-template.elf PUBLIC F_CPU=${F_CPU})
target_include_directories(stm32-template.elf PUBLIC ${CMAKE_SOURCE_DIR}/src;${CMAKE_SOURCE_DIR}/src/)

#setup options
add_library(project_options INTERFACE)
target_compile_features(project_options INTERFACE cxx_std_17)
set_project_options(project_options)
add_library(project_warnings INTERFACE)
set_project_warnings(project_warnings)

#link target with options
target_link_libraries(stm32-template.elf PRIVATE project_options project_warnings)
add_cmsis_library(stm32-template)
add_hal_library(stm32-template)

#add void library
#configure void library
configure_void_library(NAME void-stm32 MCU ${MCU} F_CPU ${F_CPU})
target_link_libraries(void-stm32 PRIVATE libcmsis) #depends from cmsis
#link target with options
target_link_libraries(stm32-template.elf PRIVATE void-stm32 project_options project_warnings)
#end void lib

print_size_details(stm32-template)
#configure cpptools for better syntax highlight for vscode
#CPPTOOL_PATH - path to generated file c_cpp_properties.json
#configure_cpptools(TARGET template_project PATH ${CPPTOOL_PATH})