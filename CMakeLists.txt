# /CMakeLists.txt
#
# Main entry point for PolysquareCMakeHeaderLanguageTests tests.
#
# See /LICENCE.md for Copyright information
include ("${CMAKE_CURRENT_LIST_DIR}/conanbuildinfo.cmake")
set (_CURRENT_LIST_FILE "${CMAKE_CURRENT_LIST_FILE}")
set (CMAKE_MODULE_PATH
     "${CMAKE_CURRENT_LIST_DIR}"
     ${CONAN_CMAKE_MODULE_PATH}  # NOLINT:correctness/quotes
     ${CMAKE_MODULE_PATH})  # NOLINT:correctness/quotes

cmake_minimum_required (VERSION 2.8)

include ("cmake/cmake-unit/CMakeUnitRunner")
include ("cmake/cmake-unit/CMakeUnit")
include (DetermineHeaderLanguage)

# Add source and header files in the following include hierarchy:
# /Toplevel.h
# |
# - /Immediate.h
#  |
#  - /CXXSource.cxx
# - /CXXSource.cxx
function (psq_test_break_include_cycles_when_scanning_for_headers)

    function (psq_configure)

        set (INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")
        set (CXX_HEADER_FILE_DIRECTORY_NAME cxx)
        set (TOPLEVEL_HEADER "${CXX_HEADER_FILE_DIRECTORY_NAME}/Toplevel.h")
        set (IMMEDIATE_HEADER
             "${CXX_HEADER_FILE_DIRECTORY_NAME}/Immediate.h")
        set (PATH_TO_TOPLEVEL_HEADER
             "${CMAKE_CURRENT_SOURCE_DIR}/${TOPLEVEL_HEADER}")
        set (PATH_TO_IMMEDIATE_HEADER
             "${CMAKE_CURRENT_SOURCE_DIR}/${IMMEDIATE_HEADER}")

        cmake_unit_create_source_file_before_build (NAME
                                                    "${TOPLEVEL_HEADER}"
                                                    INCLUDES
                                                    "${IMMEDIATE_HEADER}"
                                                    INCLUDE_DIRECTORIES
                                                    "${INCLUDE_DIR}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_create_source_file_before_build (NAME
                                                    "${IMMEDIATE_HEADER}"
                                                    INCLUDES
                                                    "${TOPLEVEL_HEADER}"
                                                    INCLUDE_DIRECTORIES
                                                    "${INCLUDE_DIR}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        set (CXX_SOURCE_FILE CXXSource.cxx)
        set (PATH_TO_CXX_SOURCE_FILE
             "${CMAKE_CURRENT_SOURCE_DIR}/${CXX_SOURCE_FILE}")

        cmake_unit_create_source_file_before_build (NAME "${CXX_SOURCE_FILE}"
                                                    INCLUDES
                                                    "${IMMEDIATE_HEADER}"
                                                    "${TOPLEVEL_HEADER}")

        psq_scan_source_for_headers (SOURCE "${PATH_TO_CXX_SOURCE_FILE}"
                                     INCLUDES "${INCLUDE_DIR}")
        psq_determine_language_for_source ("${PATH_TO_TOPLEVEL_HEADER}"
                                           TOPLEVEL_LANGUAGE WAS_HEADER)
        psq_determine_language_for_source ("${PATH_TO_IMMEDIATE_HEADER}"
                                           IMMEDIATE_LANGUAGE WAS_HEADER)

        cmake_unit_assert_that (IMMEDIATE_LANGUAGE
                                compare_as STRING EQUAL "CXX")
        cmake_unit_assert_that (TOPLEVEL_LANGUAGE
                                compare_as STRING EQUAL "CXX")

    endfunction ()

    cmake_unit_configure_test (CONFIGURE COMMAND psq_configure
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX)

endfunction ()

# Adds some source files which will be detected as C source files
# and include a header in them, with ${CMAKE_CURRENT_BINARY_DIR}/include
# to be used as the include-directory.
function (psq_test_check_for_c_and_cpp_where_header_has_ifdef_c_plus_plus)

    function (psq_configure)

        set (INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/include")
        set (C_HEADER_FILE_DIRECTORY_NAME c)
        set (BOTH_HEADER_FILE_NAME "${C_HEADER_FILE_DIRECTORY_NAME}/both.h")
        set (BOTH_HEADER_FILE_PATH
             "${CMAKE_CURRENT_SOURCE_DIR}/${BOTH_HEADER_FILE_NAME}")
        set (C_HEADER_FILE_NAME "${C_HEADER_FILE_DIRECTORY}/c.h")

        cmake_unit_create_source_file_before_build (NAME
                                                    ${BOTH_HEADER_FILE_NAME}
                                                    PREPEND_CONTENTS
                                                    "#ifdef __cplusplus\n"
                                                    "#endif"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_create_source_file_before_build (NAME ${C_HEADER_FILE_NAME}
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        set (C_SOURCE_FILE_NAME CSource.c)
        set (C_SOURCE_FILE_PATH
             "${CMAKE_CURRENT_SOURCE_DIR}/${C_SOURCE_FILE_NAME}")

        cmake_unit_create_source_file_before_build (NAME ${C_SOURCE_FILE_NAME}
                                                    INCLUDES
                                                    "${BOTH_HEADER_FILE_NAME}"
                                                    "${C_HEADER_FILE_NAME}"
                                                    INCLUDE_DIRECTORIES
                                                    "${INCLUDE_DIR}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        psq_scan_source_for_headers (SOURCE
                                     "${C_SOURCE_FILE_PATH}"
                                     INCLUDES
                                     "${INCLUDE_DIR}")
        psq_determine_language_for_source ("${BOTH_HEADER_FILE_PATH}"
                                           LANGUAGE
                                           WAS_HEADER)

        cmake_unit_assert_that (LANGUAGE list_contains_value STRING EQUAL "C")
        cmake_unit_assert_that (LANGUAGE list_contains_value STRING EQUAL "CXX")

    endfunction ()

    cmake_unit_configure_test (CONFIGURE COMMAND psq_configure
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX)

endfunction ()

# Add source and header files in the following include hierarchy:
# /Toplevel.h
# |
# - /Immediate.h
#  |
#  - /CSource.c
#  - /CXXSource.cxx
# - /CXXSource.cxx
function (psq_test_check_transient_includes_for_language)

    function (psq_configure)

        set (INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")
        set (CXX_HEADER_FILE_DIRECTORY_NAME cxx)
        set (TOPLEVEL_HEADER_NAME
             "${CXX_HEADER_FILE_DIRECTORY_NAME}/Toplevel.h")
        set (IMMEDIATE_HEADER_NAME
             "${CXX_HEADER_FILE_DIRECTORY_NAME}/Immediate.h")
        set (TOPLEVEL_HEADER_PATH
             "${CMAKE_CURRENT_SOURCE_DIR}/${TOPLEVEL_HEADER_NAME}")

        cmake_unit_create_source_file_before_build (NAME
                                                    ${TOPLEVEL_HEADER_NAME}
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_create_source_file_before_build (NAME
                                                    ${IMMEDIATE_HEADER_NAME}
                                                    INCLUDES
                                                    ${TOPLEVEL_HEADER_NAME}
                                                    INCLUDE_DIRECTORIES
                                                    "${INCLUDE_DIR}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        set (C_SOURCE_FILE_NAME CSource.c)
        set (C_SOURCE_FILE_PATH
             "${CMAKE_CURRENT_SOURCE_DIR}/${C_SOURCE_FILE_NAME}")
        set (CXX_SOURCE_FILE_NAME CXXSource.cxx)
        set (CXX_SOURCE_FILE_PATH
             "${CMAKE_CURRENT_SOURCE_DIR}/${CXX_SOURCE_FILE_NAME}")

        cmake_unit_create_source_file_before_build (NAME ${C_SOURCE_FILE_NAME}
                                                    INCLUDES
                                                    ${IMMEDIATE_HEADER_NAME}
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_create_source_file_before_build (NAME
                                                    ${CXX_SOURCE_FILE_NAME}
                                                    INCLUDES
                                                    ${IMMEDIATE_HEADER_NAME}
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        psq_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}"
                                     INCLUDES "${INCLUDE_DIR}")
        psq_scan_source_for_headers (SOURCE "${CXX_SOURCE_FILE_PATH}"
                                     INCLUDES "${INCLUDE_DIR}")
        psq_determine_language_for_source ("${TOPLEVEL_HEADER_PATH}"
                                           LANGUAGE WAS_HEADER)

        cmake_unit_assert_that (LANGUAGE compare_as STRING EQUAL "C")

    endfunction ()

    cmake_unit_configure_test (CONFIGURE COMMAND psq_configure
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX)

endfunction ()

# Adds some source files which will be detected as C source files
# and include a header in them, with ${CMAKE_CURRENT_BINARY_DIR}/include
# to be used as the include-directory.
function (psq_test_default_to_c_language_for_headers)

    function (psq_configure)
        set (C_HEADER_FILE_DIRECTORY_NAME c)
        set (TOPLEVEL_HEADER_NAME
             "${C_HEADER_FILE_DIRECTORY_NAME}/Toplevel.h")
        set (TOPLEVEL_HEADER_PATH
             "${CMAKE_CURRENT_SOURCE_DIR}/${TOPLEVEL_HEADER_NAME}")

        cmake_unit_create_source_file_before_build (NAME
                                                    ${TOPLEVEL_HEADER_NAME}
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        set (C_SOURCE_FILE_NAME CSource.c)
        set (C_SOURCE_FILE_PATH
             "${CMAKE_CURRENT_SOURCE_DIR}/${C_SOURCE_FILE_NAME}")
        set (CXX_SOURCE_FILE_NAME CXXSource.cxx)
        set (CXX_SOURCE_FILE_PATH
             "${CMAKE_CURRENT_SOURCE_DIR}/${CXX_SOURCE_FILE_NAME}")

        cmake_unit_create_source_file_before_build (NAME ${C_SOURCE_FILE_NAME}
                                                    INCLUDES
                                                    ${TOPLEVEL_HEADER_NAME}
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_create_source_file_before_build (NAME ${CXX_SOURCE_FILE_NAME}
                                                    INCLUDES
                                                    ${TOPLEVEL_HEADER_NAME}
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        psq_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}"
                                     INCLUDES "${TOPLEVEL_HEADER_NAME}")
        psq_scan_source_for_headers (SOURCE "${CXX_SOURCE_FILE_PATH}"
                                     INCLUDES "${TOPLEVEL_HEADER_NAME}")
        psq_determine_language_for_source ("${TOPLEVEL_HEADER_PATH}"
                                           LANGUAGE WAS_HEADER)

        cmake_unit_assert_that (LANGUAGE compare_as STRING EQUAL "C")

    endfunction ()

    cmake_unit_configure_test (CONFIGURE COMMAND psq_configure
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX)

endfunction ()

# Adds some source files which will be detected as C source files
# and include a header in them, with ${CMAKE_CURRENT_BINARY_DIR}/include
# to be used as the include-directory.
function (psq_test_detect_c_language_for_headers)

    function (psq_configure)

        set (INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")
        set (SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
        set (C_HEADER_FILE_DIRECTORY_NAME c)
        set (TOPLEVEL_HEADER_NAME
             "${C_HEADER_FILE_DIRECTORY_NAME}/Toplevel.h")
        set (TOPLEVEL_HEADER_PATH
             "${SOURCE_DIR}/${TOPLEVEL_HEADER_NAME}")

        cmake_unit_create_source_file_before_build (NAME
                                                    ${TOPLEVEL_HEADER_NAME}
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        set (C_SOURCE_FILE_NAME CSource.c)
        set (C_SOURCE_FILE_PATH "${SOURCE_DIR}/${C_SOURCE_FILE_NAME}")

        cmake_unit_create_source_file_before_build (NAME ${C_SOURCE_FILE_NAME}
                                                    INCLUDES
                                                    "${TOPLEVEL_HEADER_NAME}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        psq_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}"
                                     INCLUDES "${INCLUDE_DIR}")
        psq_determine_language_for_source ("${TOPLEVEL_HEADER_PATH}"
                                           LANGUAGE WAS_HEADER)

        cmake_unit_assert_that (LANGUAGE compare_as STRING EQUAL "C")

    endfunction ()

    cmake_unit_configure_test (CONFIGURE COMMAND psq_configure
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX)

endfunction ()

# Adds some source files which will be detected as C source files
# and include a header in them, with the current source directory used as
# the include directory automatically
function (psq_test_detect_c_language_for_headers_when_include_in_quotes)

    function (psq_configure)

        set (SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
        set (TOPLEVEL_HEADER_NAME Toplevel.h)
        set (TOPLEVEL_HEADER_PATH "${TOPLEVEL_HEADER_NAME}")

        cmake_unit_create_source_file_before_build (NAME
                                                    ${TOPLEVEL_HEADER_NAME}
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        set (C_SOURCE_FILE_NAME CSource.c)
        set (C_SOURCE_FILE_PATH "${SOURCE_DIR}/${C_SOURCE_FILE_NAME}")

        cmake_unit_create_source_file_before_build (NAME ${C_SOURCE_FILE_NAME}
                                                    INCLUDES
                                                    "${TOPLEVEL_HEADER_PATH}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        psq_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}")
        psq_determine_language_for_source ("${TOPLEVEL_HEADER_PATH}"
                                           LANGUAGE WAS_HEADER)

        cmake_unit_assert_that (LANGUAGE compare_as STRING EQUAL "C")

    endfunction ()

    cmake_unit_configure_test (CONFIGURE COMMAND psq_configure
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX)

endfunction ()

# Adds some source files which will be detected as CPP source files
# and include a header in them, with ${CMAKE_CURRENT_BINARY_DIR}/include
# to be used as the include-directory.
function (psq_test_detect_cpp_language_for_headers)

    function (psq_configure)

        set (INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")
        set (SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
        set (CXX_HEADER_FILE_DIRECTORY_NAME cxx)
        set (TOPLEVEL_HEADER_NAME
             "${CXX_HEADER_FILE_DIRECTORY_NAME}/Toplevel.h")
        set (TOPLEVEL_HEADER_PATH
             "${SOURCE_DIR}/${TOPLEVEL_HEADER_NAME}")

        cmake_unit_create_source_file_before_build (NAME
                                                    ${TOPLEVEL_HEADER_NAME}
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        set (CXX_SOURCE_FILE_NAME CXXSource.cxx)
        set (CXX_SOURCE_FILE_PATH "${SOURCE_DIR}/${CXX_SOURCE_FILE_NAME}")

        cmake_unit_create_source_file_before_build (NAME ${CXX_SOURCE_FILE_NAME}
                                                    INCLUDES
                                                    ${TOPLEVEL_HEADER_NAME}
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        psq_scan_source_for_headers (SOURCE "${CXX_SOURCE_FILE_PATH}"
                                     INCLUDES "${INCLUDE_DIR}")
        psq_determine_language_for_source ("${TOPLEVEL_HEADER_PATH}"
                                           LANGUAGE WAS_HEADER)

        cmake_unit_assert_that (LANGUAGE compare_as STRING EQUAL "CXX")

    endfunction ()

    cmake_unit_configure_test (CONFIGURE COMMAND psq_configure
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX)

endfunction ()

# Adds some source files which will be detected as C source files
# and include a header in them, although that header will be a generated file.
function (psq_test_detect_language_of_generated_header)

    function (psq_configure)

        set (INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
        set (SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
        set (TOPLEVEL_HEADER_NAME "c/Toplevel.h")
        set (TOPLEVEL_HEADER_PATH "${INCLUDE_DIR}/${TOPLEVEL_HEADER_NAME}")

        cmake_unit_generate_source_file_during_build (TARGET
                                                      NAME
                                                      ${TOPLEVEL_HEADER_NAME})

        set (C_SOURCE_FILE_NAME CSource.c)
        set (C_SOURCE_FILE_PATH "${SOURCE_DIR}/${C_SOURCE_FILE_NAME}")

        cmake_unit_create_source_file_before_build (NAME ${C_SOURCE_FILE_NAME}
                                                    INCLUDES
                                                    "${TOPLEVEL_HEADER_PATH}"
                                                    INCLUDE_DIRECTORIES
                                                    "${INCLUDE_DIR}")

        psq_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}"
                                     INCLUDES "${INCLUDE_DIR}")
        psq_determine_language_for_source ("${TOPLEVEL_HEADER_PATH}"
                                           LANGUAGE WAS_HEADER)

        cmake_unit_assert_that (LANGUAGE compare_as STRING EQUAL "C")

    endfunction ()

    cmake_unit_configure_test (CONFIGURE COMMAND psq_configure
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX)

endfunction ()

# Adds some source files which will be detected as C source files
# and include a header in them, with ${CMAKE_CURRENT_BINARY_DIR}/include
# to be used as the include-directory.
function (psq_test_language_forced_by_option)

    function (psq_configure)

        set (INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/include")
        set (SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
        set (C_HEADER_FILE_DIRECTORY_NAME cxx)
        set (TOPLEVEL_HEADER_NAME
             "${C_HEADER_FILE_DIRECTORY_NAME}/Toplevel.h")
        set (TOPLEVEL_HEADER_PATH
             "${SOURCE_DIR}/${TOPLEVEL_HEADER_NAME}")

        cmake_unit_create_source_file_before_build (NAME
                                                    ${TOPLEVEL_HEADER_NAME}
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        set (C_SOURCE_FILE_NAME CSource.c)
        set (C_SOURCE_FILE_PATH "${SOURCE_DIR}/${C_SOURCE_FILE_NAME}")

        cmake_unit_create_source_file_before_build (NAME ${C_SOURCE_FILE_NAME}
                                                    INCLUDES
                                                    ${TOPLEVEL_HEADER_NAME}
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        psq_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}"
                                     INCLUDES "${INCLUDE_DIR}")
        psq_determine_language_for_source ("${TOPLEVEL_HEADER_PATH}"
                                           LANGUAGE WAS_HEADER
                                           FORCE_LANGUAGE CXX)

        cmake_unit_assert_that (LANGUAGE compare_as STRING EQUAL "CXX")
        cmake_unit_assert_that (WAS_HEADER is_true)

    endfunction ()

    cmake_unit_configure_test (CONFIGURE COMMAND psq_configure
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX)

endfunction ()

# Adds some source files which will be detected as C source files
# and include a header in them, with ${CMAKE_CURRENT_BINARY_DIR}/include
# to be used as the include-directory.
function (psq_test_scan_for_both_with_custom_cpp_identifier)

    function (psq_configure)

        set (INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
        set (SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
        set (C_HEADER_FILE_DIRECTORY_NAME "c")
        set (DECLS_HEADER_FILE_NAME "${C_HEADER_FILE_DIRECTORY_NAME}/decls.h")
        set (DECLS_HEADER_FILE_PATH "${INCLUDE_DIR}/${DECLS_HEADER_FILE_NAME}")
        set (BOTH_HEADER_FILE_NAME "${C_HEADER_FILE_DIRECTORY_NAME}/both.h")
        set (BOTH_HEADER_FILE_PATH "${INCLUDE_DIR}/${BOTH_HEADER_FILE_NAME}")
        set (C_HEADER_FILE_NAME "${C_HEADER_FILE_DIRECTORY}/c.h")
        set (C_HEADER_FILE_PATH "${INCLUDE_DIR}/${C_HEADER_FILE_NAME}")
        set (C_SOURCE_FILE_NAME "CSource.c")
        set (C_SOURCE_FILE_PATH "${SOURCE_DIR}/${C_SOURCE_FILE_NAME}")
        set (CXX_SOURCE_FILE_NAME "CPPSource.cpp")
        set (CXX_SOURCE_FILE_PATH "${SOURCE_DIR}/${CXX_SOURCE_FILE_NAME}")

        cmake_unit_create_source_file_before_build (NAME
                                                    "${DECLS_HEADER_FILE_NAME}"
                                                    DEFINES "psq_IS_CPP"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_create_source_file_before_build (NAME
                                                    "${BOTH_HEADER_FILE_NAME}"
                                                    DEFINES "psq_IS_CPP"
                                                    INCLUDES
                                                    "${DECLS_HEADER_FILE_PATH}"
                                                    INCLUDE_DIRECTORIES
                                                    "${INCLUDE_DIR}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_create_source_file_before_build (NAME "${C_HEADER_FILE_NAME}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_create_source_file_before_build (NAME "${C_SOURCE_FILE_NAME}"
                                                    INCLUDES
                                                    "${BOTH_HEADER_FILE_PATH}"
                                                    "${C_HEADER_FILE_PATH}"
                                                    INCLUDE_DIRECTORIES
                                                    "${INCLUDE_DIR}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_create_source_file_before_build (NAME
                                                    "${CXX_SOURCE_FILE_NAME}"
                                                    INCLUDES
                                                    "${BOTH_HEADER_FILE_PATH}"
                                                    "${C_HEADER_FILE_PATH}"
                                                    INCLUDE_DIRECTORIES
                                                    "${INCLUDE_DIR}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        psq_scan_source_for_headers (SOURCE "${CXX_SOURCE_FILE_PATH}"
                                     INCLUDES "${INCLUDE_DIR}"
                                     CPP_IDENTIFIERS psq_IS_CPP)
        psq_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}"
                                     INCLUDES "${INCLUDE_DIR}"
                                     CPP_IDENTIFIERS psq_IS_CPP)
        psq_determine_language_for_source ("${BOTH_HEADER_FILE_PATH}"
                                           LANGUAGE WAS_HEADER)

        cmake_unit_assert_that (LANGUAGE list_contains_value STRING EQUAL "C")
        cmake_unit_assert_that (LANGUAGE list_contains_value STRING EQUAL "CXX")

    endfunction ()

    cmake_unit_configure_test (CONFIGURE COMMAND psq_configure
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX)

endfunction ()

# Adds some source files which will be detected as C and CXX source files
# and include a header in them, with ${CMAKE_CURRENT_BINARY_DIR}/include
# to be used as the include-directory.
function (psq_test_scan_for_both_with_custom_cpp_identifier_and_c_source_first)

    function (psq_configure)

        set (INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
        set (SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
        set (C_HEADER_FILE_DIRECTORY_NAME "c")
        set (DECLS_HEADER_FILE_NAME "${C_HEADER_FILE_DIRECTORY_NAME}/decls.h")
        set (DECLS_HEADER_FILE_PATH "${INCLUDE_DIR}/${DECLS_HEADER_FILE_NAME}")
        set (BOTH_HEADER_FILE_NAME "${C_HEADER_FILE_DIRECTORY_NAME}/both.h")
        set (BOTH_HEADER_FILE_PATH "${INCLUDE_DIR}/${BOTH_HEADER_FILE_NAME}")
        set (C_HEADER_FILE_NAME "${C_HEADER_FILE_DIRECTORY}/c.h")
        set (C_HEADER_FILE_PATH "${INCLUDE_DIR}/${C_HEADER_FILE_NAME}")
        set (C_SOURCE_FILE_NAME "CSource.c")
        set (C_SOURCE_FILE_PATH "${SOURCE_DIR}/${C_SOURCE_FILE_NAME}")
        set (CXX_SOURCE_FILE_NAME "CPPSource.cpp")
        set (CXX_SOURCE_FILE_PATH "${SOURCE_DIR}/${CXX_SOURCE_FILE_NAME}")

        cmake_unit_create_source_file_before_build (NAME
                                                    "${DECLS_HEADER_FILE_NAME}"
                                                    DEFINES "psq_IS_CPP"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_create_source_file_before_build (NAME
                                                    "${BOTH_HEADER_FILE_NAME}"
                                                    DEFINES "psq_IS_CPP"
                                                    INCLUDES
                                                    "${DECLS_HEADER_FILE_PATH}"
                                                    INCLUDE_DIRECTORIES
                                                    "${INCLUDE_DIR}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_create_source_file_before_build (NAME
                                                    "${C_HEADER_FILE_NAME}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_create_source_file_before_build (NAME
                                                    "${C_SOURCE_FILE_NAME}"
                                                    INCLUDES
                                                    "${BOTH_HEADER_FILE_PATH}"
                                                    "${C_HEADER_FILE_PATH}"
                                                    INCLUDE_DIRECTORIES
                                                    "${INCLUDE_DIR}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")
        cmake_unit_create_source_file_before_build (NAME
                                                    "${CXX_SOURCE_FILE_NAME}"
                                                    INCLUDES
                                                    "${BOTH_HEADER_FILE_PATH}"
                                                    "${C_HEADER_FILE_PATH}"
                                                    INCLUDE_DIRECTORIES
                                                    "${INCLUDE_DIR}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        psq_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}"
                                     INCLUDES "${INCLUDE_DIR}"
                                     CPP_IDENTIFIERS psq_IS_CPP)
        psq_scan_source_for_headers (SOURCE "${CXX_SOURCE_FILE_PATH}"
                                     INCLUDES "${INCLUDE_DIR}"
                                     CPP_IDENTIFIERS psq_IS_CPP)
        psq_determine_language_for_source ("${BOTH_HEADER_FILE_PATH}"
                                           LANGUAGE WAS_HEADER)

        cmake_unit_assert_that (LANGUAGE list_contains_value STRING EQUAL "C")
        cmake_unit_assert_that (LANGUAGE list_contains_value STRING EQUAL "CXX")

    endfunction ()

    cmake_unit_configure_test (CONFIGURE COMMAND psq_configure
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX)

endfunction ()

# Adds some source files with a header file. WAS_HEADER
# should be false for the source file.
function (psq_test_source_was_header_false_for_source)

    function (psq_configure)

        set (TOPLEVEL_HEADER_NAME Toplevel.h)
        set (TOPLEVEL_HEADER_PATH "${TOPLEVEL_HEADER_NAME}")

        cmake_unit_create_source_file_before_build (NAME
                                                    ${TOPLEVEL_HEADER_NAME}
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        set (C_SOURCE_FILE_NAME CSource.c)
        set (C_SOURCE_FILE_PATH
             "${CMAKE_CURRENT_SOURCE_DIR}/${C_SOURCE_FILE_NAME}")

        cmake_unit_create_source_file_before_build (NAME ${C_SOURCE_FILE_NAME}
                                                    INCLUDES
                                                    "${TOPLEVEL_HEADER_PATH}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        psq_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}")
        psq_determine_language_for_source ("${C_SOURCE_FILE_PATH}"
                                           LANGUAGE WAS_HEADER)

        cmake_unit_assert_that (WAS_HEADER is_false)

    endfunction ()

    cmake_unit_configure_test (CONFIGURE COMMAND psq_configure
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX)

endfunction ()

# Adds some source files with a header file. WAS_HEADER
# should be true for the header file.
function (psq_test_source_was_header_true_for_header)

    function (psq_configure)

        set (TOPLEVEL_HEADER_NAME Toplevel.h)
        set (TOPLEVEL_HEADER_PATH "${TOPLEVEL_HEADER_NAME}")

        cmake_unit_create_source_file_before_build (NAME
                                                    ${TOPLEVEL_HEADER_NAME}
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        set (C_SOURCE_FILE_NAME CSource.c)
        set (C_SOURCE_FILE_PATH
             "${CMAKE_CURRENT_SOURCE_DIR}/${C_SOURCE_FILE_NAME}")

        cmake_unit_create_source_file_before_build (NAME ${C_SOURCE_FILE_NAME}
                                                    INCLUDES
                                                    "${TOPLEVEL_HEADER_PATH}"
                                                    GENERATING_FILE
                                                    "${_CURRENT_LIST_FILE}")

        psq_scan_source_for_headers (SOURCE "${C_SOURCE_FILE_PATH}")
        psq_determine_language_for_source ("${TOPLEVEL_HEADER_PATH}"
                                           LANGUAGE WAS_HEADER)

        cmake_unit_assert_that (WAS_HEADER is_true)

    endfunction ()

    cmake_unit_configure_test (CONFIGURE COMMAND psq_configure
                               INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX)

endfunction ()

cmake_unit_init (NAMESPACE "psq"
                 COVERAGE_FILES
                 "${CMAKE_CURRENT_LIST_DIR}/DetermineHeaderLanguage.cmake")

if (BIICODE)

    add_bii_targets ()

endif ()
