#-fno-threadsafe-statics отьедает 60кб, за счёт того что делает инициализацию static переменных в функциях потокобезопасной
#-fno-exceptions
SET(CMAKE_DEBUG_FLAG -DNDEBUG)
IF(CMAKE_BUILD_TYPE MATCHES Debug OR CMAKE_BUILD_TYPE MATCHES DebugMinSize)
    SET(CMAKE_DEBUG_FLAG -D_DEBUG)
ENDIF()

SET(CMAKE_C_FLAGS_DEBUG "-O0 -g" CACHE INTERNAL "c compiler flags debug")
SET(CMAKE_CXX_FLAGS_DEBUG "-O0 -g  -fno-threadsafe-statics  -fno-rtti" CACHE INTERNAL "cxx compiler flags debug")
SET(CMAKE_ASM_FLAGS_DEBUG "-g" CACHE INTERNAL "asm compiler flags debug")
SET(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE INTERNAL "linker flags debug")

SET(CMAKE_C_FLAGS_DEBUGMINSIZE "-Og -g" CACHE INTERNAL "c compiler flags debugminsize")
SET(CMAKE_CXX_FLAGS_DEBUGMINSIZE "-Og -g  -fno-threadsafe-statics  -fno-rtti" CACHE INTERNAL "cxx compiler flags debugminsize")
SET(CMAKE_ASM_FLAGS_DEBUGMINSIZE "-g" CACHE INTERNAL "asm compiler flags debugminsize")
SET(CMAKE_EXE_LINKER_FLAGS_DEBUGMINSIZE "" CACHE INTERNAL "linker flags debugminsize")



#-flto  -flto -flto
SET(CMAKE_C_FLAGS_RELEASE "-O2" CACHE INTERNAL "c compiler flags release")
SET(CMAKE_CXX_FLAGS_RELEASE "-O2 -fno-threadsafe-statics -fno-rtti" CACHE INTERNAL "cxx compiler flags release")
SET(CMAKE_ASM_FLAGS_RELEASE "" CACHE INTERNAL "asm compiler flags release")
SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "" CACHE INTERNAL "linker flags release")
SET(CMAKE_FIND_ROOT_PATH "${TOOLCHAIN_PATH}/${TARGET_TRIPLET}" ${EXTRA_FIND_PATH})
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)

#SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
SET(ENABLE_LTO ON)
IF(ENABLE_LTO MATCHES ON)
	set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -flto -ffat-lto-objects") #ffat-lto-object for linking against static libraries
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -flto -ffat-lto-objects")#ffat-lto-object for linking against static libraries
ENDIF()