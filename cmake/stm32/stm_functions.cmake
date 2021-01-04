
function(add_stm_dump TARGET)
	set(elf_file ${TARGET}.elf)
	ADD_CUSTOM_TARGET(${TARGET}.dump DEPENDS ${elf_file} COMMAND ${CMAKE_OBJDUMP} -x -D -S -s ${elf_file} | ${CMAKE_CPPFILT} > ${TARGET}.dump)
endfunction()

##########################################################################
# add_stm_executable
# - IN_VAR: EXECUTABLE_NAME
# - IN_VAR: MCU_TYPE
# Creates targets and dependencies for STM toolchain, building an
# executable. Calls add_executable with ELF file as target name, so
# any link dependencies need to be using that target, e.g. for
# target_link_libraries(<EXECUTABLE_NAME>.elf ...).
##########################################################################
function(add_stm_executable EXECUTABLE_NAME MCU)
	list(APPEND CMAKE_MESSAGE_CONTEXT "target")
	if(NOT ARGN)
		message(FATAL_ERROR "No source files given for ${EXECUTABLE_NAME}.")
	endif(NOT ARGN)
	# set file names
	set(OUTPUT_DIR ${EXECUTABLE_OUTPUT_PATH})
	set(elf_file ${EXECUTABLE_NAME}.elf)
	set(bin_file ${EXECUTABLE_NAME}.bin)
	set(hex_file ${EXECUTABLE_NAME}.hex)
	set(lst_file ${EXECUTABLE_NAME}.lst)
	set(map_file ${EXECUTABLE_NAME}.map)
	set(eeprom_image ${EXECUTABLE_NAME}.eep)

	# elf file
	add_executable(${elf_file} EXCLUDE_FROM_ALL ${ARGN})
	STM32_SET_TARGET_PROPERTIES(${elf_file} ${MCU})
	STM32_ADD_CHIP_PROPERTIES(${elf_file} ${MCU})

	target_compile_definitions(${elf_file} PUBLIC -DMCU=${MCU})
	
	get_target_property(LINK_OPTS ${elf_file} LINK_OPTIONS)
	message(STATUS "LINKER OPTIONS: ${LINK_OPTS}")
	get_target_property(COMPILE_OPTIONS ${elf_file} COMPILE_OPTIONS)
	message(STATUS "COMPILE OPTIONS: ${COMPILE_OPTIONS}")
	#=====================ADD STANDART LIBRARY=================================================


	#GENERATE HEX AND BIN
	add_custom_command(
		OUTPUT ${hex_file}
		COMMAND
			${CMAKE_OBJCOPY} -Oihex ${OUTPUT_DIR}/${elf_file} ${OUTPUT_DIR}/${hex_file}
			DEPENDS ${elf_file}
	)
	add_custom_command(
		OUTPUT ${bin_file}
		COMMAND
			${CMAKE_OBJCOPY} -Obinary ${OUTPUT_DIR}/${elf_file} ${OUTPUT_DIR}/${bin_file}
			DEPENDS ${elf_file}
	)
	add_custom_command(
		OUTPUT ${lst_file}
		COMMAND
			${CMAKE_OBJDUMP} -d ${OUTPUT_DIR}/${elf_file} > ${lst_file}
		DEPENDS ${elf_file}
	)

	## eeprom
	add_custom_command(
		OUTPUT ${eeprom_image}
		COMMAND
			${CMAKE_OBJCOPY} -j .eeprom --set-section-flags=.eeprom=alloc,load
			--change-section-lma .eeprom=0 --no-change-warnings
			-O ihex ${OUTPUT_DIR}/${elf_file} ${OUTPUT_DIR}/${eeprom_image}
		DEPENDS ${elf_file}
	)

	add_custom_target(
		${EXECUTABLE_NAME}
		ALL
		DEPENDS ${hex_file} ${lst_file} ${eeprom_image} ${bin_file} 
	)
	SET(CLEAN_FILES ${OUTPUT_DIR}/${map_file} ${OUTPUT_DIR}/${hex_file} ${OUTPUT_DIR}/${eeprom_image} ${OUTPUT_DIR}/${bin_file} ${CMAKE_CURRENT_BINARY_DIR}/${lst_file})
	get_target_property(ADDITIONAL_CLEAN_FILES ${EXECUTABLE_NAME} ADDITIONAL_CLEAN_FILES)
	set_target_properties(
		${EXECUTABLE_NAME}
		PROPERTIES
			OUTPUT_NAME "${elf_file}"
			MCU ${MCU} #SETUP MCU PROPERTY FOR OTHER UTILITIES
			ADDITIONAL_CLEAN_FILES  "${ADDITIONAL_CLEAN_FILES}${CLEAN_FILES}"
	)
	print_size(${EXECUTABLE_NAME}) 

	add_custom_command(
		TARGET ${EXECUTABLE_NAME} POST_BUILD
		COMMAND echo ========== Build succeeded ==========
	)
	
	list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endfunction(add_stm_executable)

function(add_stm_copy EXECUTABLE_NAME)
	set(OUTPUT_DIR ${EXECUTABLE_OUTPUT_PATH})
	set(elf_file ${EXECUTABLE_NAME}.elf)
	set(elf_file_collect ${EXECUTABLE_NAME}_collect)
	#make copy of target
	get_target_inherited_property(LINK_FLAGS ${elf_file} LINK_FLAGS)
	get_target_inherited_property(LINK_OPTIONS ${elf_file} LINK_OPTIONS)
	get_target_inherited_property(COMPILE_OPTIONS ${elf_file} COMPILE_OPTIONS)
	get_target_inherited_property(SOURCES  ${elf_file} SOURCES )
	get_target_inherited_property(MCU  ${EXECUTABLE_NAME} MCU )
	get_target_inherited_property(INCLUDE_DIRECTORIES  ${elf_file} INCLUDE_DIRECTORIES)
	get_target_inherited_property(COMPILE_DEFINITIONS  ${elf_file} COMPILE_DEFINITIONS)
	#--config Release --target ${EXECUTABLE_NAME} > omg.txt

	add_executable(${elf_file_collect} EXCLUDE_FROM_ALL ${SOURCES})
	LIST(APPEND COMPILE_OPTIONS -H)
	set_target_properties(
		${elf_file_collect}
		PROPERTIES
			OUTPUT_NAME ${elf_file_collect}
			MCU ${MCU} #SETUP MCU PROPERTY FOR OTHER UTILITIES
			LINK_OPTIONS "${LINK_OPTIONS}"
			COMPILE_OPTIONS "${COMPILE_OPTIONS}"
			SOURCES "${SOURCES}"
			COMPILE_DEFINITIONS "${COMPILE_DEFINITIONS}"
			INCLUDE_DIRECTORIES "${INCLUDE_DIRECTORIES}"
			
	)
	SET(VAR ${CMAKE_COMMAND})
	target_compile_features(${elf_file_collect} PUBLIC cxx_std_17)
	#COMMAND ${CMAKE_COMMAND} -E tar xzf "${CMAKE_CURRENT_SOURCE_DIR}/libfoo/foo.tar"z
	LIST(APPEND CMD echo. 2>EmptyFile.txt)
	add_custom_target(custom_target
		COMMAND ${CMD} > file.txt
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
		DEPENDS ${elf_file_collect}
		#COMMENT "Unpacking foo.tar"
	)
endfunction()

