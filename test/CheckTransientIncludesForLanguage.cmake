# /test/CheckTransientIncludesForLanguage.cmake
#
# Add source and header files in the following include hierarchy:
# Toplevel.h
# |
# -Immediate.h
#  |
#  - CSource.c
#  - CXXSource.cxx
# - CXXSource.cxx
#
# Immediate.h is included by at least one C source, so it becomes a "C"
# header. Because Immediate.h includes Toplevel.h, it also becomes a "C"
# header too, even though CXXSource.cxx includes it.
#
# See LICENCE.md for Copyright Information.

include (DetermineHeaderLanguage)
include (CMakeUnit)

set (INCLUDE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include)
set (CXX_HEADER_FILE_DIRECTORY_NAME cxx)
set (TOPLEVEL_HEADER_FILE_NAME ${CXX_HEADER_FILE_DIRECTORY_NAME}/Toplevel.h)
set (IMMEDIATE_HEADER_FILE_NAME ${CXX_HEADER_FILE_DIRECTORY_NAME}/Immediate.h)
set (TOPLEVEL_HEADER_FILE_PATH
     "${CMAKE_CURRENT_SOURCE_DIR}/${TOPLEVEL_HEADER_FILE_NAME}")
set (IMMEDIATE_HEADER_FILE_PATH
     "${CMAKE_CURRENT_SOURCE_DIR}/${IMMEDIATE_HEADER_FILE_NAME}")

cmake_unit_create_source_file_before_build (NAME ${TOPLEVEL_HEADER_FILE_NAME})
cmake_unit_create_source_file_before_build (NAME ${IMMEDIATE_HEADER_FILE_NAME}
                                            INCLUDES
                                            ${TOPLEVEL_HEADER_FILE_NAME}
                                            INCLUDE_DIRECTORIES
                                            ${INCLUDE_DIRECTORY})

set (C_SOURCE_FILE_NAME CSource.c)
set (C_SOURCE_FILE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${C_SOURCE_FILE_NAME}")
set (CXX_SOURCE_FILE_NAME CXXSource.cxx)
set (CXX_SOURCE_FILE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${CXX_SOURCE_FILE_NAME}")

cmake_unit_create_source_file_before_build (NAME ${C_SOURCE_FILE_NAME}
                                            INCLUDES
                                            ${IMMEDIATE_HEADER_FILE_NAME})
cmake_unit_create_source_file_before_build (NAME ${CXX_SOURCE_FILE_NAME}
                                            INCLUDES
                                            ${IMMEDIATE_HEADER_FILE_NAME})

polysquare_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}"
                                    INCLUDES ${INCLUDE_DIRECTORY})
polysquare_scan_source_for_headers (SOURCE "${CXX_SOURCE_FILE_PATH}"
                                    INCLUDES ${INCLUDE_DIRECTORY})

polysquare_determine_language_for_source ("${TOPLEVEL_HEADER_FILE_PATH}"
                                          LANGUAGE WAS_HEADER)

assert_variable_is (LANGUAGE STRING EQUAL "C")
