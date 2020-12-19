SET(CHIP_C_OPTIONS -g3 -mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize CACHE INTERNAL "c compiler flags")
SET(CHIP_CXX_OPTIONS -g3 -mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize CACHE INTERNAL "cxx compiler flags")
SET(CHIP_ASM_OPTIONS -g3 -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -x assembler-with-cpp CACHE INTERNAL "asm compiler flags")
SET(CHIP_EXE_LINKER_OPTIONS -Wl,--gc-sections -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs CACHE INTERNAL "executable linker flags")
SET(CHIP_MODULE_LINKER_OPTIONS -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs CACHE INTERNAL "module linker flags")
SET(CHIP_SHARED_LINKER_OPTIONS -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs CACHE INTERNAL "shared linker flags")

FUNCTION(CHIP_GET_TYPES_ STM32_CHIP_TYPES)
    SET(${STM32_CHIP_TYPES} 431xx 432xx 433xx 442xx 443xx 451xx 452xx 462xx 471xx 475xx 476xx 485xx 486xx 496xx 4a6xx 4r5xx 4r7xx 4r9xx 4s5xx 4s7xx 4s9xx PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(CHIP_GET_CODES_ CODES)
    SET(${CODES} "431.." "432.." "433.." "442.." "443.." "451.." "452.." "462.." "471.." "475.." "476.." "485.." "486.." "496.." "4a6.." "4r5.." "4r7.." "4r9.." "4s5.." "4s7.." "4s9.." PARENT_SCOPE)
ENDFUNCTION()
#OUT -> STM32_CODE
FUNCTION(CHIP_GET_CURRENT_CODE_ MCU STM32_CODE)
    STRING(REGEX REPLACE "^[sS][tT][mM]32[lL](4[3456789ARS][1235679].[BCEGI]).*$" "\\1" STM32_CODE_ ${MCU})
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
    STRING(REGEX REPLACE "^[sS][tT][mM]32[lL]4[3456789ARS][1235679].([BCEGI]).*$" "\\1" STM32_SIZE_CODE ${MCU})
    IF(STM32_SIZE_CODE STREQUAL "B")
        SET(FLASH "128K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "C")
        SET(FLASH "256K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "E")
        SET(FLASH "512K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "G")
        SET(FLASH "1024K")
    ELSEIF(STM32_SIZE_CODE STREQUAL "I")
        SET(FLASH "2048K")
    ENDIF()
    
    CHIP_GET_TYPE_(${MCU} TYPE)
    
    IF(${TYPE} STREQUAL "431xx")
        SET(RAM "64K")
    ELSEIF(${TYPE} STREQUAL "432xx")
        SET(RAM "64K")
    ELSEIF(${TYPE} STREQUAL "433xx")
        SET(RAM "64K")
    ELSEIF(${TYPE} STREQUAL "442xx")
        SET(RAM "64K")
    ELSEIF(${TYPE} STREQUAL "443xx")
        SET(RAM "64K")
    ELSEIF(${TYPE} STREQUAL "451xx")
        SET(RAM "160K")
    ELSEIF(${TYPE} STREQUAL "452xx")
        SET(RAM "160K")
    ELSEIF(${TYPE} STREQUAL "462xx")
        SET(RAM "160K")
    ELSEIF(${TYPE} STREQUAL "471xx")
        SET(RAM "128K")
    ELSEIF(${TYPE} STREQUAL "475xx")
        SET(RAM "128K")
    ELSEIF(${TYPE} STREQUAL "476xx")
        SET(RAM "128K")
    ELSEIF(${TYPE} STREQUAL "485xx")
        SET(RAM "128K")
    ELSEIF(${TYPE} STREQUAL "486xx")
        SET(RAM "128K")
    ELSEIF(${TYPE} STREQUAL "496xx")
        SET(RAM "320K")
    ELSEIF(${TYPE} STREQUAL "4a6xx")
        SET(RAM "320K")
    ELSEIF(${TYPE} STREQUAL "4r5xx")
        SET(RAM "640K")
    ELSEIF(${TYPE} STREQUAL "4r7xx")
        SET(RAM "640K")
    ELSEIF(${TYPE} STREQUAL "4r9xx")
        SET(RAM "640K")
    ELSEIF(${TYPE} STREQUAL "4s5xx")
        SET(RAM "640K")
    ELSEIF(${TYPE} STREQUAL "4s7xx")
        SET(RAM "640K")
    ELSEIF(${TYPE} STREQUAL "4s9xx")
        SET(RAM "640K")
    ENDIF()
    
    SET(${FLASH_SIZE} ${FLASH} PARENT_SCOPE)
    SET(${RAM_SIZE} ${RAM} PARENT_SCOPE)
    SET(${CCRAM_SIZE} "64K" PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(CHIP_SET_DEFINITIONS_ TARGET MCU)
    CHIP_GET_TYPE_(${MCU} CHIP_TYPE)
    CHIP_GET_TYPES_(STM32_CHIP_TYPES)
    LIST(FIND STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    IF(TYPE_INDEX EQUAL -1)
        MESSAGE(FATAL_ERROR "Invalid/unsupported STM32L4 chip type: ${CHIP_TYPE}")
    ENDIF()
    GET_TARGET_PROPERTY(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    IF(TARGET_DEFS)
        SET(TARGET_DEFS "STM32L4;STM32L${CHIP_TYPE};${TARGET_DEFS}")
    ELSE()
        SET(TARGET_DEFS "STM32L4;STM32L${CHIP_TYPE}")
    ENDIF()
        
    SET_TARGET_PROPERTIES(${TARGET} PROPERTIES COMPILE_DEFINITIONS "${TARGET_DEFS}")
ENDFUNCTION()