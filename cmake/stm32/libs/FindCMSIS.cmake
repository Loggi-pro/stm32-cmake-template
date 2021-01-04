if (NOT EXISTS ${STM32Cube_DIR})
	message(FATAL_ERROR "CMake error: Directory STM32Cube_DIR for CMSIS library not specified: ${STM32Cube_DIR}")
endif()
STRING(REGEX REPLACE "\\\\" "/" STM32Cube_DIR ${STM32Cube_DIR}) 
ENABLE_LANGUAGE(ASM)


function(generate_startup_file TARGET_NAME FAMILY FILENAME OUT_FILEPATH STM32Cube_DIR)
    #find template for hal_conf file
    list(APPEND CMAKE_MESSAGE_CONTEXT "config")
    STRING(TOLOWER ${FAMILY} STM32_FAMILY_LOWER)

    #find file in sources
    #get list of sources
    get_target_property(sources_fullpath ${TARGET_NAME} SOURCES)
    foreach(file_path ${sources_fullpath})
        get_filename_component(filename ${file_path} NAME)
        list(APPEND sources ${filename})
    endforeach()
    #find by name
    MESSAGE(DEBUG "Scan sources: ${sources}")
    list(FIND sources ${FILENAME} startup_file_exist)
    if (startup_file_exist GREATER_EQUAL 0)
        #get fullpath
        list(GET sources_fullpath ${startup_file_exist} RESULT)
        MESSAGE(DEBUG "Startup file already exist: ${RESULT}")
        list(POP_BACK CMAKE_MESSAGE_CONTEXT)
        return()
    endif()
    #find in library
    MESSAGE(DEBUG "Scan cmsis")

    SET(startup_src_file SRC_FILE-NOTFOUND)
    FIND_FILE(startup_src_file ${FILENAME}
        PATH_SUFFIXES src stm32${FAMILY_LOWER} cmsis
        HINTS ${STM32Cube_DIR}/Drivers/CMSIS/Device/ST/STM32${FAMILY}xx/Source/Templates/gcc/
        CMAKE_FIND_ROOT_PATH_BOTH
    )



    if (EXISTS ${startup_src_file})
        MESSAGE(DEBUG "Startup file found: ${startup_src_file}")
    else()
        MESSAGE(DEBUG "Startup file not found")
        list(POP_BACK CMAKE_MESSAGE_CONTEXT)
        return()
    endif()

    #try to find path to save file
    set(src_folder ${include_dirs})
    set(save_path ${CMAKE_SOURCE_DIR}/startup)
    set(RESULT ${save_path}/${FILENAME})
    MESSAGE(DEBUG "Write at path: ${save_path}")
    #write file
    file(READ ${startup_src_file} filedata)
    file(WRITE  ${save_path}/${FILENAME} "${filedata}")
    SET(${OUT_FILEPATH} ${RESULT} PARENT_SCOPE)
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()


#Use MCU PROPERTY OF TARGET
function(add_cmsis_library TARGET)
    list(APPEND CMAKE_MESSAGE_CONTEXT "cmsis")
    get_target_property(TARGET_NAME ${TARGET} OUTPUT_NAME)
    get_target_property(MCU ${TARGET} MCU)
    STM32_CHIP_GET_FAMILY(${MCU} FAMILY)
    STM32_CHIP_GET_TYPE(${MCU} CHIP_TYPE)
    STRING(TOLOWER ${CHIP_TYPE} CHIP_TYPE_LOWER)
    STM32_CHIP_GET_CODE(${MCU} CHIP_CODE)

    #get headers
    SET(CMSIS_COMMON_HEADERS
        arm_common_tables.h
        arm_const_structs.h
        arm_math.h
        core_cmFunc.h
        core_cmInstr.h
        core_cmSimd.h
    )
    SET(CMSIS_HEADER_TO_FORCE_INCLUDE '')
    IF(FAMILY STREQUAL "F1")
        IF(NOT STM32Cube_DIR)
            SET(STM32Cube_DIR "/opt/STM32Cube_FW_F1_V1.2.0")
            MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
        ENDIF()
        LIST(APPEND CMSIS_COMMON_HEADERS core_cm3.h)
        SET(CMSIS_HEADER_TO_FORCE_INCLUDE stm32f1xx.h)
        SET(CMSIS_DEVICE_HEADERS ${CMSIS_HEADER_TO_FORCE_INCLUDE} system_stm32f1xx.h)
        SET(CMSIS_DEVICE_SOURCES system_stm32f1xx.c)
    ELSEIF(FAMILY STREQUAL "F2")
        IF(NOT STM32Cube_DIR)
            SET(STM32Cube_DIR "/opt/STM32Cube_FW_F2_V1.1.1")
            MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
        ENDIF()

        STRING(REGEX REPLACE "^(2[01]7).[BCDEFG]" "\\1" STM32_DEVICE_NUM ${CHIP_TYPE})
        SET(CMSIS_STARTUP_SOURCE startup_stm32f${STM32_DEVICE_NUM}xx.s)

        LIST(APPEND CMSIS_COMMON_HEADERS core_cm4.h)
        SET(CMSIS_HEADER_TO_FORCE_INCLUDE stm32f2xx.h)
        SET(CMSIS_DEVICE_HEADERS ${CMSIS_HEADER_TO_FORCE_INCLUDE} system_stm32f2xx.h)
        SET(CMSIS_DEVICE_SOURCES system_stm32f2xx.c)
    ELSEIF(FAMILY STREQUAL "F3")
        IF(NOT STM32Cube_DIR)
            SET(STM32Cube_DIR "/opt/STM32Cube_FW_F3_V1.6.0")
            MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
        ENDIF()

        STRING(REGEX REPLACE "^(3..).(.)" "\\1x\\2" STM32_STARTUP_NAME ${CHIP_CODE})
        STRING(TOLOWER ${STM32_STARTUP_NAME} STM32_STARTUP_NAME_LOWER)	 
        STRING(REGEX REPLACE "^3...(.)" "\\1" STM32_SIZE_CODE ${STM32_STARTUP_NAME_LOWER})
        if (STM32_SIZE_CODE STREQUAL "b")  #case for xb cpu
        STRING(REGEX REPLACE "^(3..).(.)" "\\1xc" STM32_STARTUP_NAME_LOWER ${STM32_STARTUP_NAME_LOWER})
        endif()
        SET(CMSIS_STARTUP_SOURCE startup_stm32f${STM32_STARTUP_NAME_LOWER}.s)
        
       

        LIST(APPEND CMSIS_COMMON_HEADERS core_cm4.h)
        SET(CMSIS_HEADER_TO_FORCE_INCLUDE stm32f3xx.h)
        SET(CMSIS_DEVICE_HEADERS ${CMSIS_HEADER_TO_FORCE_INCLUDE} system_stm32f3xx.h)
        SET(CMSIS_DEVICE_SOURCES system_stm32f3xx.c)
    ELSEIF(FAMILY STREQUAL "F4")
        IF(NOT STM32Cube_DIR)
            SET(STM32Cube_DIR "/opt/STM32Cube_FW_F4_V1.8.0")
            MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
        ENDIF()

        LIST(APPEND CMSIS_COMMON_HEADERS core_cm4.h)
        SET(CMSIS_HEADER_TO_FORCE_INCLUDE stm32f4xx.h)
        SET(CMSIS_DEVICE_HEADERS ${CMSIS_HEADER_TO_FORCE_INCLUDE} system_stm32f4xx.h)
        SET(CMSIS_DEVICE_SOURCES system_stm32f4xx.c)
    ELSEIF(FAMILY STREQUAL "F7")
        IF(NOT STM32Cube_DIR)
            SET(STM32Cube_DIR "/opt/STM32Cube_FW_F7_V1.3.0")
            MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
        ENDIF()

        LIST(APPEND CMSIS_COMMON_HEADERS core_cm7.h)
        SET(CMSIS_HEADER_TO_FORCE_INCLUDE stm32f7xx.h)
        SET(CMSIS_DEVICE_HEADERS ${CMSIS_HEADER_TO_FORCE_INCLUDE} system_stm32f7xx.h)
        SET(CMSIS_DEVICE_SOURCES system_stm32f7xx.c)
    ELSEIF(FAMILY STREQUAL "F0")
        IF(NOT STM32Cube_DIR)
            SET(STM32Cube_DIR "/opt/STM32Cube_FW_F0_V1.4.0")
            MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
        ENDIF()

        LIST(APPEND CMSIS_COMMON_HEADERS core_cm3.h)
        SET(CMSIS_HEADER_TO_FORCE_INCLUDE stm32f0xx.h)
        SET(CMSIS_DEVICE_HEADERS ${CMSIS_HEADER_TO_FORCE_INCLUDE} system_stm32f0xx.h)
        SET(CMSIS_DEVICE_SOURCES system_stm32f0xx.c)
    ELSEIF(FAMILY STREQUAL "L0")
        IF(NOT STM32Cube_DIR)
            SET(STM32Cube_DIR "/opt/STM32Cube_FW_L0_V1.7.0")
            MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
        ENDIF()

        LIST(APPEND CMSIS_COMMON_HEADERS core_cm0.h)
        SET(CMSIS_HEADER_TO_FORCE_INCLUDE stm32l0xx.h)
        SET(CMSIS_DEVICE_HEADERS ${CMSIS_HEADER_TO_FORCE_INCLUDE} system_stm32l0xx.h)
        SET(CMSIS_DEVICE_SOURCES system_stm32l0xx.c)
        IF(NOT CMSIS_STARTUP_SOURCE)
            SET(CMSIS_STARTUP_SOURCE startup_stm32l${CHIP_TYPE_LOWER}.s)
        ENDIF()
    ELSEIF(FAMILY STREQUAL "L1")
        IF(NOT STM32Cube_DIR)
            SET(STM32Cube_DIR "/opt/STM32Cube_FW_L1_V1.8.0")
            MESSAGE(WARNING "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
        ENDIF()
        LIST(APPEND CMSIS_COMMON_HEADERS core_cm3.h)
        SET(CMSIS_HEADER_TO_FORCE_INCLUDE stm32l1xx.h)
        SET(CMSIS_DEVICE_HEADERS ${CMSIS_HEADER_TO_FORCE_INCLUDE} system_stm32l1xx.h)
        SET(CMSIS_DEVICE_SOURCES system_stm32l1xx.c)
        IF(NOT CMSIS_STARTUP_SOURCE)
            SET(CMSIS_STARTUP_SOURCE startup_stm32l${CHIP_TYPE_LOWER}.s)
        ENDIF()
    ELSEIF(FAMILY STREQUAL "L4")
        IF(NOT STM32Cube_DIR)
            SET(STM32Cube_DIR "/opt/STM32Cube_FW_L4_V1.9.0")
            MESSAGE(STATUS "No STM32Cube_DIR specified, using default: " ${STM32Cube_DIR})
        ENDIF()

        LIST(APPEND CMSIS_COMMON_HEADERS core_cm4.h)
        SET(CMSIS_HEADER_TO_FORCE_INCLUDE stm32l4xx.h)
        SET(CMSIS_DEVICE_HEADERS ${CMSIS_HEADER_TO_FORCE_INCLUDE} system_stm32l4xx.h)
        SET(CMSIS_DEVICE_SOURCES system_stm32l4xx.c) 
        IF(NOT CMSIS_STARTUP_SOURCE)
            SET(CMSIS_STARTUP_SOURCE startup_stm32l${CHIP_TYPE_LOWER}.s)
        ENDIF()   
    ENDIF()

    IF(NOT CMSIS_STARTUP_SOURCE)
        SET(CMSIS_STARTUP_SOURCE startup_stm32f${CHIP_TYPE_LOWER}.s)
    ENDIF()


    FIND_PATH(CMSIS_COMMON_INCLUDE_DIR ${CMSIS_COMMON_HEADERS}
        PATH_SUFFIXES include stm32${FAMILY_LOWER} cmsis
        HINTS ${STM32Cube_DIR}/Drivers/CMSIS/Include/
        CMAKE_FIND_ROOT_PATH_BOTH
    )

    FIND_PATH(CMSIS_DEVICE_INCLUDE_DIR ${CMSIS_DEVICE_HEADERS}
        PATH_SUFFIXES include stm32${FAMILY_LOWER} cmsis
        HINTS ${STM32Cube_DIR}/Drivers/CMSIS/Device/ST/STM32${FAMILY}xx/Include
        CMAKE_FIND_ROOT_PATH_BOTH
    )
    SET(CMSIS_INCLUDE_DIRS
        ${CMSIS_DEVICE_INCLUDE_DIR}
        ${CMSIS_COMMON_INCLUDE_DIR}
    )

    FOREACH(SRC ${CMSIS_DEVICE_SOURCES})
        STRING(MAKE_C_IDENTIFIER "${SRC}" SRC_CLEAN)
        SET(CMSIS_${SRC_CLEAN}_FILE SRC_FILE-NOTFOUND)
        FIND_FILE(CMSIS_${SRC_CLEAN}_FILE ${SRC}
            PATH_SUFFIXES src stm32${FAMILY_LOWER} cmsis
            HINTS ${STM32Cube_DIR}/Drivers/CMSIS/Device/ST/STM32${FAMILY}xx/Source/Templates/
            CMAKE_FIND_ROOT_PATH_BOTH
        )
        LIST(APPEND CMSIS_SOURCES ${CMSIS_${SRC_CLEAN}_FILE})
    ENDFOREACH()

    IF(CHIP_TYPE)
        generate_startup_file(${TARGET_NAME} ${FAMILY} ${CMSIS_STARTUP_SOURCE} OUT_FILEPATH ${STM32Cube_DIR})
        if (EXISTS ${OUT_FILEPATH})
            LIST(APPEND CMSIS_SOURCES ${OUT_FILEPATH})
            MESSAGE(STATUS "Generate startup file: ${OUT_FILEPATH}")
        endif()
    ENDIF()
    
    set(new_target cmsis)
    
    add_library(${new_target} ${CMSIS_SOURCES})
    foreach (SOURCE_FILE ${CMSIS_SOURCES})
        get_filename_component(EXTENSION ${SOURCE_FILE} LAST_EXT)
        if (EXTENSION STREQUAL ".c")
            set_source_files_properties(${SOURCE_FILE} PROPERTIES LANGUAGE CXX )
        endif()
    endforeach()
    STM32_SET_TARGET_PROPERTIES(${new_target} ${MCU})
    STM32_ADD_CHIP_PROPERTIES(${new_target} ${MCU})
    target_compile_features(${new_target} PRIVATE cxx_std_17)
    target_include_directories(${new_target} PUBLIC ${CMSIS_INCLUDE_DIRS})
    foreach(FORCE_INCLUDE_FILE ${CMSIS_HEADER_TO_FORCE_INCLUDE})
    target_compile_options (${new_target}  BEFORE PUBLIC $<$<COMPILE_LANGUAGE:CXX>:-include${FORCE_INCLUDE_FILE}>)
    endforeach()	
    PREPEND(ALL_HEADERS "${CMSIS_INCLUDE_DIRS}/" ${CMSIS_COMMON_HEADERS} ${CMSIS_DEVICE_HEADERS})
    MESSAGE(VERBOSE "Add sources: ${CMSIS_SOURCES}")
    MESSAGE(VERBOSE "Add include directories: ${CMSIS_INCLUDE_DIRS}")
    MESSAGE(VERBOSE "Add force includes: ${CMSIS_HEADER_TO_FORCE_INCLUDE}")
    MESSAGE(VERBOSE "Using headers: ${ALL_HEADERS}")
    
    target_link_libraries(${TARGET_NAME} PUBLIC ${new_target})
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction(add_cmsis_library)



INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(CMSIS DEFAULT_MSG)
