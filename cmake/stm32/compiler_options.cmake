function(set_project_options target)
   set(GCC_C_CXX_OPTIONS
	  -gdwarf-2  
    #-fpack-struct
    -fno-split-wide-types
    -fno-tree-scev-cprop
    -fno-strict-aliasing
    -funsigned-char # a few optimizations
    -funsigned-bitfields 
    -fshort-enums
    -ffunction-sections 
    -fdata-sections
    -finline-functions
    -fdiagnostics-color=always
  )

  set(GCC_CXX_OPTIONS
    -fno-threadsafe-statics
    -fno-rtti
  )



  set(PROJECT_OPTIONS "")
  
  foreach(COMPILE_OPTION ${GCC_C_CXX_OPTIONS})
    set(PROJECT_OPTIONS ${PROJECT_OPTIONS} $<$<COMPILE_LANGUAGE:C>:${COMPILE_OPTION}>)
    set(PROJECT_OPTIONS ${PROJECT_OPTIONS} $<$<COMPILE_LANGUAGE:CXX>:${COMPILE_OPTION}>)
  endforeach()	
  foreach(COMPILE_OPTION ${GCC_CXX_OPTIONS})
    set(PROJECT_OPTIONS ${PROJECT_OPTIONS} $<$<COMPILE_LANGUAGE:CXX>:${COMPILE_OPTION}>)
  endforeach()	

  #get_target_property(TARGET_NAME ${target} OUTPUT_NAME)
  target_compile_options(${target} INTERFACE ${PROJECT_OPTIONS})


endfunction()