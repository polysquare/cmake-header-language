# /test/SourceWasHeaderTrueForHeaders.cmake
# Adds some source files with a header file. WAS_HEADER
# should be true for the header file.
#
# See LICENCE.md for Copyright Information.

include (${POLYSQUARE_HL_CMAKE_DIRECTORY}/DetermineHeaderLanguage.cmake)
include (${POLYSQUARE_HL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (INCLUDE_DIRECTORY
     ${CMAKE_CURRENT_BINARY_DIR}/include)
set (CXX_HEADER_FILE_DIRECTORY
     ${INCLUDE_DIRECTORY}/cxx)
set (CXX_HEADER_FILE
     ${CXX_HEADER_FILE_DIRECTORY}/header.h)
set (CXX_HEADER_FILE_CONTENTS
     "class MyThing\n"
     "{\n"
     "public:\n"
     "    int dataMember\;\n"
     "}\;\n"
     "\n")

set (CXX_SOURCE_FILE
     ${CMAKE_CURRENT_BINARY_DIR}/CXXSource.cxx)
set (CXX_SOURCE_FILE_CONTENTS
     "\#include <cxx/header.h>\n"
     "int main (void)\n"
     "{\n"
     "    MyThing myThing\;\n"
     "    myThing.dataMember = 1\;\n"
     "    return myThing.dataMember\;\n"
     "}\n"
     "\n")

file (MAKE_DIRECTORY ${INCLUDE_DIRECTORY})
file (MAKE_DIRECTORY ${CXX_HEADER_FILE_DIRECTORY})

file (WRITE ${CXX_SOURCE_FILE} ${CXX_SOURCE_FILE_CONTENTS})
file (WRITE ${CXX_HEADER_FILE} ${CXX_HEADER_FILE_CONTENTS})

polysquare_scan_source_for_headers (SOURCE ${CXX_SOURCE_FILE}
                                    INCLUDES ${INCLUDE_DIRECTORY})

polysquare_determine_language_for_source (${CXX_HEADER_FILE}
                                          LANGUAGE WAS_HEADER)

assert_true (${WAS_HEADER})