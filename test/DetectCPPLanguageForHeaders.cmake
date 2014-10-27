# /test/DetectCPPLanguageForHeaders.cmake
# Adds some source files which will be detected as CPP source files
# and include a header in them, with ${CMAKE_CURRENT_BINARY_DIR}/include
# to be used as the include-directory.
#
# See LICENCE.md for Copyright Information.

include (DetermineHeaderLanguage)
include (CMakeUnit)

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

assert_variable_is (LANGUAGE STRING EQUAL "CXX")
