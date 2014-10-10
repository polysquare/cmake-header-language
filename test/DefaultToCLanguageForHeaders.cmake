# /test/DefaultToCLanguageForHeaders.cmake
# Adds some source files which will be detected as C source files
# and include a header in them, with ${CMAKE_CURRENT_BINARY_DIR}/include
# to be used as the include-directory. 
#
# See LICENCE.md for Copyright Information.

include (DetermineHeaderLanguage)
include (CMakeUnit)

set (INCLUDE_DIRECTORY
     ${CMAKE_CURRENT_BINARY_DIR}/include)
set (C_HEADER_FILE_DIRECTORY
     ${INCLUDE_DIRECTORY}/c)
set (C_HEADER_FILE
     ${C_HEADER_FILE_DIRECTORY}/header.h)
set (C_HEADER_FILE_CONTENTS
     "struct MyThing\n"
     "{\n"
     "    int dataMember\;\n"
     "}\;\n"
     "int other (void)\;\n"
     "\n")

set (C_SOURCE_FILE
     ${CMAKE_CURRENT_BINARY_DIR}/CSource.c)
set (C_SOURCE_FILE_CONTENTS
     "\#include <c/header.h>\n"
     "int other (void)\n"
     "{\n"
     "    struct MyThing myThing = { 1 }\;\n"
     "    return myThing.dataMember\;\n"
     "}\n"
     "\n")

set (CXX_SOURCE_FILE
     ${CMAKE_CURRENT_BINARY_DIR}/CXXSource.cpp)
set (CXX_SOURCE_FILE_CONTENTS
     "extern \"C\" {\n"
     "\#include <c/header.h>\n"
     "}\n"
     "int main ()\n"
     "{\n"
     "    return other ()\;\n"
     "}\n"
     "\n")

file (MAKE_DIRECTORY ${INCLUDE_DIRECTORY})
file (MAKE_DIRECTORY ${C_HEADER_FILE_DIRECTORY})

file (WRITE ${C_SOURCE_FILE} ${C_SOURCE_FILE_CONTENTS})
file (WRITE ${CXX_SOURCE_FILE} ${CXX_SOURCE_FILE_CONTENTS})
file (WRITE ${C_HEADER_FILE} ${C_HEADER_FILE_CONTENTS})

polysquare_scan_source_for_headers (SOURCE ${C_SOURCE_FILE}
                             INCLUDES ${INCLUDE_DIRECTORY})
polysquare_scan_source_for_headers (SOURCE ${CXX_SOURCE_FILE}
                             INCLUDES ${INCLUDE_DIRECTORY})

polysquare_determine_language_for_source (${C_HEADER_FILE}
                                          LANGUAGE WAS_HEADER)

assert_variable_is (${LANGUAGE} STRING EQUAL "C")
