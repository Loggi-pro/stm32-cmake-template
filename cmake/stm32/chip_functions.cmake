#List of supported family
#Add family here to add support, and also add specific_mcu/gcc_stm32${STM32_FAMILY_LOWER}.cmake
#usage ${STM32_ARCH_OF_${STM32_FAMILY}}
set(STM32_CHIP_ARCH_OF_L0		    M0+)
set(STM32_CHIP_ARCH_OF_L1			M3)
set(STM32_CHIP_ARCH_OF_L4			M4)
set(STM32_CHIP_ARCH_OF_F0			M0)
set(STM32_CHIP_ARCH_OF_F1			M3)
set(STM32_CHIP_ARCH_OF_F2			M3)
set(STM32_CHIP_ARCH_OF_F3			M4)
set(STM32_CHIP_ARCH_OF_F4			M4)
set(STM32_CHIP_ARCH_OF_F7			M7)

#Get mcu family
FUNCTION(STM32_CHIP_GET_FAMILY MCU FAMILY)
    STRING(REGEX REPLACE "^[sS][tT][mM]32(([fF][0-47])|([lL][0-14])|([tT])|([wW])).+$" "\\1" tmp ${MCU})
    STRING(TOUPPER ${tmp} tmp)
    SET(${FAMILY} ${tmp} PARENT_SCOPE)
    #check that family is supported
    if (NOT STM32_CHIP_ARCH_OF_${tmp})
        MESSAGE(FATAL_ERROR "Invalid/unsupported STM32 family: ${STM32_FAMILY}")
    endif()
ENDFUNCTION()

#Get mcu architecture
FUNCTION(STM32_CHIP_GET_ARCH MCU ARCH)
    STM32_CHIP_GET_FAMILY(${MCU} FAMILY)
    SET(${ARCH} ${STM32_CHIP_ARCH_OF_${FAMILY}} PARENT_SCOPE)
ENDFUNCTION()

#OUT->CHIP_TYPE 
FUNCTION(STM32_CHIP_GET_TYPE MCU CHIP_TYPE)
    STM32_CHIP_GET_FAMILY(${MCU} FAMILY)
    string(TOLOWER ${FAMILY} FAMILY)
    INCLUDE(specific_mcu/gcc_stm32${FAMILY})
    #
    CHIP_GET_TYPE_(${MCU} CHIP_TYPE_)
    set(${CHIP_TYPE} ${CHIP_TYPE_} PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(STM32_CHIP_GET_PARAMETERS MCU FLASH_SIZE RAM_SIZE CCRAM_SIZE)
    STM32_CHIP_GET_FAMILY(${MCU} FAMILY)
    string(TOLOWER ${FAMILY} FAMILY)
    INCLUDE(specific_mcu/gcc_stm32${FAMILY})
    #
    CHIP_GET_PARAMETERS_(${MCU} FLASH_SIZE_ RAM_SIZE_ CCRAM_SIZE_)
    set(${FLASH_SIZE} ${FLASH_SIZE_} PARENT_SCOPE)
    set(${RAM_SIZE} ${RAM_SIZE_} PARENT_SCOPE)
    set(${CCRAM_SIZE} ${CCRAM_SIZE_} PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(STM32_CHIP_SET_DEFINITIONS TARGET MCU)
    STM32_CHIP_GET_FAMILY(${MCU} FAMILY)
    string(TOLOWER ${FAMILY} FAMILY)
    INCLUDE(specific_mcu/gcc_stm32${FAMILY})
    #
    CHIP_SET_DEFINITIONS_(${TARGET} ${MCU})
ENDFUNCTION()

#OUT->CHIP_TYPES
FUNCTION(STM32_CHIP_GET_TYPES MCU CHIP_TYPES)
    STM32_CHIP_GET_FAMILY(${MCU} FAMILY)
    string(TOLOWER ${FAMILY} FAMILY)
    INCLUDE(specific_mcu/gcc_stm32${FAMILY})
    #
    CHIP_GET_TYPES_(${TARGET} TYPES_)
    set(${CHIP_TYPES} ${CHIP_TYPES_} PARENT_SCOPE)
ENDFUNCTION()

#OUT->CHIP_CODE
FUNCTION(STM32_CHIP_GET_CODE MCU CHIP_CODE)
    STM32_CHIP_GET_FAMILY(${MCU} FAMILY)
    string(TOLOWER ${FAMILY} FAMILY)
    INCLUDE(specific_mcu/gcc_stm32${FAMILY})
    #
    CHIP_GET_CURRENT_CODE_(${MCU} CHIP_CODE_)
    set(${CHIP_CODE} ${CHIP_CODE_} PARENT_SCOPE)
ENDFUNCTION()


FUNCTION(STM32_CHIP_GET_OPTIONS MCU
        CHIP_C_OPTIONS
        CHIP_CXX_OPTIONS
        CHIP_ASM_OPTIONS
        CHIP_EXE_LINKER_OPTIONS
        CHIP_MODULE_LINKER_OPTIONS
        CHIP_SHARED_LINKER_OPTIONS)
    STM32_CHIP_GET_FAMILY(${MCU} FAMILY)
    string(TOLOWER ${FAMILY} FAMILY)
    INCLUDE(specific_mcu/gcc_stm32${FAMILY})
    #
    CHIP_GET_OPTIONS_(CHIP_C_OPTIONS_ CHIP_CXX_OPTIONS_ CHIP_ASM_OPTIONS_ CHIP_EXE_LINKER_OPTIONS_ CHIP_MODULE_LINKER_OPTIONS_ CHIP_SHARED_LINKER_OPTIONS_)
    SET(CHIP_C_OPTIONS ${CHIP_C_OPTIONS_} PARENT_SCOPE)
    SET(CHIP_CXX_OPTIONS ${CHIP_CXX_OPTIONS_} PARENT_SCOPE)
    SET(CHIP_ASM_OPTIONS ${CHIP_ASM_OPTIONS_} PARENT_SCOPE)
    SET(CHIP_EXE_LINKER_OPTIONS ${CHIP_EXE_LINKER_OPTIONS_} PARENT_SCOPE)
    SET(CHIP_MODULE_LINKER_OPTIONS ${CHIP_MODULE_LINKER_OPTIONS_} PARENT_SCOPE)
    SET(CHIP_SHARED_LINKER_OPTIONS ${CHIP_SHARED_LINKER_OPTIONS_} PARENT_SCOPE)
ENDFUNCTION()
