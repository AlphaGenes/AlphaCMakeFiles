
set(PFUNIT_DIR $ENV{PFUNITDIR})


if (NOT PFUNIT_DIR)
  if (USE_MPI) 
    SET(PFUNIT_DIR "/usr/local/pFUnit_Parallel")
  else (USE_MPI)
    SET (PFUNIT_DIR "/usr/local/pFUnit_serial")
  endif(USE_MPI)
endif(NOT PFUNIT_DIR)

enable_testing()


if(DEFINED PFUNIT_DIR)
    # message(STATUS "Manual setup of variable PFUNIT_DIR : ${PFUNIT_DIR}")
    set(PFUNIT_DIR ${PFUNIT_DIR})
else(DEFINED PFUNIT_DIR)
    include(ExternalProject)

    set(ExternalProjectCMakeArgs
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_INSTALL_PREFIX=${PROJECT_BINARY_DIR}/external/pfunit
        -DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
        )
    ExternalProject_Add(pfunit
        DOWNLOAD_COMMAND git submodule update
        DOWNLOAD_DIR ${PROJECT_SOURCE_DIR}
        SOURCE_DIR ${PROJECT_SOURCE_DIR}/external/pfunit
        BINARY_DIR ${PROJECT_BINARY_DIR}/external/pfunit-build
        STAMP_DIR ${PROJECT_BINARY_DIR}/external/pfunit-stamp
        TMP_DIR ${PROJECT_BINARY_DIR}/external/pfunit-tmp
        INSTALL_DIR ${PROJECT_BINARY_DIR}/external
        CMAKE_ARGS ${ExternalProjectCMakeArgs}
        )
    include_directories(${PROJECT_BINARY_DIR}/external/pfunit/mod)
    set(PFUNIT_DIR ${PROJECT_BINARY_DIR}/external/pfunit)
endif(DEFINED PFUNIT_DIR)

file(MAKE_DIRECTORY ${OBJ}/generated)
file(WRITE ${OBJ}/generated/testSuites.inc "")

include_directories(${PFUNIT_DIR}/source)

include_directories(
    # ${TESTS}
    ${SRC}
    # ${OBJ}
    ${PFUNIT_DIR}/mod
    ${OBJ}/generated
    )
message(STATUS "Manual setup of variable PFUNIT_DIR : ${PFUNIT_DIR}")
set(_test_sources)
if (NOT DEFINED TESTFILES)
    file(GLOB files "${TESTS}/*.pf")
else()
    set(files ${TESTFILES})
endif()
# set(files ${TESTFILES})
    message("TESTS: ${files}" )
    foreach(_file ${files})

    get_filename_component (_test ${_file} NAME_WE)
    set(test_dependency ${TESTS}/${_test}.pf ${SRC}/*.f90)
    add_custom_command(
        OUTPUT ${OBJ}/generated/${_test}.F90
        COMMAND python ${PFUNIT_DIR}/bin/pFUnitParser.py ${TESTS}/${_test}.pf ${OBJ}/generated/${_test}.F90
        DEPENDS ${test_dependency}
        )
    set(_test_sources ${_test_sources} ${OBJ}/generated/${_test}.F90)
    file(APPEND ${OBJ}/generated/testSuites.inc "ADD_TEST_SUITE(${_test}_suite)\n")
endforeach()

set_source_files_properties(${PFUNIT_DIR}/include/driver.F90 PROPERTIES GENERATED 1)


# file(GLOB testDeps "${SRC}/*.f90")
add_executable(
    pftest_alltests
    ${testDeps}
    ${PFUNIT_DIR}/include/driver.F90
    ${_test_sources}

    )

target_link_libraries(
    pftest_alltests
    ${PFUNIT_DIR}/lib/libpfunit.a
    )

TARGET_LINK_LIBRARIES(pftest_alltests ${AHLIB})


# add external links here
TARGET_LINK_LIBRARIES(pftest_alltests ${MKL_BLAS_LIB})

#if (${MKL_LAPACK_LIB})
      TARGET_LINK_LIBRARIES(pftest_alltests ${MKL_LAPACK_LIB})
      #endif()

if (USE_MPI)
  TARGET_LINK_LIBRARIES(pftest_alltests ${MKL_BLACS_LIB})
  TARGET_LINK_LIBRARIES(pftest_alltests ${MKL_SCALAPACK_LIB})
endif()
TARGET_LINK_LIBRARIES(pftest_alltests ${MKL_ILP_LIB})
TARGET_LINK_LIBRARIES(pftest_alltests ${MKL_THREAD_LIB})
TARGET_LINK_LIBRARIES(pftest_alltests ${MKL_CORE_LIB})


add_test(pftest_alltests ${BIN}/pftest_alltests)
INSTALL(TARGETS pftest_alltests RUNTIME DESTINATION bin)
