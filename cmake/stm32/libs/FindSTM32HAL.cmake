SET(STM32_COMPONENTS_REQUIRED ${STM32HAL_FIND_COMPONENTS}) #setup on ind Package phase

# OUT DEFINES
function(generate_defines DEFINES)
    list(APPEND CMAKE_MESSAGE_CONTEXT "defines")
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
    LIST(APPEND DEFINES_ HAL_MODULE_ENABLED)
    FOREACH(cmp ${STM32_COMPONENTS_REQUIRED})
        if (${cmp} STREQUAL flash_ramfunc) 
            LIST(APPEND DEFINES_ HAL_FLASH_MODULE_ENABLED)
            continue()
        endif()
        STRING(TOUPPER ${cmp} cmp_upper_)
        LIST(APPEND DEFINES_ HAL_${cmp_upper_}_MODULE_ENABLED)
    ENDFOREACH()
    LIST(REMOVE_DUPLICATES DEFINES_)
    MESSAGE(DEBUG "Generated components defines: ${DEFINES_}")
    set(${DEFINES} ${DEFINES_} PARENT_SCOPE)
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(generate_hal_conf_file TARGET_NAME FAMILY STM32Cube_DIR)
    #find template for hal_conf file
    list(APPEND CMAKE_MESSAGE_CONTEXT "config")
    STRING(TOLOWER ${FAMILY} STM32_FAMILY_LOWER)
    FIND_FILE(HAL_CONF_FILE_TEMPLATE stm32${STM32_FAMILY_LOWER}xx_hal_conf_template.h
            PATH_SUFFIXES src
            HINTS ${STM32Cube_DIR}/Drivers/STM32${FAMILY}xx_HAL_Driver/Inc
            CMAKE_FIND_ROOT_PATH_BOTH
    )
    if (EXISTS ${HAL_CONF_FILE_TEMPLATE})
        MESSAGE(DEBUG "Conf file template found: ${HAL_CONF_FILE_TEMPLATE}")
    else()
        MESSAGE(DEBUG "Conf file template not found")
    endif()
  
    #find existed hal_conf in include dirs of target
    get_target_property(include_dirs ${TARGET_NAME} INCLUDE_DIRECTORIES)
    FIND_FILE(HAL_CONF_FILE_EXISTED stm32${STM32_FAMILY_LOWER}xx_hal_conf.h
        PATH_SUFFIXES src
        HINTS ${include_dirs}
        CMAKE_FIND_ROOT_PATH_BOTH
    )
    #if alreade exist - do nothing
    if (EXISTS  ${HAL_CONF_FILE_EXISTED})
        MESSAGE(DEBUG "Conf project file found: ${HAL_CONF_FILE_EXISTED}")
        MESSAGE(VERBOSE "Using config hal project file: ${HAL_CONF_FILE_EXISTED}")
        list(POP_BACK CMAKE_MESSAGE_CONTEXT)
        return()
    endif()
    MESSAGE(DEBUG "Conf project file not found")
    if (NOT EXISTS ${HAL_CONF_FILE_TEMPLATE})
        message(FATAL_ERROR "CMake error: while configuring HAL library file <mcu>_hal_conf.h not found: please create this file")
        list(POP_BACK CMAKE_MESSAGE_CONTEXT)
        return()
    endif()
    #generate hal_conf
    MESSAGE(DEBUG "Generate config file")
    #comment out all modules defines
    file(READ ${HAL_CONF_FILE_TEMPLATE} filedata)
    string(REGEX REPLACE "(#define HAL[A-Za-z0-9_]+MODULE_ENABLED)" "//\\1" filedata ${filedata})

   
    #try to fin path to save file
    #filter all path inside project tree
    LIST(FILTER include_dirs INCLUDE REGEX ${CMAKE_SOURCE_DIR})
    #check is source folder exist
    set(src_folder ${include_dirs})
    LIST(FILTER src_folder INCLUDE REGEX ${CMAKE_SOURCE_DIR}/src$)
    LIST(LENGTH src_folder size)
    MESSAGE(DEBUG "Check all include dirs: ${src_folder}")
    if (size GREATER_EQUAL 1)
        LIST(GET src_folder 0 filepath)
        MESSAGE(DEBUG "Select 'src' folder")
    else()
    #else take any folder
        MESSAGE(DEBUG "Select first found folder")
        LIST(GET include_dirs 0 filepath)
    endif()
    MESSAGE(DEBUG "Write at path: ${filepath}")
    MESSAGE(VERBOSE "Generate config hal file: ${filepath}")
    #write file
    file(WRITE   ${filepath}/stm32${STM32_FAMILY_LOWER}xx_hal_conf.h "${filedata}")
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()

function(add_hal_library TARGET)
    list(APPEND CMAKE_MESSAGE_CONTEXT "hal")
    MESSAGE(STATUS "HAL components required: ${STM32_COMPONENTS_REQUIRED}")
    get_target_property(TARGET_NAME ${TARGET} OUTPUT_NAME)
    get_target_property(MCU ${TARGET} MCU)
    STM32_CHIP_GET_FAMILY(${MCU} FAMILY)

    IF(FAMILY STREQUAL "F0")
        SET(HAL_COMPONENTS adc can cec comp cortex crc dac dma flash gpio i2c
                        i2s irda iwdg pcd pwr rcc rtc smartcard smbus
                        spi tim tsc uart usart wwdg)

        SET(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

        # Components that have _ex sources
        SET(HAL_EX_COMPONENTS adc crc dac flash i2c pcd pwr rcc rtc smartcard spi tim uart)

        SET(HAL_PREFIX stm32f0xx_)

    ELSEIF(FAMILY STREQUAL "F1")
        SET(HAL_COMPONENTS adc can cec cortex crc dac dma eth flash gpio hcd i2c
                        i2s irda iwdg nand nor pccard pcd pwr rcc rtc sd smartcard
                        spi sram tim uart usart wwdg fsmc sdmmc usb)

        SET(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

        # Components that have _ex sources
        SET(HAL_EX_COMPONENTS adc dac flash gpio pcd rcc rtc tim)

        SET(HAL_PREFIX stm32f1xx_)

    ELSEIF(FAMILY STREQUAL "F2")
        SET(HAL_COMPONENTS adc can cortex crc cryp dac dcmi dma eth flash
                        gpio hash hcd i2c i2s irda iwdg nand nor pccard
                        pcd pwr rcc rng rtc sd smartcard spi sram tim
                        uart usart wwdg fsmc sdmmc usb)

        SET(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

        # Components that have _ex sources
        SET(HAL_EX_COMPONENTS adc dac dma flash pwr rcc rtc tim)

        SET(HAL_PREFIX stm32f2xx_)

    ELSEIF(FAMILY STREQUAL "F3")
        SET(HAL_COMPONENTS adc can cec comp cortex crc dac dma flash gpio i2c i2s
                        irda nand nor opamp pccard pcd pwr rcc rtc sdadc
                        smartcard smbus spi sram tim tsc uart usart wwdg)

        SET(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

        SET(HAL_EX_COMPONENTS adc crc dac flash i2c i2s opamp pcd pwr
                            rcc rtc smartcard spi tim uart)

        SET(HAL_PREFIX stm32f3xx_)

    ELSEIF(FAMILY STREQUAL "F4")
        SET(HAL_COMPONENTS adc can cec cortex crc cryp dac dcmi dma dma2d eth flash
                        flash_ramfunc fmpi2c gpio hash hcd i2c i2s irda iwdg ltdc
                        nand nor pccard pcd pwr qspi rcc rng rtc sai sd sdram
                        smartcard spdifrx spi sram tim uart usart wwdg fmc fsmc
                        sdmmc usb)

        SET(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

        # Components that have _ex sources
        SET(HAL_EX_COMPONENTS adc cryp dac dcmi dma flash fmpi2c hash i2c i2s pcd
                            pwr rcc rtc sai tim)

        SET(HAL_PREFIX stm32f4xx_)

    ELSEIF(FAMILY STREQUAL "F7")
        SET(HAL_COMPONENTS adc can cec cortex crc cryp dac dcmi dma dma2d eth flash
                        gpio hash hcd i2c i2s irda iwdg lptim ltdc nand nor pcd
                        pwr qspi rcc rng rtc sai sd sdram smartcard spdifrx spi
                        sram tim uart usart wwdg fmc sdmmc usb)

        SET(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

        # Components that have _ex sources
        SET(HAL_EX_COMPONENTS adc crc cryp dac dcmi dma flash hash i2c pcd
                            pwr rcc rtc sai tim)

        SET(HAL_PREFIX stm32f7xx_)

    ELSEIF(FAMILY STREQUAL "L0")
        SET(HAL_COMPONENTS adc comp cortex crc crs cryp dac dma exti firewall flash gpio i2c
                        i2s irda iwdg lcd lptim lpuart pcd pwr rcc rng rtc smartcard
                        smbus spi tim tsc uart usart utils wwdg)

        SET(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

        # Components that have _ex sources
        SET(HAL_EX_COMPONENTS adc comp crc cryp dac flash i2c pcd pwr rcc rtc smartcard tim uart usart)

        SET(HAL_PREFIX stm32l0xx_)
    ELSEIF(FAMILY STREQUAL "L1")
        SET(HAL_COMPONENTS adc comp cortex crc cryp dac dma flash flash_ramfunc
                        gpio i2c i2s irda iwdg lcd nor opamp pcd pwr rcc rtc
                        sd smartcard spi sram tim uart usart wwdg)
        SET(HAL_REQUIRED_COMPONENTS cortex pwr)
        
        # Components that have _ex sources
        SET(HAL_EX_COMPONENTS adc cryp dac flash opamp pcd pwr rcc rtc spi tim)
        # Components that have ll_ in names instead of hal_

        SET(HAL_PREFIX stm32l1xx_)
    ELSEIF(FAMILY STREQUAL "L4")
        SET(HAL_COMPONENTS adc can comp cortex crc cryp dac dcmi dfsdm dma dma2d dsi 
                        firewall flash flash_ramfunc gfxmmu gpio hash hcd i2c irda iwdg
                        lcd lptim ltdc nand nor opamp ospi pcd pwr qspi rcc rng rtc sai
                        sd smartcard smbus spi sram swpmi tim tsc uart usart wwdg)

        SET(HAL_REQUIRED_COMPONENTS cortex pwr rcc)

        # Components that have _ex sources
        SET(HAL_EX_COMPONENTS adc crc cryp dac dfsdm dma flash hash i2c ltdc 
                            opamp pcd pwr rcc rtc sai sd smartcard spi tim uart usart)
                            
        SET(HAL_PREFIX stm32l4xx_)

    ENDIF()

    SET(HAL_HEADERS
        ${HAL_PREFIX}hal.h
        ${HAL_PREFIX}hal_def.h
    )

    SET(HAL_SRCS
        ${HAL_PREFIX}hal.c
    )
    IF(NOT STM32_COMPONENTS_REQUIRED)
        SET(STM32_COMPONENTS_REQUIRED ${HAL_COMPONENTS})
        MESSAGE(STATUS "No STM32HAL components selected, using all: ${STM32_COMPONENTS_REQUIRED}")
    ENDIF()
    FOREACH(cmp ${HAL_REQUIRED_COMPONENTS})
        LIST(FIND STM32_COMPONENTS_REQUIRED ${cmp} STM32HAL_FOUND_INDEX)
        IF(${STM32HAL_FOUND_INDEX} LESS 0)
            LIST(APPEND STM32_COMPONENTS_REQUIRED ${cmp})
        ENDIF()
    ENDFOREACH()



    FOREACH(cmp ${STM32_COMPONENTS_REQUIRED})
        LIST(FIND HAL_COMPONENTS ${cmp} STM32HAL_FOUND_INDEX)
        IF(${STM32HAL_FOUND_INDEX} LESS 0)
            MESSAGE(FATAL_ERROR "Unknown STM32HAL component: ${cmp}. Available components: ${HAL_COMPONENTS}")
        ELSE()
            LIST(APPEND HAL_HEADERS ${HAL_PREFIX}hal_${cmp}.h)
            LIST(APPEND HAL_SRCS ${HAL_PREFIX}hal_${cmp}.c)
        ENDIF()
        LIST(FIND HAL_EX_COMPONENTS ${cmp} STM32HAL_FOUND_INDEX)
        IF(NOT (${STM32HAL_FOUND_INDEX} LESS 0))
            LIST(APPEND HAL_HEADERS ${HAL_PREFIX}hal_${cmp}_ex.h)
            LIST(APPEND HAL_SRCS ${HAL_PREFIX}hal_${cmp}_ex.c)
        ENDIF()
    ENDFOREACH()

    LIST(REMOVE_DUPLICATES HAL_HEADERS)
    LIST(REMOVE_DUPLICATES HAL_SRCS)

    STRING(TOLOWER ${FAMILY} STM32_FAMILY_LOWER)

    FIND_PATH(STM32HAL_INCLUDE_DIR ${HAL_HEADERS}
        PATH_SUFFIXES include stm32${STM32_FAMILY_LOWER}
        HINTS ${STM32Cube_DIR}/Drivers/STM32${FAMILY}xx_HAL_Driver/Inc
        CMAKE_FIND_ROOT_PATH_BOTH
    )

    FOREACH(HAL_SRC ${HAL_SRCS})
        STRING(MAKE_C_IDENTIFIER "${HAL_SRC}" HAL_SRC_CLEAN)
        SET(HAL_${HAL_SRC_CLEAN}_FILE HAL_SRC_FILE-NOTFOUND)
        FIND_FILE(HAL_${HAL_SRC_CLEAN}_FILE ${HAL_SRC}
            PATH_SUFFIXES src stm32${STM32_FAMILY_LOWER}
            HINTS ${STM32Cube_DIR}/Drivers/STM32${FAMILY}xx_HAL_Driver/Src
            CMAKE_FIND_ROOT_PATH_BOTH
        )
        LIST(APPEND STM32HAL_SOURCES ${HAL_${HAL_SRC_CLEAN}_FILE})
    ENDFOREACH()
    #GET HAL_CONF FILE
    generate_hal_conf_file(${TARGET_NAME} ${FAMILY} ${STM32Cube_DIR})
    #GENERATE HAL_*_MODULE_ENABLED_DEFINE
    generate_defines(DEFINES)
    ##

    set(new_target hal)
    add_library(${new_target} ${STM32HAL_SOURCES})
    foreach (SOURCE_FILE ${STM32HAL_SOURCES})
        get_filename_component(EXTENSION ${SOURCE_FILE} LAST_EXT)
        if (EXTENSION STREQUAL ".c")
            set_source_files_properties(${SOURCE_FILE} PROPERTIES LANGUAGE CXX )
        endif()
    endforeach()

    get_target_inherited_property(INCLUDE_DIRECTORIES ${TARGET_NAME} INCLUDE_DIRECTORIES) #for finding hal_conf file

    target_include_directories(${new_target}   PRIVATE ${INCLUDE_DIRECTORIES})

    STM32_SET_TARGET_PROPERTIES(${new_target} ${MCU})
    STM32_ADD_CHIP_PROPERTIES(${new_target} ${MCU})
    target_compile_features(${new_target} PRIVATE cxx_std_17)
    
    target_include_directories(${new_target} PUBLIC ${STM32HAL_INCLUDE_DIR})
    target_compile_options (${new_target}  PUBLIC $<$<COMPILE_LANGUAGE:CXX>:-include${HAL_PREFIX}hal.h>)
    target_compile_definitions(${new_target}  PUBLIC ${DEFINES})
    target_link_libraries(${TARGET_NAME} PUBLIC ${new_target})
    #
    PREPEND(ALL_HEADERS "${STM32HAL_INCLUDE_DIR}/" ${HAL_HEADERS})
    MESSAGE(VERBOSE "Add sources: ${STM32HAL_SOURCES}")
    MESSAGE(VERBOSE "Add include directories: ${STM32HAL_INCLUDE_DIR}")
	MESSAGE(VERBOSE "Add force includes: ${HAL_PREFIX}hal.h")
    MESSAGE(VERBOSE "Add defines: ${DEFINES}")
    MESSAGE(VERBOSE "Using headers: ${ALL_HEADERS}")
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction()
INCLUDE(FindPackageHandleStandardArgs)
# STM32HAL_INCLUDE_DIR STM32HAL_SOURCES
FIND_PACKAGE_HANDLE_STANDARD_ARGS(STM32HAL DEFAULT_MSG)
