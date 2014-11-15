# /test/BreakIncludeCyclesWhenScanningForHeaders.cmake
#
# Add source and header files in the following include hierarchy:
# Toplevel.h
# |
# -Immediate.h
#  |
#  - CXXSource.cxx
# - CXXSource.cxx
#
# Immediate.h shall also include Toplevel.h. This would technically
# create a cycle.
#
# See LICENCE.md for Copyright Information.

include (DetermineHeaderLanguage)
include (CMakeUnit)

set (INCLUDE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include)
set (CXX_HEADER_FILE_DIRECTORY_NAME cxx)
set (TOPLEVEL_HEADER_FILE ${CXX_HEADER_FILE_DIRECTORY_NAME}/Toplevel.h)
set (IMMEDIATE_HEADER_FILE ${CXX_HEADER_FILE_DIRECTORY_NAME}/Immediate.h)
set (PATH_TO_TOPLEVEL_HEADER_FILE
     "${CMAKE_CURRENT_SOURCE_DIR}/${TOPLEVEL_HEADER_FILE}")
set (PATH_TO_IMMEDIATE_HEADER_FILE
     "${CMAKE_CURRENT_SOURCE_DIR}/${IMMEDIATE_HEADER_FILE}")

cmake_unit_create_source_file_before_build (NAME ${TOPLEVEL_HEADER_FILE}
                                            INCLUDES ${IMMEDIATE_HEADER_FILE}
                                            INCLUDE_DIRECTORIES
                                            ${INCLUDE_DIRECTORY})
cmake_unit_create_source_file_before_build (NAME ${IMMEDIATE_HEADER_FILE}
                                            INCLUDES ${TOPLEVEL_HEADER_FILE}
                                            INCLUDE_DIRECTORIES
                                            ${INCLUDE_DIRECTORY})

set (CXX_SOURCE_FILE CXXSource.cxx)
set (PATH_TO_CXX_SOURCE_FILE "${CMAKE_CURRENT_SOURCE_DIR}/${CXX_SOURCE_FILE}")

cmake_unit_create_source_file_before_build (NAME ${CXX_SOURCE_FILE}
                                            INCLUDES
                                            ${IMMEDIATE_HEADER_FILE}
                                            ${TOPLEVEL_HEADER_FILE})

polysquare_scan_source_for_headers (SOURCE ${PATH_TO_CXX_SOURCE_FILE}
                                    INCLUDES ${INCLUDE_DIRECTORY})

polysquare_determine_language_for_source (${PATH_TO_TOPLEVEL_HEADER_FILE}
                                          TOPLEVEL_LANGUAGE
                                          WAS_HEADER)
polysquare_determine_language_for_source (${PATH_TO_IMMEDIATE_HEADER_FILE}
                                          IMMEDIATE_LANGUAGE
                                          WAS_HEADER)

assert_variable_is (IMMEDIATE_LANGUAGE STRING EQUAL "CXX")
assert_variable_is (TOPLEVEL_LANGUAGE STRING EQUAL "CXX")
