# /test/LanguageForcedByOption.cmake
#
# Adds some source files which will be detected as C source files
# and include a header in them, with ${CMAKE_CURRENT_BINARY_DIR}/include
# to be used as the include-directory.
#
# Force the language to CXX. The header should still be marked as a
# header, but the langauge will be CXX.
#
# See LICENCE.md for Copyright Information.

include (DetermineHeaderLanguage)
include (CMakeUnit)

set (INCLUDE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include)
set (C_HEADER_FILE_DIRECTORY_NAME cxx)
set (TOPLEVEL_HEADER_FILE_NAME ${C_HEADER_FILE_DIRECTORY_NAME}/Toplevel.h)
set (TOPLEVEL_HEADER_FILE_PATH
     "${CMAKE_CURRENT_SOURCE_DIR}/${TOPLEVEL_HEADER_FILE_NAME}")

cmake_unit_create_source_file_before_build (NAME ${TOPLEVEL_HEADER_FILE_NAME})

set (C_SOURCE_FILE_NAME CSource.c)
set (C_SOURCE_FILE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${C_SOURCE_FILE_NAME}")

cmake_unit_create_source_file_before_build (NAME ${C_SOURCE_FILE_NAME}
                                            INCLUDES
                                            ${TOPLEVEL_HEADER_FILE_NAME})

polysquare_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}"
                                    INCLUDES "${INCLUDE_DIRECTORY}")
polysquare_determine_language_for_source ("${TOPLEVEL_HEADER_FILE_PATH}"
                                          LANGUAGE WAS_HEADER
                                          FORCE_LANGUAGE CXX)

assert_variable_is (${LANGUAGE} STRING EQUAL "CXX")
assert_true (${WAS_HEADER})
