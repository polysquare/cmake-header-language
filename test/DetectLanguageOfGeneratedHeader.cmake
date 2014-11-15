# /test/DetectLanguageOfGeneratedHeader.cmake
#
# Adds some source files which will be detected as C source files
# and include a header in them, although that header will be a generated file.
#
# See LICENCE.md for Copyright Information.

include (DetermineHeaderLanguage)
include (CMakeUnit)

set (INCLUDE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
set (TOPLEVEL_HEADER_FILE_NAME "c/Toplevel.h")
set (TOPLEVEL_HEADER_FILE_PATH
     "${CMAKE_CURRENT_BINARY_DIR}/${TOPLEVEL_HEADER_FILE_NAME}")

cmake_unit_generate_source_file_during_build (TARGET
                                              NAME ${TOPLEVEL_HEADER_FILE_NAME})

set (C_SOURCE_FILE_NAME CSource.c)
set (C_SOURCE_FILE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${C_SOURCE_FILE_NAME}")

cmake_unit_create_source_file_before_build (NAME ${C_SOURCE_FILE_NAME}
                                            INCLUDES
                                            "${TOPLEVEL_HEADER_FILE_PATH}"
                                            INCLUDE_DIRECTORIES
                                            "${INCLUDE_DIRECTORY}")

polysquare_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}"
                                    INCLUDES "${INCLUDE_DIRECTORY}")
polysquare_determine_language_for_source ("${TOPLEVEL_HEADER_FILE_PATH}"
                                          LANGUAGE WAS_HEADER)

assert_variable_is (LANGUAGE STRING EQUAL "C")
