# /test/SourceWasHeaderTrueForHeader.cmake
#
# Adds some source files with a header file. WAS_HEADER
# should be true for the header file.
#
# See LICENCE.md for Copyright information

include (DetermineHeaderLanguage)
include (CMakeUnit)

set (INCLUDE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include)
set (TOPLEVEL_HEADER_FILE_NAME Toplevel.h)
set (TOPLEVEL_HEADER_FILE_PATH "${TOPLEVEL_HEADER_FILE_NAME}")

cmake_unit_create_source_file_before_build (NAME ${TOPLEVEL_HEADER_FILE_NAME})

set (C_SOURCE_FILE_NAME CSource.c)
set (C_SOURCE_FILE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${C_SOURCE_FILE_NAME}")

cmake_unit_create_source_file_before_build (NAME ${C_SOURCE_FILE_NAME}
                                            INCLUDES
                                            "${TOPLEVEL_HEADER_FILE_PATH}")

polysquare_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}")
polysquare_determine_language_for_source ("${TOPLEVEL_HEADER_FILE_PATH}"
                                          LANGUAGE WAS_HEADER)

assert_true (${WAS_HEADER})
