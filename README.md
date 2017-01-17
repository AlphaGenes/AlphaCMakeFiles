# README #
This holds the necessary files to find various libraries for Cmake.   This repository should be cloned into somewhere on your machine, and then never changed! (except to update once in a while :) ).

####Using CMake ####

To use CMake, the project directory needs to have 4 folders in it.   These are /src, /objs, /bin and /tests.   CMake expects all of the source files to reside in /src (all .f90 files), the test files in tests (all .pf files, testSuites.inc), puts the object and mod files in /objs (can safely be ignored) and puts the executable in /bin.


When using CMake, the various options are set using a file called CMakeLists.txt.   There are two of these.   The first gives the overall project options and lives in the main folder of your project.   The second gives the files to compile, together with any libraries that are in use.   This file resides in <projectDirectory>/src.





### Using Cmake on Mac ###

* Quick summary
* Version
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

### Using Cmake on Eddie ###

To use CMake on edd