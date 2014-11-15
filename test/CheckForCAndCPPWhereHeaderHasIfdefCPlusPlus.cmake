# /test/CheckForCAndCPPWhereHeaderHasIfdefCPlusPlus.cmake
#
# Adds some source files which will be detected as C source files
# and include a header in them, with ${CMAKE_CURRENT_BINARY_DIR}/include
# to be used as the include-directory.
#
# Add #ifdef __cplusplus to the header file. This shall make it scanned
# in both modes
#
# See LICENCE.md for Copyright Information.

include (DetermineHeaderLanguage)
include (CMakeUnit)

set (INCLUDE_DIRECTORY
     ${CMAKE_CURRENT_BINARY_DIR}/include)
set (C_HEADER_FILE_DIRECTORY_NAME c)
set (BOTH_HEADER_FILE_NAME ${C_HEADER_FILE_DIRECTORY_NAME}/both.h)
set (BOTH_HEADER_FILE_PATH
     "${CMAKE_CURRENT_SOURCE_DIR}/${BOTH_HEADER_FILE_NAME}")
set (C_HEADER_FILE_NAME ${C_HEADER_FILE_DIRECTORY}/c.h)
set (C_HEADER_FILE_PATH
     "${CMAKE_CURRENT_SOURCE_DIR}/${C_HEADER_FILE_NAME}")

cmake_unit_create_source_file_before_build (NAME ${BOTH_HEADER_FILE_NAME}
                                            PREPEND_CONTENTS
                                            "#ifdef __cplusplus\n"
                                            "#endif")
cmake_unit_create_source_file_before_build (NAME ${C_HEADER_FILE_NAME})

set (C_SOURCE_FILE_NAME CSource.c)
set (C_SOURCE_FILE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${C_SOURCE_FILE_NAME}")

cmake_unit_create_source_file_before_build (NAME ${C_SOURCE_FILE_NAME}
                                            INCLUDES
                                            "${BOTH_HEADER_FILE_NAME}"
                                            "${C_HEADER_FILE_NAME}"
                                            INCLUDE_DIRECTORIES
                                            "${INCLUDE_DIRECTORY}")

polysquare_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}"
                                    INCLUDES ${INCLUDE_DIRECTORY})

polysquare_determine_language_for_source ("${BOTH_HEADER_FILE_PATH}"
                                          LANGUAGE WAS_HEADER)

assert_list_contains_value (LANGUAGE STRING EQUAL "C")
assert_list_contains_value (LANGUAGE STRING EQUAL "CXX")
