##########################################################################
# add_avr_executable
# - IN_VAR: EXECUTABLE_NAME
# Creates targets and dependencies for AVR toolchain, building an
# executable. Calls add_executable with ELF file as target name, so
# any link dependencies need to be using that target, e.g. for
# target_link_libraries(<EXECUTABLE_NAME>.elf ...).
# using global variable SYSTEM_PROCESSOR = stm32|avr
SET(PRINT_SIZE_DIR ${CMAKE_CURRENT_LIST_DIR})
##########################################################################
function (print_size EXECUTABLE_NAME)
	list(APPEND CMAKE_MESSAGE_CONTEXT "print")
	set(OUTPUT_DIR ${EXECUTABLE_OUTPUT_PATH})
	set(elf_file ${EXECUTABLE_NAME}.elf)
	get_target_property(MCU ${EXECUTABLE_NAME} MCU)
	FIND_FILE(PATH_TO_UTILITY size_printer.py
        HINT ${PRINT_SIZE_DIR}
		CMAKE_FIND_ROOT_PATH_BOTH
    )
	#MESSAGE("PATH_TO_UTILITY=${PATH_TO_UTILITY}")
	FIND_FILE(PATH_TO_EZSTACK ezstack.exe
        HINT ${PRINT_SIZE_DIR}
		CMAKE_FIND_ROOT_PATH_BOTH
    )
	#MESSAGE("PATH_TO_EZSTACK=${PATH_TO_EZSTACK}")
	include(FindPythonInterp)
	if (SYSTEM_PROCESSOR STREQUAL stm32)
		STM32_CHIP_GET_PARAMETERS(${MCU} FLASH_SIZE RAM_SIZE CCRAM_SIZE)
		string(REGEX REPLACE "K" "000" FLASH_SIZE_FULL ${FLASH_SIZE})
		string(REGEX REPLACE "K" "000" RAM_SIZE_FULL ${RAM_SIZE})
		set(MAXFLASH --maxflash=${FLASH_SIZE_FULL})
		set(MAXRAM --maxram=${RAM_SIZE_FULL})
	endif()

	if (EXISTS "${PYTHON_EXECUTABLE}" AND EXISTS "${PATH_TO_UTILITY}")
		add_custom_command(
			TARGET ${EXECUTABLE_NAME} POST_BUILD
			COMMAND ${PYTHON_EXECUTABLE} ${PATH_TO_UTILITY} --size=${CMAKE_SIZE} --mcu=${MCU} --elf=${OUTPUT_DIR}/${elf_file} --ezstack=${PATH_TO_EZSTACK} 
			${MAXFLASH} ${MAXRAM}
		)
	else()
		PRINT_SIZE_OF_TARGET(${EXECUTABLE_NAME})
	endif()
	list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction(print_size)

function (print_size_details EXECUTABLE_NAME)
    set(OUTPUT_DIR ${EXECUTABLE_OUTPUT_PATH})
    set(elf_file ${EXECUTABLE_NAME}.elf)
    set(BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR})
    get_target_property(SOURCES ${elf_file} SOURCES)
    #get all sources, and make path to object files
    list(TRANSFORM SOURCES PREPEND ${BUILD_DIR}/CMakeFiles/${elf_file}.dir/)
    list(TRANSFORM SOURCES APPEND ".obj")
    list(TRANSFORM SOURCES REPLACE "\\.\\./" "__/")
    list(TRANSFORM SOURCES REPLACE "\\./" "_/")
    #MESSAGE("OBJECT FILES = ${SOURCES}")
    add_custom_command(TARGET ${EXECUTABLE_NAME}
            POST_BUILD
            COMMAND ${CMAKE_SIZE} ${SOURCES} > ${BUILD_DIR}/size_sources.txt)
    set(PATH_TO_SIZE_UTILITY "${CURRENT_DIR}/../utils")
    add_custom_command(TARGET ${EXECUTABLE_NAME} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} POST_BUILD COMMAND ${PATH_TO_SIZE_UTILITY}/print_size.cmd ${BUILD_DIR}/size_sources.txt)
endfunction()

