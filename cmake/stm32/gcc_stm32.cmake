#SET(CMAKE_MODULE_PATH ${STM32_CMAKE_DIR} ${CMAKE_MODULE_PATH})

set(CMAKE_SYSTEM_NAME Generic)  #REQUIRE FOR CROSSCOMPILING FOR LINKER
SET(CMAKE_SYSTEM_PROCESSOR stm32)
set(CMAKE_CROSSCOMPILING 1)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)


SET(TARGET_TRIPLET "arm-none-eabi")

FILE(TO_CMAKE_PATH "${TOOLCHAIN_PATH}" TOOLCHAIN_PATH)
SET(TOOLCHAIN_BIN_DIR "${TOOLCHAIN_PATH}/bin")
SET(TOOLCHAIN_INC_DIR "${TOOLCHAIN_PATH}/${TARGET_TRIPLET}/include")
SET(TOOLCHAIN_LIB_DIR "${TOOLCHAIN_PATH}/${TARGET_TRIPLET}/lib")
SET(TOOLCHAIN_BIN_COMMON_DIR "${TOOLCHAIN_PATH}/${TARGET_TRIPLET}/bin")
INCLUDE_DIRECTORIES(
	 "${TOOLCHAIN_PATH}/${TARGET_TRIPLET}/include "
)

IF (WIN32)
    SET(TOOL_EXECUTABLE_SUFFIX ".exe")
ELSE()
    SET(TOOL_EXECUTABLE_SUFFIX "")
ENDIF()

IF(${CMAKE_VERSION} VERSION_LESS 3.6.0)
    INCLUDE(CMakeForceCompiler)
    CMAKE_FORCE_C_COMPILER("${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc${TOOL_EXECUTABLE_SUFFIX}" GNU)
    CMAKE_FORCE_CXX_COMPILER("${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-g++${TOOL_EXECUTABLE_SUFFIX}" GNU)
ELSE()
	#SET(CMAKE_C_COMPILER_WORKS true)
	#SET(CMAKE_CXX_COMPILER_WORKS true)
    #SET(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
    SET(CMAKE_C_COMPILER "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc${TOOL_EXECUTABLE_SUFFIX}" CACHE PATH "CMAKE_C_COMPILER" FORCE)
    SET(CMAKE_CXX_COMPILER "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-g++${TOOL_EXECUTABLE_SUFFIX}" CACHE PATH "CMAKE_CXX_COMPILER" FORCE)
ENDIF()
set(CMAKE_AR "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-ar${TOOL_EXECUTABLE_SUFFIX}" CACHE FILEPATH "Archiver" )
SET(CMAKE_CXX_COMPILER_AR "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-ar${TOOL_EXECUTABLE_SUFFIX}" GNU)

SET(CMAKE_ASM_COMPILER "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc${TOOL_EXECUTABLE_SUFFIX}")
SET(CMAKE_OBJCOPY "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-objcopy${TOOL_EXECUTABLE_SUFFIX}" CACHE INTERNAL "objcopy tool")
SET(CMAKE_OBJDUMP "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-objdump${TOOL_EXECUTABLE_SUFFIX}" CACHE INTERNAL "objdump tool")
SET(CMAKE_SIZE "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-size${TOOL_EXECUTABLE_SUFFIX}" CACHE INTERNAL "size tool")
SET(CMAKE_DEBUGER "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gdb${TOOL_EXECUTABLE_SUFFIX}" CACHE INTERNAL "debuger")
SET(CMAKE_CPPFILT "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-c++filt${TOOL_EXECUTABLE_SUFFIX}" CACHE INTERNAL "C++filt")
set(CMAKE_SYSTEM_INCLUDE_PATH "${TOOLCHAIN_PATH}")
set(CMAKE_SYSTEM_INCLUDE_PATH "${TOOLCHAIN_INC_DIR}")
set(CMAKE_SYSTEM_LIBRARY_PATH "${TOOLCHAIN_LIB_DIR}")

define_property(TARGET PROPERTY MCU BRIEF_DOCS "Name of mcu" FULL_DOCS "Name of mcu") #add mcu property to target
set(SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR})
