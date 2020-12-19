SET(CMAKE_MODULE_PATH ${STM32_CMAKE_DIR} ${CMAKE_MODULE_PATH})
STRING(REGEX REPLACE "\\\\" "/" MYPATH $ENV{CPH_LIB}) 
SET(CPH_COMPONENTS gpio timer uart usb wake exti printf adc i2c graphics)

SET(CPH_MODULE_PATH Cortex${STM32_CHIP_ARCH})


SET(CPH_SOURCES "")
IF(NOT CPH_FIND_COMPONENTS)
    SET(CPH_FIND_COMPONENTS ${CPH_COMPONENTS})
    MESSAGE(STATUS "No CPH components selected, using all: ${CPH_FIND_COMPONENTS}")
ENDIF()

FOREACH(cmp ${CPH_FIND_COMPONENTS})
    LIST(FIND CPH_COMPONENTS ${cmp} CPH_FOUND_INDEX)
    IF(${CPH_FOUND_INDEX} LESS 0)
        MESSAGE(FATAL_ERROR "Unknown CPH component: ${cmp}. Available components: ${CPH_COMPONENTS}")
	ELSE()
	STRING(TOLOWER ${cmp} cmp_lower)
	if(cmp_lower STREQUAL "gpio")
	#ADD GPIO
	elseif(cmp_lower STREQUAL "timer")
	#ADD TIMER
		LIST(APPEND CPH_SOURCES ${MYPATH}/periph/platform/stm32/timer/${CPH_MODULE_PATH}/timer_stm32.cpp)
	elseif(cmp_lower STREQUAL "uart")
		LIST(APPEND CPH_SOURCES ${MYPATH}/periph/platform/stm32/uart/uart_impl.cpp)
	elseif(cmp_lower STREQUAL "usb")
		LIST(APPEND CPH_SOURCES ${MYPATH}/periph/platform/stm32/usb/${CPH_MODULE_PATH}/usb_it.cpp)
		LIST(APPEND CPH_SOURCES ${MYPATH}/periph/platform/stm32/usb/${CPH_MODULE_PATH}/usb_lowlevel.cpp)
		INCLUDE_DIRECTORIES(
			${MYPATH}/periph/platform/stm32/usb/${CPH_MODULE_PATH}/Inc
		)
	elseif(cmp_lower STREQUAL "wake")
		LIST(APPEND CPH_SOURCES ${MYPATH}/periph/wake/wake.cpp)
		LIST(APPEND CPH_SOURCES ${MYPATH}/periph/wake/crc.cpp)
	elseif(cmp_lower STREQUAL "exti")
		LIST(APPEND CPH_SOURCES ${MYPATH}/periph/platform/stm32/core/${CPH_MODULE_PATH}/stm32_exti.cpp)
	elseif(cmp_lower STREQUAL "printf")
		LIST(APPEND CPH_SOURCES ${MYPATH}/periph/platform/stm32/printf/platform_printf.cpp)
	elseif(cmp_lower STREQUAL "adc")
		LIST(APPEND CPH_SOURCES ${MYPATH}/periph/platform/stm32/adc/adc_impl.cpp)
	elseif(cmp_lower STREQUAL "i2c")
		LIST(APPEND CPH_SOURCES ${MYPATH}/periph/platform/stm32/i2c/platform_i2c.cpp)
	elseif(cmp_lower STREQUAL "graphics")
	
	endif()
    ENDIF()
   
ENDFOREACH()

#FORCE_INCLUDE
#LIST(APPEND FORCE_INCLUDE void/platform_specific.h)
	LIST(APPEND PROJECT_SOURCES ${CPH_SOURCES})



INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(CPH DEFAULT_MSG CPH_SOURCES)

