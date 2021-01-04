set(CHIP_C_OPTIONS -g3 -mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize -Wl,-Map,output.map)
set(CHIP_CXX_OPTIONS -g3 -mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize -Wl,-Map,output.map)
set(CHIP_ASM_OPTIONS -g3 -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -Wa,--no-warn -x assembler-with-cpp)
set(CHIP_EXE_LINKER_OPTIONS -Wl,--gc-sections -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -specs=nosys.specs)
set(CHIP_MODULE_LINKER_OPTIONS -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16)
set(CHIP_SHARED_LINKER_OPTIONS -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16)

FUNCTION(CHIP_GET_OPTIONS_ STM32_CHIP_C_OPTIONS STM32_CHIP_CXX_OPTIONS STM32_CHIP_ASM_OPTIONS STM32_CHIP_EXE_LINKER_OPTIONS STM32_CHIP_MODULE_LINKER_OPTIONS STM32_CHIP_SHARED_LINKER_OPTIONS)
    SET(${STM32_CHIP_C_OPTIONS} ${CHIP_C_OPTIONS} PARENT_SCOPE)
    SET(${STM32_CHIP_CXX_OPTIONS} ${CHIP_CXX_OPTIONS} PARENT_SCOPE)
    SET(${STM32_CHIP_ASM_OPTIONS} ${CHIP_ASM_OPTIONS} PARENT_SCOPE)
    SET(${STM32_CHIP_EXE_LINKER_OPTIONS} ${CHIP_EXE_LINKER_OPTIONS} PARENT_SCOPE)
    SET(${STM32_CHIP_MODULE_LINKER_OPTIONS} ${CHIP_MODULE_LINKER_OPTIONS} PARENT_SCOPE)
    SET(${STM32_CHIP_SHARED_LINKER_OPTIONS} ${CHIP_SHARED_LINKER_OPTIONS} PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(CHIP_GET_TYPES_ STM32_CHIP_TYPES)
    SET(${STM32_CHIP_TYPES} 301xx 302xx 303xx 334xx 373xx PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(CHIP_GET_CODES_ CODES)
    SET(${CODES} "301.." "302.." "303.." "334.." "373.." PARENT_SCOPE)
ENDFUNCTION()
#OUT -> STM32_CODE
FUNCTION(CHIP_GET_CURRENT_CODE_ MCU STM32_CODE)
    STRING(REGEX REPLACE "^[sS][tT][mM]32[fF](3[037][1234].[68BC]).*$" "\\1" STM32_CODE_ ${MCU})
    SET(${STM32_CODE} ${STM32_CODE_} PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(CHIP_GET_TYPE_ MCU CHIP_TYPE)
    CHIP_GET_CODES_(STM32_CODES)
    CHIP_GET_CURRENT_CODE_(${MCU} STM32_CODE)
    SET(INDEX 0)
    CHIP_GET_TYPES_(STM32_CHIP_TYPES)
    FOREACH(C_TYPE ${STM32_CHIP_TYPES})
        LIST(GET STM32_CODES ${INDEX} CHIP_TYPE_REGEXP)
        IF(STM32_CODE MATCHES ${CHIP_TYPE_REGEXP})
            SET(RESULT_TYPE ${C_TYPE})
        ENDIF()
        MATH(EXPR INDEX "${INDEX}+1")
    ENDFOREACH()
    SET(${CHIP_TYPE} ${RESULT_TYPE} PARENT_SCOPE)
ENDFUNCTION()


FUNCTION(CHIP_GET_PARAMETERS_ MCU FLASH_SIZE RAM_SIZE CCRAM_SIZE)
    STRING(REGEX REPLACE "^[sS][tT][mM]32[fF]3[037][1234].([68BC]).*$" "\\1" STM32_SIZE_CODE ${MCU})
    IF(STM32_SIZE_CODE STREQUAL "6")
        SET(FLASH "32K")
        SET(CCRAM "4K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "8")
        SET(FLASH "64K")
        SET(CCRAM "4K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "B")
        SET(FLASH "128K")
        SET(CCRAM "8K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "C")
        SET(FLASH "256K")
        SET(CCRAM "8K")
    ENDIF()

    CHIP_GET_TYPE_(${MCU} TYPE)

    IF(${TYPE} STREQUAL "301xx")
        SET(RAM "16K")
    ELSEIF(${TYPE} STREQUAL "302xx")
        SET(RAM "256K")
    ELSEIF(${TYPE} STREQUAL "303xx")
        SET(RAM "40K")
    ELSEIF(${TYPE} STREQUAL "334xx")
        SET(RAM "16K")
    ELSEIF(${TYPE} STREQUAL "373xx")
        SET(RAM "128K")
    ENDIF()

    SET(${FLASH_SIZE} ${FLASH} PARENT_SCOPE)
    SET(${RAM_SIZE} ${RAM} PARENT_SCOPE)
    SET(${CCRAM_SIZE} ${CCRAM} PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(CHIP_SET_DEFINITIONS_ TARGET MCU)
    CHIP_GET_TYPE_(${MCU} CHIP_TYPE)
    CHIP_GET_TYPES_(STM32_CHIP_TYPES)
    CHIP_GET_CURRENT_CODE_(${MCU} STM32_CODE)
    LIST(FIND STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    IF(TYPE_INDEX EQUAL -1)
        MESSAGE(FATAL_ERROR "Invalid/unsupported STM32F3 chip type: ${CHIP_TYPE}")
    ENDIF()
    GET_TARGET_PROPERTY(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    STRING(REGEX REPLACE "^(3..).(.)" "\\1x\\2" CHIP_TYPE_2 ${STM32_CODE})
    IF(TARGET_DEFS)
        SET(TARGET_DEFS "STM32F3;STM32F${CHIP_TYPE_2};${TARGET_DEFS}")
    ELSE()
        SET(TARGET_DEFS "STM32F3;STM32F${CHIP_TYPE_2}")
    ENDIF()
    SET_TARGET_PROPERTIES(${TARGET} PROPERTIES COMPILE_DEFINITIONS "${TARGET_DEFS}")
ENDFUNCTION()
