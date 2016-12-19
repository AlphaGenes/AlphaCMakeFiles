# - Find Intel MKL
# Find the MKL libraries
#
# Options:
#
#   MKL_STATIC       :   use static linking
#   MKL_MULTI_THREADED:   use multi-threading
#   MKL_SDL           :   Single Dynamic Library interface
#
# This module defines the following variables:
#
#   MKL_FOUND            : True if MKL_INCLUDE_DIR are found
#   MKL_INCLUDE_DIR      : where to find mkl.h, etc.
#   MKL_INCLUDE_DIRS     : set when MKL_INCLUDE_DIR found
#   MKL_LIBRARIES        : the library to link against.
SET(MKL_STATIC TRUE)
include(FindPackageHandleStandardArgs)

set(MKL_ROOT $ENV{MKLROOT})

if (NOT MKL_ROOT)
    if(APPLE)
        set(INTEL_ROOT "/opt/intel" CACHE PATH "Folder contains intel libs")
    elseif (WIN32)
        set(INTEL_ROOT "C:\\Program Files (x86)\\IntelSWTools\\compilers_and_libraries\\windows" CACHE PATH "Folder contains intel libs")
    else ()
        set (INTEL_ROOT "/exports/applications/apps/SL7/intel/parallel_studio_xe_2016" CACHE PATH "Folder contains intel libs")
    endif()
    set(MKL_ROOT ${INTEL_ROOT}/mkl)
endif(NOT MKL_ROOT)


set(MKL_ROOT_LIB ${MKL_ROOT}/lib)
set(INTEL_RTL_ROOT ${INTEL_ROOT}/lib)
# Find include dir


find_path(MKL_INCLUDE_DIR mkl.h
    PATHS ${MKL_ROOT}/include)

# Find include directory
#  There is no include folder under linux
if(WIN32)
    find_path(INTEL_INCLUDE_DIR mkl_service.h
        PATHS ${MKL_ROOT}/include)
    set(MKL_INCLUDE_DIR ${MKL_INCLUDE_DIR} ${INTEL_INCLUDE_DIR})
endif()

# Find libraries

# Handle suffix
set(_MKL_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES})

if(WIN32)
    if(MKL_STATIC)
        set(CMAKE_FIND_LIBRARY_SUFFIXES .lib)
    else()
        set(CMAKE_FIND_LIBRARY_SUFFIXES _dll.lib)
    endif()
elseif(APPLE)
    if(MKL_STATIC)
        set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
    else()
        set(CMAKE_FIND_LIBRARY_SUFFIXES .dylib)
    endif()
else()
    if(MKL_STATIC)
        set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
    else()
        set(CMAKE_FIND_LIBRARY_SUFFIXES .so)
    endif()
endif()


# MKL is composed by four layers: Interface, Threading, Computational and RTL

if(MKL_SDL)
    find_library(MKL_LIBRARY libmkl_rt
        PATHS ${MKL_ROOT_LIB})

    set(MKL_MINIMAL_LIBRARY ${MKL_LIBRARY})
else()
    ######################### Interface layer #######################
    if(WIN32)
        set(MKL_INTERFACE_LIBNAME libmkl_intel_c)
    else()
        set(MKL_INTERFACE_LIBNAME libmkl_intel)
    endif()
    # find_library(MKL_INTERFACE_LIBRARY ${MKL_INTERFACE_LIBNAME} PATHS ${MKL_ROOT}/lib/)
    SET(MKL_INTERFACE_LIBRARY ${MKL_ROOT_LIB}/${MKL_INTERFACE_LIBNAME}${CMAKE_FIND_LIBRARY_SUFFIXES})

    ######################## Threading layer ########################
    if(MKL_MULTI_THREADED)
        set(MKL_THREADING_LIBNAME libmkl_intel_thread)
    else()
        set(MKL_THREADING_LIBNAME libmkl_sequential)
    endif()

    # find_library(MKL_THREADING_LIBRARY ${MKL_THREADING_LIBNAME}
    #     PATHS ${MKL_ROOT}/lib/)
    SET(MKL_THREADING_LIBRARY ${MKL_ROOT_LIB}/${MKL_THREADING_LIBNAME}${CMAKE_FIND_LIBRARY_SUFFIXES})
    ####################### Computational layer #####################
    # find_library(MKL_CORE_LIBRARY libmkl_core
        # PATHS ${MKL_ROOT}/lib/)

    # SET(MKL_CORE_LIBRARY ${MKL_ROOT_LIB}/${MKL_THREADING_LIBNAME}${CMAKE_FIND_LIBRARY_SUFFIXES})
    ############################ RTL layer ##########################
    if(WIN32)
        set(MKL_RTL_LIBNAME libiomp5md)
    else()
        set(MKL_RTL_LIBNAME libiomp5)
    endif()
    # find_library(MKL_RTL_LIBRARY ${MKL_RTL_LIBNAME}
    #     PATHS ${INTEL_RTL_ROOT}/lib)
        SET(MKL_RTL_LIBRARY ${INTEL_RTL_ROOT}/${MKL_RTL_LIBNAME}${CMAKE_FIND_LIBRARY_SUFFIXES})

    set(MKL_LIBRARY ${MKL_INTERFACE_LIBRARY} ${MKL_THREADING_LIBRARY} ${MKL_CORE_LIBRARY} ${MKL_RTL_LIBRARY})
    
    set(MKL_MINIMAL_LIBRARY ${MKL_INTERFACE_LIBRARY} ${MKL_THREADING_LIBRARY} ${MKL_CORE_LIBRARY} ${MKL_RTL_LIBRARY})
endif()

set(CMAKE_FIND_LIBRARY_SUFFIXES ${_MKL_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES})

find_package_handle_standard_args(MKL DEFAULT_MSG
    MKL_INCLUDE_DIR MKL_LIBRARY MKL_MINIMAL_LIBRARY)


# Add specific libs from MKL
if (APPLE)
# set(BLAS_LIBRARIES "${MKL_ROOT}/lib/libmkl_blas95_ilp64.a ${MKL_ROOT}/lib/libmkl_intel_ilp64.a ${MKL_ROOT}/lib/libmkl_intel_thread.a ${MKL_ROOT}/lib/libmkl_core.a")
set(BLAS_PATH "${MKL_ROOT}/lib")
set(BLAS_LIBRARIES  libmkl_blas95_ilp64.a libmkl_intel_ilp64.a libmkl_intel_thread.a libmkl_core.a)
set(BLAS_LIBRARIES_INCLUDE ${MKL_ROOT}/include/intel64/ilp64)
else()
    if(WIN32)
        set(BLAS_PATH "${MKL_ROOT}\\lib\\intel64")
        set(BLAS_LIBRARIES  mkl_blas95_ilp64${CMAKE_FIND_LIBRARY_SUFFIXES} mkl_intel_ilp64${CMAKE_FIND_LIBRARY_SUFFIXES} mkl_intel_thread${CMAKE_FIND_LIBRARY_SUFFIXES} mkl_core${CMAKE_FIND_LIBRARY_SUFFIXES})
    else()
        set(BLAS_PATH "${MKL_ROOT}/lib/intel64")
        # set(BLAS_LIBRARIES  libmkl_blas95_ilp64${CMAKE_FIND_LIBRARY_SUFFIXES} libmkl_intel_ilp64${CMAKE_FIND_LIBRARY_SUFFIXES} libmkl_intel_thread${CMAKE_FIND_LIBRARY_SUFFIXES} libmkl_core${CMAKE_FIND_LIBRARY_SUFFIXES})
        set(BLAS_LIBRARIES  libmkl_blas95_ilp64${CMAKE_FIND_LIBRARY_SUFFIXES} libmkl_intel_ilp64${CMAKE_FIND_LIBRARY_SUFFIXES} libmkl_intel_thread${CMAKE_FIND_LIBRARY_SUFFIXES})
    endif(WIN32)
# set(BLAS_LIBRARIES  "${MKL_ROOT}/lib/intel64/libmkl_blas95_ilp64.a ${MKL_ROOT}/lib/intel64/libmkl_intel_ilp64.a ${MKL_ROOT}/lib/intel64/libmkl_intel_thread.a ${MKL_ROOT}/lib/intel64/libmkl_core.a")
set(BLAS_LIBRARIES_INCLUDE ${MKL_ROOT}/include/intel64/ilp64)
endif()

message("BLAS PATH: ${BLAS_PATH}")
LINK_DIRECTORIES(${BLAS_PATH})
FIND_LIBRARY(RESULT ${BLAS_LIBRARIES} PATHS ${BLAS_PATH})


#Link to blas like this  TARGET_LINK_LIBRARIES(${TESTPROG} ${RESULT})
if(MKL_FOUND)
    set(MKL_INCLUDE_DIRS ${MKL_INCLUDE_DIR})
    set(MKL_LIBRARIES ${MKL_LIBRARY})
    set(MKL_MINIMAL_LIBRARIES ${MKL_LIBRARY})
else()
    message("MKL not found at ${MKL_INCLUDE_DIR}")
endif(MKL_FOUND)
