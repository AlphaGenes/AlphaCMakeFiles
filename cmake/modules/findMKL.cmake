#
# Find Intel MKL
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


# MKLROOT environment variable should point to location of MKL folder
set(MKL_ROOT $ENV{MKLROOT})

if (NOT MKL_ROOT)
    if(APPLE)
        set(INTEL_ROOT "/opt/intel" CACHE PATH "Folder contains intel libs")
    elseif (WIN32)
        set(INTEL_ROOT "C:\\Program Files (x86)\\IntelSWTools\\compilers_and_libraries\\windows" CACHE PATH "Folder contains intel libs")
    else ()
        set (INTEL_ROOT "/exports/applications/apps/SL7/intel/parallel_studio_xe_2017_update4" CACHE PATH "Folder contains intel libs")
    endif()
    set(MKL_ROOT ${INTEL_ROOT}/mkl)
endif(NOT MKL_ROOT)


set(MKL_ROOT_LIB ${MKL_ROOT}/lib)
set(INTEL_RTL_ROOT ${INTEL_ROOT}/lib)
# Find include dir


find_path(MKL_INCLUDE_DIR mkl.fi
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
    set(BLACSLIBRARY mpich)
else()
    if(MKL_STATIC)
        set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
    else()
        set(CMAKE_FIND_LIBRARY_SUFFIXES .so)
    endif()
    set(BLACSLIBRARY intelmpi)
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


find_package_handle_standard_args(MKL DEFAULT_MSG
    MKL_INCLUDE_DIR MKL_LIBRARY MKL_MINIMAL_LIBRARY)


if(WIN32)
    set(MKL_EXTRA_PATH "${MKL_ROOT}\\lib\\intel64")
    set(MKL_BLAS  mkl_blas95_lp64${CMAKE_FIND_LIBRARY_SUFFIXES})
    set(MKL_SCALAPACK mkl_scalapack_lp64${CMAKE_FIND_LIBRARY_SUFFIXES})
    set(MKL_LAPACK mkl_lapack95_lp64${CMAKE_FIND_LIBRARY_SUFFIXES} )
    set(MKL_ILP mkl_intel_lp64${CMAKE_FIND_LIBRARY_SUFFIXES})
    # lp64 vs ilp64 - ilp64 indexes are 64 bit unsigned 
    # On the 2017 intel version, 64 bit libraries (ILP) are broken - so not working on eddie3
    set(MKL_THREAD mkl_intel_thread${CMAKE_FIND_LIBRARY_SUFFIXES} )
    set(MKL_CORE mkl_core${CMAKE_FIND_LIBRARY_SUFFIXES})
    message("WINDOWS MKL LIBS")
else()
    if (APPLE)
        set(MKL_EXTRA_PATH "${MKL_ROOT}/lib")
    else()
        set(MKL_EXTRA_PATH "${MKL_ROOT}/lib/intel64")
    endif()
    if (USE_MPI)
      set(MKL_BLACS libmkl_blacs_${BLACSLIBRARY}_ilp64${CMAKE_FIND_LIBRARY_SUFFIXES})
      set(MKL_SCALAPACK libmkl_scalapack_ilp64${CMAKE_FIND_LIBRARY_SUFFIXES})
    endif() 

    set(MKL_BLAS  libmkl_blas95_ilp64${CMAKE_FIND_LIBRARY_SUFFIXES})
    set(MKL_LAPACK libmkl_lapack95_ilp64${CMAKE_FIND_LIBRARY_SUFFIXES})
      
      set(MKL_ILP libmkl_intel_lp64${CMAKE_FIND_LIBRARY_SUFFIXES} )
      set(MKL_THREAD libmkl_intel_thread${CMAKE_FIND_LIBRARY_SUFFIXES} )
      set(MKL_CORE libmkl_core${CMAKE_FIND_LIBRARY_SUFFIXES})

    # lp64 vs ilp64 - ilp64 indexes are 64 bit unsigned 
    set(MKL_LIBRARIES_INCLUDE ${MKL_ROOT}/include/intel64/ilp64)
endif(WIN32)



message("BLAS PATH: ${MKL_EXTRA_PATH}")
message("BLAS PATH: ${MKL_BLAS}")
message("MKL_THREAD PATH: ${MKL_CORE}")
include_directories(${MKL_LIBRARIES_INCLUDE})
LINK_DIRECTORIES(${MKL_EXTRA_PATH})

# FIND_LIBRARY(RESULT ${MKL_LIBRARIES} PATHS ${MKL_EXTRA_PATH})

FIND_LIBRARY(MKL_BLAS_LIB ${MKL_BLAS} PATHS ${MKL_EXTRA_PATH})

message("BLAS at : ${MKL_BLAS_LIB}")
if (USE_MPI)
  FIND_LIBRARY(MKL_BLACS_LIB ${MKL_BLACS} PATHS ${MKL_EXTRA_PATH})
  message("BLACS at: ${MKL_BLACS_LIB}")
endif()
FIND_LIBRARY(MKL_LAPACK_LIB ${MKL_LAPACK} PATHS ${MKL_EXTRA_PATH})
FIND_LIBRARY(MKL_SCALAPACK_LIB ${MKL_SCALAPACK} PATHS ${MKL_EXTRA_PATH})
FIND_LIBRARY(MKL_ILP_LIB ${MKL_ILP} PATHS ${MKL_EXTRA_PATH})
FIND_LIBRARY(MKL_THREAD_LIB ${MKL_THREAD} PATHS ${MKL_EXTRA_PATH})
FIND_LIBRARY(MKL_CORE_LIB ${MKL_CORE} PATHS ${MKL_EXTRA_PATH})

# Get all MKL libs as one
set(MKL_MIX  ${MKL_BLAS_LIB} ${MKL_LAPACK_LIB} ${MKL_ILP_LIB} ${MKL_THREAD_LIB} ${MKL_CORE_LIB})
FIND_LIBRARY(MKL_DEFAULT_LIBS ${MKL_MIX} PATHS ${MKL_EXTRA_PATH})

#Link to blas like this  TARGET_LINK_LIBRARIES(${TESTPROG} ${RESULT})
if(MKL_FOUND)
    set(MKL_INCLUDE_DIRS ${MKL_INCLUDE_DIR})
    include_directories(${MKL_INCLUDE_DIRS})
    set(MKL_MINIMAL_LIBRARIES ${MKL_LIBRARY})
else()
    message("MKL not found at ${MKL_INCLUDE_DIR}")
endif(MKL_FOUND)
