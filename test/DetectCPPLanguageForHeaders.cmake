# /test/DetectCPPLanguageForHeaders.cmake
#
# Adds some source files which will be detected as CPP source files
# and include a header in them, with ${CMAKE_CURRENT_BINARY_DIR}/include
# to be used as the include-directory.
#
# See LICENCE.md for Copyright Information.

include (DetermineHeaderLanguage)
include (CMakeUnit)

set (INCLUDE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include)
set (CXX_HEADER_FILE_DIRECTORY_NAME cxx)
set (TOPLEVEL_HEADER_FILE_NAME ${CXX_HEADER_FILE_DIRECTORY_NAME}/Toplevel.h)
set (TOPLEVEL_HEADER_FILE_PATH
     "${CMAKE_CURRENT_SOURCE_DIR}/${TOPLEVEL_HEADER_FILE_NAME}")

cmake_unit_create_source_file_before_build (NAME ${TOPLEVEL_HEADER_FILE_NAME})

set (CXX_SOURCE_FILE_NAME CXXSource.cxx)
set (CXX_SOURCE_FILE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${CXX_SOURCE_FILE_NAME}")

cmake_unit_create_source_file_before_build (NAME ${CXX_SOURCE_FILE_NAME}
                                            INCLUDES
                                            ${TOPLEVEL_HEADER_FILE_NAME})

polysquare_scan_source_for_headers (SOURCE "${CXX_SOURCE_FILE_PATH}"
                                    INCLUDES "${INCLUDE_DIRECTORY}")

polysquare_determine_language_for_source ("${TOPLEVEL_HEADER_FILE_PATH}"
                                          LANGUAGE WAS_HEADER)

assert_variable_is (LANGUAGE STRING EQUAL "CXX")
