# add a target to generate API documentation with Doxygen
# find_package(Doxygen)
if(DOXYGEN_FOUND)
configure_file(${CMAKE_MODULE_PATH}/../../Doxygen/Doxygen.txt ${BIN}/Doxyfile @ONLY)
add_custom_target(doc
${DOXYGEN_EXECUTABLE} ${BIN}/Doxyfile
WORKING_DIRECTORY ${BIN}
COMMENT "Generating API documentation with Doxygen" VERBATIM
)
endif(DOXYGEN_FOUND)