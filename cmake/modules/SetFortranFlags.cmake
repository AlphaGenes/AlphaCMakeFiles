######################################################
# Determine and set the Fortran compiler flags we want 
######################################################

####################################################################
# Make sure that the default build type is RELEASE if not specified.
####################################################################
INCLUDE(${CMAKE_MODULE_PATH}/SetCompileFlags.cmake)

# Make sure the build type is uppercase
STRING(TOUPPER "${CMAKE_BUILD_TYPE}" BT)

IF(BT STREQUAL "RELEASE")
    SET(CMAKE_BUILD_TYPE RELEASE CACHE STRING
      "Choose the type of build, options are DEBUG, RELEASE,PROFILE,EDDIE or TESTING."
      FORCE)
ELSEIF(BT STREQUAL "DEBUG")
    SET (CMAKE_BUILD_TYPE DEBUG CACHE STRING
      "Choose the type of build, options are DEBUG, RELEASE,PROFILE,EDDIE or TESTING."
      FORCE)
ELSEIF(BT STREQUAL "DEBUG1")
    SET (CMAKE_BUILD_TYPE DEBUG CACHE STRING
      "Choose the type of build, options are DEBUG, RELEASE,PROFILE,EDDIE or TESTING."
      FORCE)
      add_definitions(-DDEBUG)
ELSEIF(BT STREQUAL "TESTING")
    SET (CMAKE_BUILD_TYPE TESTING CACHE STRING
      "Choose the type of build, options are DEBUG, RELEASE,PROFILE,EDDIE or TESTING."
      FORCE)
ELSEIF(BT STREQUAL "EDDIE")
    SET (CMAKE_BUILD_TYPE EDDIE CACHE STRING
      "Choose the type of build, options are DEBUG, RELEASE,PROFILE,EDDIE or TESTING."
      FORCE)
ELSEIF(BT STREQUAL "PROFILE")
    SET (CMAKE_BUILD_TYPE PROFILING CACHE STRING
      "Choose the type of build, options are DEBUG, RELEASE,PROFILE,EDDIE or TESTING."
      FORCE)
ELSEIF(NOT BT)
    SET(CMAKE_BUILD_TYPE RELEASE CACHE STRING
      "Choose the type of build, options are DEBUG, RELEASE,PROFILE,EDDIE or TESTING."
      FORCE)
    MESSAGE(STATUS "CMAKE_BUILD_TYPE not given, defaulting to RELEASE")
ELSE()
    MESSAGE(FATAL_ERROR "CMAKE_BUILD_TYPE not valid, choices are DEBUG, RELEASE, EDDIE, PROFILE or TESTING")
ENDIF(BT STREQUAL "RELEASE")

#########################################################
# If the compiler flags have already been set, return now
#########################################################

IF(CMAKE_Fortran_FLAGS_RELEASE AND CMAKE_Fortran_FLAGS_TESTING AND CMAKE_Fortran_FLAGS_EDDIE AND CMAKE_Fortran_FLAGS_DEBUG AND CMAKE_Fortran_FLAGS_PROFILE)
    RETURN ()
ENDIF(CMAKE_Fortran_FLAGS_RELEASE AND CMAKE_Fortran_FLAGS_TESTING AND CMAKE_Fortran_FLAGS_EDDIE AND CMAKE_Fortran_FLAGS_DEBUG AND CMAKE_Fortran_FLAGS_PROFILE)

########################################################################
# Determine the appropriate flags for this compiler for each build type.
# For each option type, a list of possible flags is given that work
# for various compilers.  The first flag that works is chosen.
# If none of the flags work, nothing is added (unless the REQUIRED 
# flag is given in the call).  This way unknown compiles are supported.
#######################################################################

#####################
### GENERAL FLAGS ###
#####################



# There is some bug where -march=native doesn't work on Mac
IF(APPLE)
    SET(GNUNATIVE "-mtune=native")
ELSE()
    SET(GNUNATIVE "-march=native")
ENDIF()


if (WIN32)
    message("Environment set to OS_WIN")
    add_definitions(-DOS_WIN)
     SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"              
                Fortran "/libs:static"
 )
    SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
                 Fortran "/static"
                )
else()
    message("Environment set to OS_UNIX")
    add_definitions(-DOS_UNIX) 
endif()

SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
                 Fortran "-static-intel"        # Intel
                )



SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
                 Fortran "-fpp"  # Intel
                         "-fpp" # Intel Windows
                )

SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
                 Fortran "-assume realloc_lhs"  # Intel
                        "-std=f2008ts"
                         "/assume:realloc_lhs" # Intel Windows
                )

SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
                 Fortran "-heap-arrays 1024"  # Intel
                         "-fno-automatic"
                         "/heap-arrays:1024" # Intel Windows
                )
if (USE_OPENMP)
message("OpenMP fortran flags: ${OpenMP_Fortran_FLAGS}")
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
                 Fortran "${OpenMP_Fortran_FLAGS}" # Intel
                )
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS}"
                 Fortran "-qopenmp-link=static" # Intel
                 "-openmp-link=static" # Intel
                )
endif()
###################
### DEBUG FLAGS ###
###################

# NOTE: debugging symbols (-g or /debug:full) are already on by default

# Disable optimizations
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG}"
                 Fortran REQUIRED "-O0" # All compilers not on Windows
                                  "/Od" # Intel Windows
                )

# Turn on all warnings 
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG}"
                 Fortran "-warn all" # Intel
                         "/warn:all" # Intel Windows
                         "-Wall"     # GNU
                                     # Portland Group (on by default)
                )

# Traceback
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG}"
                 Fortran "-traceback"   # Intel/Portland Group
                         "/traceback"   # Intel Windows
                         "-fbacktrace"  # GNU (gfortran)
                         "-ftrace=full" # GNU (g95)
                )

# Check array bounds
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG}"
                 Fortran "-check bounds"  # Intel
                         "/check:bounds"  # Intel Windows
                         "-fcheck=bounds" # GNU (New style)
                         "-fbounds-check" # GNU (Old style)
                         "-Mbounds"       # Portland Group
                )

SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG}"
                 Fortran "-fstack-protector"  # Intel
                )

SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG}"
                 Fortran "-assume protect_parens"  # Intel
                        "/assume:protect_parens"
                )
 SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG}"
                 Fortran "-implicitnone"  # Intel
                        "/assume:protect_parens"
                ) 

# SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG}"
#                  Fortran "-check all"  # Intel
#                          "/check:all"  # Intel Windows

#                 )

#####################
### TESTING FLAGS ###
#####################

# Optimizations
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_TESTING "${CMAKE_Fortran_FLAGS_TESTING}"
                 Fortran REQUIRED "-O3" # All compilers not on Windows
                                  "/O3" # Intel Windows
                )

SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_TESTING "${CMAKE_Fortran_FLAGS_TESTING}"
  Fortran "-xHost"        # Intel
  "/QxHost"       # Intel Windows

)


if (APPLE)
# SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_TESTING "${CMAKE_Fortran_FLAGS_TESTING}"
#   Fortran "-finstrument-functions -g -save-temps")
elseif(WIN32)


else()
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_TESTING "${CMAKE_Fortran_FLAGS_TESTING}"
  Fortran "-finstrument-functions -g")
endif()
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_TESTING "${CMAKE_Fortran_FLAGS_TESTING}"
                 Fortran "-traceback"   # Intel/Portland Group
                         "/traceback"   # Intel Windows
                         "-fbacktrace"  # GNU (gfortran)
                         "-ftrace=full" # GNU (g95)
                )


# Unroll loops
# SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_TESTING "${CMAKE_Fortran_FLAGS_TESTING}"
#                  Fortran "-funroll-loops" # GNU
#                          "-unroll"        # Intel
#                          "/unroll"        # Intel Windows
#                          "-Munroll"       # Portland Group
#                 )

# Single-file optimizations
# SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_TESTING "${CMAKE_Fortran_FLAGS_TESTING}"
#                  Fortran "-g"  # Intel
#                          "/Qg" # Intel Windows
#                 )
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_TESTING "${CMAKE_Fortran_FLAGS_TESTING}"
                   Fortran "-traceback"   # Intel/Portland Group
                         "/traceback"   # Intel Windows
                         "-fbacktrace"  # GNU (gfortran)
                         "-ftrace=full" # GNU (g95)
                )
# SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_TESTING "${CMAKE_Fortran_FLAGS_TESTING}"
#                    Fortran "-Xlinker -M"   # Intel/Portland Group
#                          "/map"   # Intel Windows
#                 )



#####################
### TESTING FLAGS ###
#####################

# Optimizations
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_EDDIE "${CMAKE_Fortran_FLAGS_EDDIE}"
                 Fortran REQUIRED "-O3" # All compilers not on Windows
                                  "/O3" # Intel Windows
                )
 SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_EDDIE "${CMAKE_Fortran_FLAGS_EDDIE}"
   Fortran "-xAVX"        # Intel
   "/QxAVX"       # Intel Windows
                          ${GNUNATIVE}    # GNU
                          "-ta=host"      # Portland Group
                 )

SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_EDDIE "${CMAKE_Fortran_FLAGS_EDDIE}"
                 Fortran "-traceback"   # Intel/Portland Group
                         "/traceback"   # Intel Windows
                         "-fbacktrace"  # GNU (gfortran)
                         "-ftrace=full" # GNU (g95)
                )


# Unroll loops
#SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_EDDIE "${CMAKE_Fortran_FLAGS_EDDIE}"
                 ##Fortran "-funroll-loops" # GNU
                         #"-unroll"        # Intel
                         #"/unroll"        # Intel Windows
                         #"-Munroll"       # Portland Group
                #)

# Single-file optimizations
# SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_EDDIE "${CMAKE_Fortran_FLAGS_EDDIE}"
#                  Fortran "-g"  # Intel
#                          "/Qg" # Intel Windows
#                 )
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_EDDIE "${CMAKE_Fortran_FLAGS_EDDIE}"
                   Fortran "-Xlinker -M"   # Intel/Portland Group
                         "/map"   # Intel Windows
                )
#SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_EDDIE "${CMAKE_Fortran_FLAGS_EDDIE}"
                 #Fortran "-p")


#####################
### PROFILEFLAGS ###
#####################
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_PROFILE "${CMAKE_Fortran_FLAGS_PROFILE}"
                 Fortran "-p")
#####################
### RELEASE FLAGS ###
#####################

SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE}"
                 Fortran REQUIRED "-O3" # All compilers not on Windows
                                  "/O3" # Intel Windows
                )

SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE}"
                 Fortran REQUIRED "-ip" # All compilers not on Windows
                                  "/Qip" # Intel Windows
                )

SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE}"
                 Fortran "-fp-model fast"            # Intel
                         "/fp:fast"           # Intel Windows
                )

SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE}"
                 Fortran "-march=ivybridge"            # Intel
                )

                SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE}"
                 Fortran "-traceback"   # Intel/Portland Group
                         "/traceback"   # Intel Windows
                         "-fbacktrace"  # GNU (gfortran)
                         "-ftrace=full" # GNU (g95)
                )


# Unroll loops
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE}"
                 Fortran "-funroll-loops" # GNU
                         "-unroll"        # Intel
                         "/unroll"        # Intel Windows
                         "-Munroll"       # Portland Group
                )

# Inline functions
SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE}"
                 Fortran "-inline"            # Intel
                         "/Qinline"           # Intel Windows
                         "-finline-functions" # GNU
                         "-Minline"           # Portland Group
                )


if (HDF5PATH)
    SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS  "${CMAKE_Fortran_FLAGS}"
                    Fortran "-L${HDF5PATH}lib -I${HDF5PATH}include -lhdf5_fortran -lhdf5"
                    )
endif(HDF5PATH) 

if (MKL_FOUND)
    SET_COMPILE_FLAG(CMAKE_Fortran_FLAGS  "${CMAKE_Fortran_FLAGS}"
                    Fortran "-L${MKL_ROOT_LIB} -I${MKL_INCLUDE_DIRS} -mkl"
                    "-L${MKL_ROOT_LIB} -I${MKL_INCLUDE_DIRS}"
                    "/Qmkl"
                    )

endif(MKL_FOUND) 

message("flags: ${CMAKE_Fortran_FLAGS}")
