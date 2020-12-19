function(set_project_warnings target)
  set(GCC_C_CXX_WARNINGS
    -Wall
    -Wextra # reasonable and standard
    -Wshadow # warn the user if a variable declaration shadows one from a
              # parent context
    #-Wold-style-cast # warn for c-style casts
    -Wcast-align # warn for potential performance problem casts
    -Wunused # warn on anything being unused
                          # function
    -Wpedantic # warn if non-standard C++ is used
    -Wconversion # warn on type conversions that may lose data
    -Wsign-conversion # warn on sign conversions
    -Wnull-dereference # warn if a null dereference is detected
    -Wdouble-promotion # warn if float is implicit promoted to double
    -Wformat=2 # warn on security issues around functions that format output
                # (ie printf)
    -Wmisleading-indentation # warn if identation implies blocks where blocks
                              # do not exist
    -Wduplicated-cond # warn if if / else chain has duplicated conditions
    -Wduplicated-branches # warn if if / else branches have duplicated code
    -Wlogical-op # warn about logical operations being used where bitwise were
                  # probably wanted
    -Wno-unknown-pragmas
    -Wno-unused-local-typedefs
    -Wswitch
    -Wreturn-local-addr
  )
  set(GCC_CXX_WARNINGS
    -Wnon-virtual-dtor    # warn the user if a class with virtual functions has a
                          # non-virtual destructor. This helps catch hard to
                          # track down memory errors
    -Woverloaded-virtual  # warn if you overload (not override) a virtual
    -Wuseless-cast        # warn if you perform a cast to the same type
  )
  if (WARNINGS_AS_ERRORS)
    set(GCC_C_CXX_WARNINGS ${GCC_C_CXX_WARNINGS} -Werror)
  endif()

  set(PROJECT_WARNINGS "")
  
  foreach(COMPILE_OPTIONS ${GCC_C_CXX_WARNINGS})
    set(PROJECT_WARNINGS ${PROJECT_WARNINGS} $<$<COMPILE_LANGUAGE:C>:${COMPILE_OPTIONS}>)
    set(PROJECT_WARNINGS ${PROJECT_WARNINGS} $<$<COMPILE_LANGUAGE:CXX>:${COMPILE_OPTIONS}>)
  endforeach()	
  foreach(COMPILE_OPTIONS ${GCC_CXX_WARNINGS})
    set(PROJECT_WARNINGS ${PROJECT_WARNINGS} $<$<COMPILE_LANGUAGE:CXX>:${COMPILE_OPTIONS}>)
  endforeach()	

  #get_target_property(TARGET_NAME ${target} OUTPUT_NAME)
  target_compile_options(${target} INTERFACE ${PROJECT_WARNINGS})

endfunction()