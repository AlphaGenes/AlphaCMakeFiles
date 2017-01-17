# README #
This holds the necessary files to find various libraries for Cmake.   This repository should be cloned into somewhere on your machine, and then never changed! (except to update once in a while :) ).

##Using CMake ##

To use CMake, the project directory needs to have 4 folders in it.   These are /src, /objs, /bin and /tests.   CMake expects all of the source files to reside in /src (all .f90 files), the test files in tests (all .pf files, testSuites.inc), puts the object and mod files in /objs (can safely be ignored) and puts the executable in /bin.


When using CMake, the various options are set using a file called CMakeLists.txt.   There are two of these.   The first gives the overall project options and lives in the main folder of your project.   The second gives the files to compile, together with any libraries that are in use.   This file resides in <projectDirectory>/src.

```CMAKE_MINIMUM_REQUIRED(VERSION 2.8.5)
PROJECT(<ProjectName>)
enable_language (Fortran)

find_package(Doxygen)
OPTION(RUN_TESTS "Run and compile tests"
  OFF)
OPTION(USE_HDF5 "Use hdf"
       OFF)

set(CLUSTER 0 CACHE STRING "cluster size")
# Add our local modlues to the module path
SET(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../alphacmakefiles/cmake/modules")
set(CMAKE_MACOSX_RPATH 0)

INCLUDE(${CMAKE_MODULE_PATH}/setVersion.cmake)

INCLUDE(${CMAKE_MODULE_PATH}/findDoxygen.cmake)

# add propressor variables like list
add_definitions(-DCLUSTER=${CLUSTER})

# Define the executable name
SET(PROGRAMEXE <name_of_exe>)
MESSAGE("Prog name ${PROGRAMEXE}")


# Define the library name
SET(AHLIB alphahouse)

# Define some directories
SET(SRC ${CMAKE_SOURCE_DIR}/src)
SET(OBJ ${CMAKE_SOURCE_DIR}/objs)
SET(BIN ${CMAKE_SOURCE_DIR}/bin)
SET(TESTS ${CMAKE_SOURCE_DIR}/tests)
SET(<SRCPROGRAM> ${SRC}/)

# Defined libary source

# Uncomment if it is required that Fortran 90 is supported
IF(NOT CMAKE_Fortran_COMPILER_SUPPORTS_F90)
   MESSAGE(FATAL_ERROR "Fortran compiler does not support F90")
ENDIF(NOT CMAKE_Fortran_COMPILER_SUPPORTS_F90)

# Set some options the user may choose
# Uncomment the below if you want the user to choose a parallelization library
OPTION(USE_MPI "Use the MPI library for parallelization" OFF)
OPTION(USE_OPENMP "Use OpenMP for parallelization" ON)


if (${RUN_TESTS})
	# list all test dependencies
	SET(testDeps ${SRC}/<test_file_dep>.f90
		...
	)
endif (${RUN_TESTS})

# set(_files "test.pf")


INCLUDE(${CMAKE_MODULE_PATH}/SetParallelizationLibrary.cmake)

INCLUDE(${CMAKE_MODULE_PATH}/findMKL.cmake)
# Setup the LAPACK libraries.  This also takes care of peculiarities, such as
# the fact the searching for MKL requires a C compiler, and that the results
# are not stored in the cache.
#INCLUDE(${CMAKE_MODULE_PATH}/SetUpLAPACK.cmake)
if (${USE_HDF5})
	INCLUDE(${CMAKE_MODULE_PATH}/findHDF5.cmake)
endif(${USE_HDF5})

# This INCLUDE statement executes code that sets the compile flags for DEBUG,
# RELEASE, and TESTING.  You should  review this file and make sure the flags
# are to your liking.
INCLUDE(${CMAKE_MODULE_PATH}/SetFortranFlags.cmake)
SET(SRCAH ../alphahouse/src/)

# Have the .mod files placed in the OBJ folder
SET(CMAKE_Fortran_MODULE_DIRECTORY ${OBJ})


ADD_SUBDIRECTORY(${SRCAH} ${OBJ}/AH)


# TODO add tests to correct location
ADD_SUBDIRECTORY(${SRCALPHAIMPUTE} ${BIN})

# Add a distclean target to the Makefile
ADD_CUSTOM_TARGET(distclean
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_MODULE_PATH}/distclean.cmake
)

if (${RUN_TESTS})
	INCLUDE(${CMAKE_MODULE_PATH}/findPFUnit.cmake)
endif(${RUN_TESTS})
```






### Using Cmake on Mac ###

* Quick summary
* Version
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

### Using Cmake on Eddie ###

To use CMake on edd