# Turns on either OpenMP or MPI
# If both are requested, the other is disabled
# When one is turned on, the other is turned off
# If both are off, we explicitly disable them just in case
OPTION(CHECK_PARA "Check if paralellization works" ON)
IF (USE_OPENMP)

    # Find OpenMP
    INCLUDE(${CMAKE_MODULE_PATH}/FindOpenMP_Fortran.cmake)
    IF (NOT OpenMP_Fortran_FLAGS)
        FIND_PACKAGE (OpenMP_Fortran)
        IF (NOT OpenMP_Fortran_FLAGS)
            MESSAGE (FATAL_ERROR "Fortran compiler does not support OpenMP")
        ENDIF (NOT OpenMP_Fortran_FLAGS)
    ENDIF (NOT OpenMP_Fortran_FLAGS)
    # Turn of MPI
    UNSET (MPI_FOUND CACHE)
    UNSET (MPI_COMPILER CACHE)
    UNSET (MPI_LIBRARY CACHE)
ELSE ()
    # Turn off both OpenMP and MPI
    SET (OMP_NUM_PROCS 0 CACHE
         STRING "Number of processors OpenMP may use" FORCE)
    UNSET (OpenMP_Fortran_FLAGS CACHE)
    UNSET (GOMP_Fortran_LINK_FLAGS CACHE)
    UNSET (MPI_FOUND CACHE)
    UNSET (MPI_COMPILER CACHE)
    UNSET (MPI_LIBRARY CACHE)
ENDIF (USE_OPENMP)

IF (USE_MPI)
    # Find MPI
    IF (NOT MPI_Fortran_FOUND)
        FIND_PACKAGE (MPI REQUIRED)
        # include(FindMPI)
    ENDIF (NOT MPI_Fortran_FOUND)
    MESSAGE (STATUS "MPI FOUND:: ${MPI_FOUND}")
    MESSAGE (STATUS "MPI COMPILER:: ${MPI_LIBRARIES}")

    add_definitions(-DMPIACTIVE)
    add_definitions(-DUSE_MPI)
    # Turn off OpenMP
    # SET FLAGS!

    # set(CMAKE_CXX_COMPILER "/home/lola/Packages/mpich2-1.3.2p1/bin/mpicxx")
    # set(CMAKE_C_COMPILER "/home/lola/Packages/mpich2-1.3.2p1/bin/mpicc")


    SET (OMP_NUM_PROCS 8 CACHE
         STRING "Number of processors OpenMP may use" FORCE)
    UNSET (OpenMP_C_FLAGS CACHE)
    UNSET (GOMP_Fortran_LINK_FLAGS CACHE)
ENDIF (USE_MPI)
