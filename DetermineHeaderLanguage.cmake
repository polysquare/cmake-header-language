#
# DetermineHeaderLanguage.cmake
#
# CMake utility to determine the languages of a header file. This information
# can be used to determine which language mode certain tools should run in.
#
# See LICENCE.md for Copyright information.

include (CMakeParseArguments)

function (_psq_get_absolute_path_to_header_file_language ABSOLUTE_PATH_TO_HEADER
                                                         LANGUAGE)

    # ABSOLUTE_PATH is a GLOBAL property
    # called "_CPPCHECK_H_MAP_" + ABSOLUTE_PATH.
    # We can't address it immediately by that name though,
    # because CMake properties and variables can only be
    # addressed by certain characters, however, internally,
    # they are stored as std::map <std::string, std::string>,
    # so we can fool CMake into doing so.
    #
    # We first save our desired property string into a new
    # variable called MAP_KEY and then use set
    # ("${MAP_KEY}" ${LANGUAGE}). CMake will expand ${MAP_KEY}
    # and pass the string directly to the internal
    # implementation of "set", which sets the string
    # as the key value
    set (MAP_KEY "_CPPCHECK_H_MAP_${ABSOLUTE_PATH_TO_HEADER}")
    get_property (HEADER_FILE_LANGUAGE_SET GLOBAL PROPERTY "${MAP_KEY}" SET)

    if (HEADER_FILE_LANGUAGE_SET)

        get_property (HEADER_FILE_LANGUAGE GLOBAL PROPERTY "${MAP_KEY}")

        # If it is just C, check our _CPPCHECK_HAS_CXX_TOKENS_MAP_ to see
        # if this is actually a mixed mode header.
        if (HEADER_FILE_LANGUAGE STREQUAL "C")

            set (MIXED_MODE_MAP_KEY
                 "_CPPCHECK_HAS_CXX_TOKENS_MAP_${ABSOLUTE_PATH_TO_HEADER}")
            get_property (IS_MIXED_MODE GLOBAL PROPERTY
                          "${MIXED_MODE_MAP_KEY}")

            if (IS_MIXED_MODE)

                list (APPEND HEADER_FILE_LANGUAGE "CXX")

            endif (IS_MIXED_MODE)

        endif (HEADER_FILE_LANGUAGE STREQUAL "C")

        set (${LANGUAGE} ${HEADER_FILE_LANGUAGE} PARENT_SCOPE)
        return ()

    endif (HEADER_FILE_LANGUAGE_SET)

    return ()

endfunction ()

function (_psq_language_from_source SOURCE
                                    RETURN_LANGUAGE
                                    SOURCE_WAS_HEADER_RETURN)

    cmake_parse_arguments (LANG_FROM_SOURCE
                           ""
                           "FORCE_LANGUAGE"
                           ""
                           ${ARGN})

    set (${SOURCE_WAS_HEADER_RETURN} FALSE PARENT_SCOPE)
    set (_RETURN_LANGUAGE "")

    # Try and detect the language based on the file's extension
    get_filename_component (EXTENSION ${SOURCE} EXT)
    string (SUBSTRING ${EXTENSION} 1 -1 EXTENSION)

    list (FIND CMAKE_C_SOURCE_FILE_EXTENSIONS ${EXTENSION} C_INDEX)

    if (NOT C_INDEX EQUAL -1)

        set (_RETURN_LANGUAGE "C")

    endif (NOT C_INDEX EQUAL -1)

    list (FIND CMAKE_CXX_SOURCE_FILE_EXTENSIONS ${EXTENSION} CXX_INDEX)

    if (NOT CXX_INDEX EQUAL -1)

        set (_RETURN_LANGUAGE "CXX")

    endif ()

    # This is a header
    if (NOT _RETURN_LANGUAGE)

        set (${SOURCE_WAS_HEADER_RETURN} TRUE PARENT_SCOPE)
        # Couldn't find source langauge from either extension or property.
        # We might be scanning a header so check the header maps for a language
        set (LANGUAGE "")
        _psq_get_absolute_path_to_header_file_language (${SOURCE} LANGUAGE)
        set (_RETURN_LANGUAGE ${LANGUAGE})

    endif (NOT _RETURN_LANGUAGE)

    # Override language based on option here after we've scanned everything
    # and worked out if this was a header or not
    if (LANG_FROM_SOURCE_FORCE_LANGUAGE)

        set (_RETURN_LANGUAGE ${LANG_FROM_SOURCE_FORCE_LANGUAGE})

    else (LANG_FROM_SOURCE_FORCE_LANGUAGE)

        get_property (LANGUAGE SOURCE ${SOURCE} PROPERTY SET_LANGUAGE)

        # User overrode the LANGUAGE property, use that.
        if (DEFINED SET_LANGUAGE)

           set (_RETURN_LANGUAGE ${SET_LANGUAGE})

        endif (DEFINED SET_LANGUAGE)

    endif (LANG_FROM_SOURCE_FORCE_LANGUAGE)

    set (${RETURN_LANGUAGE} ${_RETURN_LANGUAGE} PARENT_SCOPE)

endfunction () 

function (_psq_process_include_statement_path INCLUDE_PATH UPDATE_HEADERS)

    set (HEADERS_TO_UPDATE_LIST)
    set (PROCESS_MULTIVAR_ARGS INCLUDES)

    cmake_parse_arguments (PROCESS
                           ""
                           ""
                           "${PROCESS_MULTIVAR_ARGS}"
                           ${ARGN})

    foreach (INCLUDE_DIRECTORY ${PROCESS_INCLUDES})

        set (RELATIVE_PATH "${INCLUDE_DIRECTORY}/${INCLUDE_PATH}")
        get_filename_component (ABSOLUTE_PATH ${RELATIVE_PATH} ABSOLUTE)

        get_property (HEADER_IS_GENERATED SOURCE ${ABSOLUTE_PATH}
                      PROPERTY GENERATED)

        if (EXISTS ${ABSOLUTE_PATH} OR HEADER_IS_GENERATED)

            # First see if a language has already been set for this header
            # file. If so, and it is "C", then we can't change it any
            # further at this point.
            set (HEADER_LANGUAGE "")
            _psq_get_absolute_path_to_header_file_language (${ABSOLUTE_PATH}
                                                            HEADER_LANGUAGE)

            set (MAP_KEY "_CPPCHECK_H_MAP_${ABSOLUTE_PATH}")
            set (UPDATE_HEADER_IN_MAP FALSE)

            list (FIND HEADER_LANGUAGE "C" C_INDEX)

            if (DEFINED HEADER_LANGUAGE AND
                C_INDEX EQUAL -1)

                list (APPEND HEADERS_TO_UPDATE_LIST "${ABSOLUTE_PATH}")

            elseif (NOT DEFINED HEADER_LANGUAGE AND C_INDEX EQUAL -1)

                list (APPEND HEADERS_TO_UPDATE_LIST "${ABSOLUTE_PATH}")

            endif (DEFINED HEADER_LANGUAGE AND C_INDEX EQUAL -1)

        endif (EXISTS ${ABSOLUTE_PATH} OR HEADER_IS_GENERATED)

    endforeach ()

    set (${UPDATE_HEADERS} ${HEADERS_TO_UPDATE_LIST} PARENT_SCOPE)

endfunction ()

# polysquare_scan_source_for_headers
#
# Opens the source file SOURCE at its absolute path and scans it for
# #include statements if we have not done so already. The content of the
# include statement is pasted together with each provided INCLUDE
# and checked to see if it forms the path to an existing or generated
# source. If it does, then the following rules apply to determine
# the language of the header file:
#
# - If the source including the header is a CXX source (including a CXX
#   header, and no other language has been set for this header, then
#   the language of the header is set to CXX
# - If any source including the header is a C source (including a C header)
#   then the language of the header is forced to "C", with one caveat:
#   - The header file will be opened and scanned for any tokens which match
#     any provided tokens in CPP_IDENTIFIERS or __cplusplus. If it does, then
#     the header language will be set to C;CXX
#
# SOURCE: The source file to be scanned
# [Optional INCLUDES]: Any include directories to search for header files
# [Optional CPP_IDENTIFIERS]: Any identifiers which might indicate that this
#                             source can be compiled with both C and CXX.
function (polysquare_scan_source_for_headers)

    set (SCAN_SINGLEVAR_ARGUMENTS SOURCE)
    set (SCAN_MULTIVAR_ARGUMENTS INCLUDES CPP_IDENTIFIERS)

    cmake_parse_arguments (SCAN
                           ""
                           "${SCAN_SINGLEVAR_ARGUMENTS}"
                           "${SCAN_MULTIVAR_ARGUMENTS}"
                           ${ARGN})

    if (NOT DEFINED SCAN_SOURCE)

        message (FATAL_ERROR "SOURCE ${SCAN_SOURCE} must be set to use this function")

    endif (NOT DEFINED SCAN_SOURCE)

    # Source doesn't exist. This is fine, we might be recursively scanning
    # a header path which is generated. If it is generated, gracefully bail
    # out, otherwise exit with a FATAL_ERROR as this is really an assertion
    if (NOT EXISTS ${SCAN_SOURCE})

        get_property (SOURCE_IS_GENERATED SOURCE ${SCAN_SOURCE}
                      PROPERTY GENERATED)

        if (SOURCE_IS_GENERATED)

            return ()

        else (SOURCE_IS_GENERATED)

            message (FATAL_ERROR "_scan_source_file_for_headers called with "
                                 "a source file that does not exist or was "
                                 "not generated as part of a build rule")

        endif (SOURCE_IS_GENERATED)

    endif (NOT EXISTS ${SCAN_SOURCE})

    # We've already scanned this source file in this pass, bail out
    get_property (ALREADY_SCANNED GLOBAL
                  PROPERTY _CPPCHECK_ALREADY_SCANNED_SOURCES)
    list (FIND ALREADY_SCANNED ${SCAN_SOURCE} SOURCE_INDEX)

    if (NOT SOURCE_INDEX EQUAL -1)

        return ()

    endif (NOT SOURCE_INDEX EQUAL -1)

    set_property (GLOBAL APPEND PROPERTY _CPPCHECK_ALREADY_SCANNED_SOURCES
                  ${SCAN_SOURCE})

    # Open the source file and read its contents
    file (READ ${SCAN_SOURCE} SOURCE_CONTENTS)

    # Split the read contents into lines, using ; as the delimiter
    string (REGEX REPLACE ";" "\\\\;" SOURCE_CONTENTS "${SOURCE_CONTENTS}")
    string (REGEX REPLACE "\n" ";" SOURCE_CONTENTS "${SOURCE_CONTENTS}")

    _psq_language_from_source (${SCAN_SOURCE} LANGUAGE WAS_HEADER)

    # If we are scanning a header file right now, the we need to check now
    # while reading it for other headers for CXX tokens too. If there are
    # CXX tokens, we'll keep it in our special _CPPCHECK_HAS_CXX_TOKENS_MAP_
    set (SCAN_FOR_CXX_IDENTIFIERS ${WAS_HEADER})

    foreach (LINE ${SOURCE_CONTENTS})

        # This is an #include statement, check what is within it
        if (LINE MATCHES "^.*\#include.*[<\"].*[>\"]")

            # Start with ${LINE}
            set (HEADER ${LINE})

            # Trim out the beginning and end of the include statement
            # Because CMake doesn't support non-greedy expressions (eg "?")
            # we need to match based on indices and not using REGEX REPLACE
            # so we need to use REGEX MATCH to get the first match and then
            # FIND to get the index.
            string (REGEX MATCH "[<\"]" PATH_START "${HEADER}")
            string (FIND "${HEADER}" "${PATH_START}" PATH_START_INDEX)
            math (EXPR PATH_START_INDEX "${PATH_START_INDEX} + 1")
            string (SUBSTRING "${HEADER}" ${PATH_START_INDEX} -1 HEADER)

            string (REGEX MATCH "[>\"]" PATH_END "${HEADER}")
            string (FIND "${HEADER}" "${PATH_END}" PATH_END_INDEX)
            string (SUBSTRING "${HEADER}" 0 ${PATH_END_INDEX} HEADER)

            string (STRIP ${HEADER} HEADER)

            # Check if this include statement has quotes. If it does, then
            # we should include the current source directory in the include
            # directory scan.
            string (FIND "${LINE}" "\"" QUOTE_INDEX)

            if (NOT QUOTE_INDEX EQUAL -1)

                list (APPEND SCAN_INCLUDES ${CMAKE_CURRENT_SOURCE_DIR})

            endif (NOT QUOTE_INDEX EQUAL -1)

            _psq_process_include_statement_path (${HEADER} UPDATE_HEADERS
                                                 INCLUDES ${SCAN_INCLUDES})

            # Every correct combination of include-directory to header
            foreach (HEADER ${UPDATE_HEADERS})

                set (MAP_KEY "_CPPCHECK_H_MAP_${HEADER}")
                set_property (GLOBAL PROPERTY "${MAP_KEY}"
                                              "${LANGUAGE}")

                # Recursively scan for header more header files
                # in this one
                polysquare_scan_source_for_headers (SOURCE ${HEADER}
                                                    INCLUDES
                                                    ${SCAN_INCLUDES}
                                                    CPP_IDENTIFIERS
                                                    ${SCAN_CPP_IDENTIFIERS})

            endforeach ()

       endif (LINE MATCHES "^.*\#include.*[<\"].*[>\"]")

       if (SCAN_FOR_CXX_IDENTIFIERS)

            list (APPEND SCAN_CPP_IDENTIFIERS
                  __cplusplus)
            list (REMOVE_DUPLICATES SCAN_CPP_IDENTIFIERS)

            foreach (IDENTIFIER ${SCAN_CPP_IDENTIFIERS})

                if (LINE MATCHES "^.*${IDENTIFIER}")

                    set (MAP_KEY "_CPPCHECK_HAS_CXX_TOKENS_MAP_${SCAN_SOURCE}")
                    set_property (GLOBAL PROPERTY "${MAP_KEY}" TRUE)
                    set (SCAN_FOR_CXX_IDENTIFIERS FALSE)

                endif (LINE MATCHES "^.*${IDENTIFIER}")

            endforeach ()

        endif (SCAN_FOR_CXX_IDENTIFIERS)

    endforeach ()

endfunction ()

# polysquare_determine_language_for_source
#
# Takes any source, including a header file and writes the determined
# language into LANGUAGE_RETURN. If the source is a header file
# SOURCE_WAS_HEADER_RETURN will be set to true as well.
#
# This function only works for header files if those header files
# were included by sources previously scanned by
# polysquare_scan_source_for_headers. They must be scanned before
# this function is called, otherwise this function will be unable
# to determine the language of the source file and report an error.
#
# SOURCE: The source whose language is to be determined
# LANGUAGE_RETURN: A variable where the language can be written into
# SOURCE_WAS_HEADER_RETURN: A variable where a boolean variable, indicating
#                           whether this was a header or a source that was
#                           checked.
# [Optional] FORCE_LANGUAGE: Performs scanning, but forces language to be one
#                            of C or CXX.
function (polysquare_determine_language_for_source SOURCE
                                                   LANGUAGE_RETURN
                                                   SOURCE_WAS_HEADER_RETURN)
 
    set (DETERMINE_LANG_MULTIVAR_ARGS INCLUDES)
    cmake_parse_arguments (DETERMINE_LANG
                           ""
                           "FORCE_LANGUAGE"
                           "${DETERMINE_LANG_MULTIVAR_ARGS}"
                           ${ARGN})

    if (DETERMINE_LANG_FORCE_LANGUAGE)

        set (LANG_FROM_SOURCE_FORCE_LANGUAGE_OPT
             FORCE_LANGUAGE ${DETERMINE_LANG_FORCE_LANGUAGE})

    endif (DETERMINE_LANG_FORCE_LANGUAGE)

    _psq_language_from_source (${SOURCE} LANGUAGE WAS_HEADER
                               ${LANG_FROM_SOURCE_FORCE_LANGUAGE_OPT})
    set (${SOURCE_WAS_HEADER_RETURN} ${WAS_HEADER} PARENT_SCOPE)

    # If it wasn't a header or language was forced, then the answer
    # we got back was the authority. There's no need to check for
    # mixed mode headers or the like.
    if (NOT WAS_HEADER OR DETERMINE_LANG_FORCE_LANGUAGE)

        set (${LANGUAGE_RETURN} ${LANGUAGE} PARENT_SCOPE)
        return ()

    else (NOT WAS_HEADER OR DETERMINE_LANG_FORCE_LANGUAGE)

        set (${SOURCE_WAS_HEADER_RETURN} TRUE PARENT_SCOPE)

        # This is a header file - we need to look up in the list
        # of header files to determine what language this header
        # file is. That will generally be "C" if it was
        # included by any "C" source files and "CXX" if it was included
        # by any other (CXX) sources.
        #
        # There is also an error case - If we are unable to determine
        # the language of the header file initially, then it was never
        # added to the list of known headers. We'll error out with a message
        # suggesting that it must be included at least once somewhere, or
        # a FORCE_LANGUAGE option should be passed
        get_filename_component (ABSOLUTE_PATH ${SOURCE} ABSOLUTE)
        _psq_get_absolute_path_to_header_file_language (${ABSOLUTE_PATH}
                                                        HEADER_LANGUAGE)

        # Error case
        if (NOT DEFINED HEADER_LANGUAGE)
        
            set (ERROR_MESSAGE "Couldn't find language for the header file"
                               " ${ABSOLUTE_PATH}. Make sure to include "
                               " this header file in at least one source "
                               " file and add that source file to a "
                               " target and scan it using "
                               " polysquare_scan_source_for_headers or specify"
                               " the FORCE_LANGUAGE option to the call to"
                               " polysquare_determine_language_for_source where"
                               " the header will be included in the arguments.")

            set (ERROR_MESSAGE "${ERROR_MESSAGE}\n The following sources have "
                               "been scanned for includes:\n")

            get_property (ALREADY_SCANNED GLOBAL PROPERTY
                          _CPPCHECK_ALREADY_SCANNED_SOURCES)

            foreach (SOURCE ${ALREADY_SCANNED})

                set (ERROR_MESSAGE "${ERROR_MESSAGE} - ${SOURCE}\n")

            endforeach ()

            message (SEND_ERROR ${ERROR_MESSAGE})

            return ()

        endif (NOT DEFINED HEADER_LANGUAGE)

        set (${LANGUAGE_RETURN} ${HEADER_LANGUAGE} PARENT_SCOPE)
        return ()

    endif (NOT WAS_HEADER OR DETERMINE_LANG_FORCE_LANGUAGE)

    message (FATAL_ERROR "This section should not be reached")

endfunction ()

