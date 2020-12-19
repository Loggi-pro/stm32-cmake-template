
#INPUT: ${VOID_LIB_PATH} -> path to void/platform_specific.h
#SET(CMAKE_MODULE_PATH ${CURRENT_DIR})
if (NOT EXISTS ${VOID_LIB_PATH})
	message(FATAL_ERROR "CMake error: Directory VOID_LIB_PATH for void library not specified: ${VOID_LIB_PATH}")
endif()
STRING(REGEX REPLACE "\\\\" "/" VOID_LIB_PATH ${VOID_LIB_PATH}) 
#ARGS: ${TARGET}
function(add_void_library target)
	list(APPEND CMAKE_MESSAGE_CONTEXT "void")
	set(new_target void)
	add_library(${new_target} ${VOID_LIB_PATH}/void/time/dateutils.cpp)
	get_target_property(MCU ${target} MCU)
	get_target_property(TARGET_NAME ${target} OUTPUT_NAME)

	copy_target_properites_to(${TARGET_NAME} PRIVATE ${new_target})
	target_compile_features(${new_target} PRIVATE cxx_std_17)
	
	
	
	if (SYSTEM_PROCESSOR STREQUAL stm32) 
		STM32_CHIP_GET_ARCH(${MCU} MCU_TYPE) 
		LIST(APPEND DEFINES _ARM)
		LIST(APPEND DEFINES __CORTEX_${MCU_TYPE}__)
	elseif(SYSTEM_PROCESSOR STREQUAL avr)
		LIST(APPEND DEFINES _AVR)
	elseif(SYSTEM_PROCESSOR STREQUAL stm8)
		LIST(APPEND DEFINES _STM8)
	endif()
	target_compile_definitions(${new_target}  PUBLIC ${DEFINES})
	target_compile_options (${new_target}  PUBLIC $<$<COMPILE_LANGUAGE:CXX>:-includevoid/platform_specific.h>)
	target_include_directories(${new_target} PUBLIC ${VOID_LIB_PATH})
	target_link_libraries(${TARGET_NAME} PUBLIC ${new_target})
	#
	MESSAGE(VERBOSE "Add sources: ${VOID_LIB_PATH}/void/time/dateutils.cpp")
    MESSAGE(VERBOSE "Add include directories: ${VOID_LIB_PATH}")
	MESSAGE(VERBOSE "Add force includes: void/platform_specific.h")
	MESSAGE(VERBOSE "Add defines: ${DEFINES}")
	list(POP_BACK CMAKE_MESSAGE_CONTEXT)
	
endfunction()

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(VOID DEFAULT_MSG)