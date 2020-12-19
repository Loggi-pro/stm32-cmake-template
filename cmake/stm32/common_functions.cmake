
FUNCTION(SOURCE_ADD_PROPERTY FILE PROPERTY_NAME VALUE)
    get_source_file_property(PROPERTY ${FILE}  ${PROPERTY_NAME})
    #MESSAGE("${FILE}---${PROPERTY}")
    if(PROPERTY)
        set_source_files_properties(${FILE}  PROPERTIES ${PROPERTY_NAME} "${PROPERTY}${VALUE}")
    else()
        set_source_files_properties(${FILE}  PROPERTIES ${PROPERTY_NAME} "${VALUE}")
    endif()
    get_source_file_property(PROPERTY ${FILE}  ${PROPERTY_NAME})
ENDFUNCTION(SOURCE_ADD_PROPERTY)

FUNCTION(ADD_FLAG FLAGS VALUE)
    set(FLAGS "${FLAGS}${VALUE}" FORCE)
ENDFUNCTION(ADD_FLAG)


FUNCTION(REMOVEPATH var)
    set(listVar "")
    foreach(f ${ARGN})
        set(temp "")
        get_filename_component(temp ${f} NAME)
        list(APPEND listVar "${temp}")
    endforeach()
    set(${var} "${listVar}" PARENT_SCOPE)
ENDFUNCTION(REMOVEPATH)

FUNCTION(PREPEND var prefix)
    set(listVar "")
        foreach(f ${ARGN})
    list(APPEND listVar "${prefix}${f}")
    endforeach()
    SET(${var} "${listVar}" PARENT_SCOPE)
ENDFUNCTION(PREPEND)
#METHOD->BEFORE or AFTER
FUNCTION(TARGET_ADD_FORCE_INCLUDES TARGET [METHOD] FORCE_INCLUDES)
    get_target_property(TARGET_NAME ${TARGET} OUTPUT_NAME)
    get_target_property(FLAGS ${TARGET_NAME} COMPILE_FLAGS)
    foreach(FILENAME ${FORCE_INCLUDES})
        #MESSAGE("FILENAME=${FILENAME}")
        target_compile_options (${TARGET_NAME}  ${METHOD} PUBLIC $<$<COMPILE_LANGUAGE:CXX>:-include${FILENAME}>)
    endforeach()	
	
    #MESSAGE("   SETUP FORCE_INCLUDES=${INCLUDE_STRING}")

ENDFUNCTION(TARGET_ADD_FORCE_INCLUDES)

#METHOD->BEFORE or AFTER
#PASS ARGN-INCLUDES
FUNCTION(TARGET_ADD_SOURCES TARGET METHOD)
    get_target_property(TARGET_NAME ${TARGET} OUTPUT_NAME)
    get_target_property(SOURCES ${TARGET_NAME} SOURCES)
    if(NOT SOURCES)  
        set(SOURCES "") 
    endif()
	#MESSAGE("ADD = ${ARGN}")
    if(${METHOD} STREQUAL BEFORE)
        set(SOURCES ${ARGN} ${SOURCES}) 
    else()
        set(SOURCES ${SOURCES} ${ARGN}) 
    endif()
    #MESSAGE("  SETUP SOURCES=${SOURCES}")
    set_target_properties(${TARGET_NAME}
        PROPERTIES 
        SOURCES "${SOURCES}"
    )
ENDFUNCTION()


#PASS ARGN-INCLUDES
FUNCTION(TARGET_ADD_DEFINES TARGET)
    get_target_property(TARGET_NAME ${TARGET} OUTPUT_NAME)
    target_compile_definitions(${TARGET_NAME}
        PUBLIC 
        ${ARGN}
    )
    #get_target_property(_compile_defs ${TARGET_NAME} COMPILE_DEFINITIONS)
    #MESSAGE("_compile_defs=${_compile_defs}")
ENDFUNCTION()



FUNCTION(SOURCE_ADD_GCOV)
    set(GCOV_C_FLAGS "-fprofile-arcs -ftest-coverage")
    #set(GCOV_LD_FLAGS "-lgcov -fprofile-arcs")

    foreach(tmp ${ARGN})
        #MESSAGE("ADD TO ${tmp}")
        SOURCE_ADD_PROPERTY(${tmp} COMPILE_FLAGS "${GCOV_C_FLAGS}")
    endforeach()
ENDFUNCTION()


function (ListToString result delim)
    list(GET ARGV 2 temp)
    math(EXPR N "${ARGC}-1")
    foreach(IDX RANGE 3 ${N})
        list(GET ARGV ${IDX} STR)
        set(temp "${temp}${delim}${STR}")
    endforeach()
    set(${result} "${temp}" PARENT_SCOPE)
endfunction(ListToString)