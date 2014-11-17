# /test/ScanForBothWithCustomCPPIdentifierAndCSourceFirst.cmake
#
# Adds some source files which will be detected as C and CXX source files
# and include a header in them, with ${CMAKE_CURRENT_BINARY_DIR}/include
# to be used as the include-directory.
#
# The CXX source will come after the C source. This will test that a later
# determination that a header is CXX after being marked mixed mode
# won't change its mixed mode status.
#
# Add POLYSQUARE_BEGIN_DECLS to the header file and let
# cppcheck_target_sources know about that identifier. This shall make it scanned
# in both modes
#
# See LICENCE.md for Copyright information

include (DetermineHeaderLanguage)
include (CMakeUnit)

set (INCLUDE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
set (C_HEADER_FILE_DIRECTORY_NAME "c")
set (DECLS_HEADER_FILE_NAME "${C_HEADER_FILE_DIRECTORY_NAME}/decls.h")
set (DECLS_HEADER_FILE_PATH "${INCLUDE_DIRECTORY}/${DECLS_HEADER_FILE_NAME}")
set (BOTH_HEADER_FILE_NAME "${C_HEADER_FILE_DIRECTORY_NAME}/both.h")
set (BOTH_HEADER_FILE_PATH "${INCLUDE_DIRECTORY}/${BOTH_HEADER_FILE_NAME}")
set (C_HEADER_FILE_NAME "${C_HEADER_FILE_DIRECTORY}/c.h")
set (C_HEADER_FILE_PATH "${INCLUDE_DIRECTORY}/${C_HEADER_FILE_NAME}")

set (C_SOURCE_FILE_NAME "CSource.c")
set (C_SOURCE_FILE_PATH
     "${CMAKE_CURRENT_SOURCE_DIR}/${C_SOURCE_FILE_NAME}")
set (CXX_SOURCE_FILE_NAME "CPPSource.cpp")
set (CXX_SOURCE_FILE_PATH
     "${CMAKE_CURRENT_SOURCE_DIR}/${CXX_SOURCE_FILE_NAME}")

cmake_unit_create_source_file_before_build (NAME "${DECLS_HEADER_FILE_NAME}"
                                            DEFINES "POLYSQUARE_IS_CPP")
cmake_unit_create_source_file_before_build (NAME "${BOTH_HEADER_FILE_NAME}"
                                            DEFINES "POLYSQUARE_IS_CPP"
                                            INCLUDES
                                            "${DECLS_HEADER_FILE_PATH}"
                                            INCLUDE_DIRECTORIES
                                            "${INCLUDE_DIRECTORY}")
cmake_unit_create_source_file_before_build (NAME "${C_HEADER_FILE_NAME}")
cmake_unit_create_source_file_before_build (NAME "${C_SOURCE_FILE_NAME}"
                                            INCLUDES
                                            "${BOTH_HEADER_FILE_PATH}"
                                            "${C_HEADER_FILE_PATH}"
                                            INCLUDE_DIRECTORIES
                                            "${INCLUDE_DIRECTORY}")
cmake_unit_create_source_file_before_build (NAME "${CXX_SOURCE_FILE_NAME}"
                                            INCLUDES
                                            "${BOTH_HEADER_FILE_PATH}"
                                            "${C_HEADER_FILE_PATH}"
                                            INCLUDE_DIRECTORIES
                                            "${INCLUDE_DIRECTORY}")

polysquare_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}"
                                    INCLUDES "${INCLUDE_DIRECTORY}"
                                    CPP_IDENTIFIERS
                                    POLYSQUARE_IS_CPP)

polysquare_scan_source_for_headers (SOURCE "${CXX_SOURCE_FILE_PATH}"
                                    INCLUDES "${INCLUDE_DIRECTORY}"
                                    CPP_IDENTIFIERS
                                    POLYSQUARE_IS_CPP)

polysquare_determine_language_for_source ("${BOTH_HEADER_FILE_PATH}"
                                          LANGUAGE WAS_HEADER)

assert_list_contains_value (LANGUAGE STRING EQUAL "C")
assert_list_contains_value (LANGUAGE STRING EQUAL "CXX")
