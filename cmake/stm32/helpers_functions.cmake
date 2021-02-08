

##########################################################################
# PRINT_SIZE_OF_TARGET (DONT RENAME)
# - IN_VAR: EXECUTABLE_NAME-> NAME OF TARGET
# - IN_VAR: MCU -> For compatibility purpose (for avr cmake)
# Standart postbuild task for printing size of target.
# This function used by print_size.cmake utility (for stm and avr) as default (if gen_size.py utility is not finded )
##########################################################################
FUNCTION(PRINT_SIZE_OF_TARGET EXECUTABLE_NAME)
    set(OUTPUT_DIR ${EXECUTABLE_OUTPUT_PATH})
    set(elf_file ${EXECUTABLE_NAME}.elf)
    set(BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR})
    add_custom_command(TARGET ${EXECUTABLE_NAME} 
        POST_BUILD
        COMMAND ${CMAKE_SIZE} ${OUTPUT_DIR}/${elf_file} > ${BUILD_DIR}/size.txt)
        STM32_CHIP_GET_PARAMETERS(${MCU} FLASH_SIZE RAM_SIZE CCRAM_SIZE
    )
    string(REGEX REPLACE "K" "000" FLASH_SIZE_FULL ${FLASH_SIZE})
    string(REGEX REPLACE "K" "000" RAM_SIZE_FULL ${RAM_SIZE})

    set(PATH_TO_SIZE_UTILITY "${CURRENT_DIR}/../utils")
    add_custom_command(TARGET ${EXECUTABLE_NAME} WORKING_DIRECTORY ${PATH_TO_SIZE_UTILITY} POST_BUILD COMMAND ${PATH_TO_SIZE_UTILITY}/print_size.cmd ${BUILD_DIR}/size.txt)
ENDFUNCTION()
FUNCTION(PRINT_SIZE_ALL_SOURCES EXECUTABLE_NAME)
    set(OUTPUT_DIR ${EXECUTABLE_OUTPUT_PATH})
    set(elf_file ${EXECUTABLE_NAME}.elf)
    set(BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR})
    get_target_property(SOURCES ${elf_file} SOURCES)
    #get all sources, and make path to object files
    list(TRANSFORM SOURCES PREPEND ${BUILD_DIR}/CMakeFiles/${elf_file}.dir/)
    list(TRANSFORM SOURCES  APPEND ".obj")
    #MESSAGE("OBJECT FILES = ${SOURCES}")
    add_custom_command(TARGET ${EXECUTABLE_NAME}
            POST_BUILD
            COMMAND ${CMAKE_SIZE} ${SOURCES} > ${BUILD_DIR}/size_sources.txt)
    set(PATH_TO_SIZE_UTILITY "${CURRENT_DIR}/../utils")
    add_custom_command(TARGET ${EXECUTABLE_NAME} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} POST_BUILD COMMAND ${PATH_TO_SIZE_UTILITY}/print_size.cmd ${BUILD_DIR}/size_sources.txt)
ENDFUNCTION()

FUNCTION(STM32_SET_FLASH_PARAMS TARGET FLASH_SIZE RAM_SIZE)
    if(NOT STM32_FLASH_ORIGIN)
        set(STM32_FLASH_ORIGIN "0x08000000")
    endif()

    if(NOT STM32_RAM_ORIGIN)
        set(STM32_RAM_ORIGIN "0x20000000")
    endif()

    if(NOT STM32_MIN_STACK_SIZE)
        set(STM32_MIN_STACK_SIZE "0x200")
    endif()

    if(NOT STM32_MIN_HEAP_SIZE)
        set(STM32_MIN_HEAP_SIZE "0")
    endif()

    if(NOT STM32_CCRAM_ORIGIN)
        set(STM32_CCRAM_ORIGIN "0x10000000")
    endif()
    string(REGEX REPLACE "\\.[^.]*$" "" TARGET_WITHOUT_EXT ${TARGET})
    SET(LINK_SCRIPT_PATH ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_WITHOUT_EXT}_flash.ld)
    if(NOT STM32_LINKER_SCRIPT)
        MESSAGE(STATUS "No linker script specified, generating default")
        INCLUDE(stm32_linker)
        FILE(WRITE ${LINK_SCRIPT_PATH} ${STM32_LINKER_SCRIPT_TEXT})
    else()
    CONFIGURE_FILE(${STM32_LINKER_SCRIPT} ${LINK_SCRIPT_PATH})
    endif()

    GET_TARGET_PROPERTY(TARGET_LD_OPTIONS ${TARGET} LINK_OPTIONS)
    if(TARGET_LD_OPTIONS)
        set(TARGET_LD_OPTIONS "-T${LINK_SCRIPT_PATH} ${TARGET_LD_OPTIONS}")
    else()
        set(TARGET_LD_OPTIONS "-T${LINK_SCRIPT_PATH}")
    endif()
    SET_TARGET_PROPERTIES(${TARGET} 
    PROPERTIES 
        LINK_OPTIONS ${TARGET_LD_OPTIONS}
    )
ENDFUNCTION()

FUNCTION(STM32_SET_TARGET_PROPERTIES TARGET MCU)
    STM32_CHIP_SET_DEFINITIONS(${TARGET} ${MCU})
    STM32_CHIP_GET_PARAMETERS(${MCU} STM32_FLASH_SIZE STM32_RAM_SIZE STM32_CCRAM_SIZE)
    if((NOT STM32_FLASH_SIZE) OR (NOT STM32_RAM_SIZE))
        MESSAGE(FATAL_ERROR "Unknown chip: ${MCU}")
    endif()
    STM32_SET_FLASH_PARAMS(${TARGET} ${STM32_FLASH_SIZE} ${STM32_RAM_SIZE})
    MESSAGE(STATUS "${MCU} has ${STM32_FLASH_SIZE}b of flash memory and ${STM32_RAM_SIZE}b of RAM")
ENDFUNCTION()


FUNCTION(STM32_ADD_CHIP_PROPERTIES TARGET MCU)
        STM32_CHIP_GET_OPTIONS(${MCU}
                CHIP_C_OPTIONS
                CHIP_CXX_OPTIONS
                CHIP_ASM_OPTIONS
                CHIP_EXE_LINKER_OPTIONS
                CHIP_MODULE_LINKER_OPTIONS
                CHIP_SHARED_LINKER_OPTIONS)
        foreach(C_COMPILE_OPTIONS ${CHIP_C_OPTIONS})
        target_compile_options( ${TARGET} PUBLIC $<$<COMPILE_LANGUAGE:C>:${C_COMPILE_OPTIONS}>)
        endforeach()

        foreach(CXX_COMPILE_OPTIONS ${CHIP_CXX_OPTIONS})
        target_compile_options( ${TARGET} PUBLIC $<$<COMPILE_LANGUAGE:CXX>:${CXX_COMPILE_OPTIONS}>)
        endforeach()

        foreach(CXX_COMPILE_OPTIONS ${CHIP_ASM_OPTIONS})
        target_compile_options( ${TARGET} PUBLIC $<$<COMPILE_LANGUAGE:ASM>:${CXX_COMPILE_OPTIONS}>)
        endforeach()
        #add link flags
        target_link_options(${TARGET} PUBLIC ${CHIP_EXE_LINKER_OPTIONS})
ENDFUNCTION()

FUNCTION(STM32_SET_HSE_VALUE TARGET STM32_HSE_VALUE)
    GET_TARGET_PROPERTY(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    if(TARGET_DEFS)
        set(TARGET_DEFS "HSE_VALUE=${STM32_HSE_VALUE};${TARGET_DEFS}")
    else()
        set(TARGET_DEFS "HSE_VALUE=${STM32_HSE_VALUE}")
    endif()
    SET_TARGET_PROPERTIES(${TARGET} PROPERTIES COMPILE_DEFINITIONS "${TARGET_DEFS}")
ENDFUNCTION()





MACRO(STM32_GENERATE_LIBRARIES NAME MCU SOURCES LIBRARIES)
    STM32_CHIP_GET_FAMILY(${MCU} FAMILY)
    STRING(TOLOWER ${FAMILY} FAMILY_LOWER)
    STM32_CHIP_GET_TYPES(CHIP_TYPES)
    FOREACH(CHIP_TYPE ${CHIP_TYPES})
        STRING(TOLOWER ${CHIP_TYPE} CHIP_TYPE_LOWER)
        LIST(APPEND ${LIBRARIES} ${NAME}_${FAMILY_LOWER}_${CHIP_TYPE_LOWER})
        ADD_LIBRARY(${NAME}_${FAMILY_LOWER}_${CHIP_TYPE_LOWER} ${SOURCES})
        STM32_CHIP_SET_DEFINITIONS(${NAME}_${FAMILY_LOWER}_${CHIP_TYPE_LOWER} ${MCU})
    ENDFOREACH()
ENDMACRO()
