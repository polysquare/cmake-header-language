# /test/CheckForCAndCPPWhereHeaderHasIfdefCPlusPlus.cmake
# Adds some source files which will be detected as C source files
# and include a header in them, with ${CMAKE_CURRENT_BINARY_DIR}/include
# to be used as the include-directory.
#
# Add #ifdef __cplusplus to the header file. This shall make it scanned
# in both modes
#
# See LICENCE.md for Copyright Information.

include (${POLYSQUARE_HL_CMAKE_DIRECTORY}/DetermineHeaderLanguage.cmake)
include (${POLYSQUARE_HL_CMAKE_TESTS_DIRECTORY}/CMakeUnit.cmake)

set (INCLUDE_DIRECTORY
     ${CMAKE_CURRENT_BINARY_DIR}/include)
set (C_HEADER_FILE_DIRECTORY
     ${INCLUDE_DIRECTORY}/c)
set (BOTH_HEADER_FILE
     ${C_HEADER_FILE_DIRECTORY}/both.h)
set (BOTH_HEADER_FILE_CONTENTS
     "\#ifdef __cplusplus\n"
     "class MyClass\n"
     "{\n"
     "    public:\n"
     "        int dataMember\;\n"
     "}\;\n"
     "\#endif\n"
     "\n")

set (C_HEADER_FILE
     ${C_HEADER_FILE_DIRECTORY}/c.h)
set (C_HEADER_FILE_CONTENTS
     "struct MyThing\n"
     "{\n"
     "    int dataMember\;\n"
     "}\;\n"
     "\n")

set (C_SOURCE_FILE
     ${CMAKE_CURRENT_BINARY_DIR}/CSource.c)
set (C_SOURCE_FILE_CONTENTS
     "\#include <c/both.h>\n"
     "\#include <c/c.h>\n"
     "int main (void)\n"
     "{\n"
     "    struct MyThing myThing = { 1 }\;\n"
     "    return myThing.dataMember\;\n"
     "}\n"
     "\n")

file (MAKE_DIRECTORY ${INCLUDE_DIRECTORY})
file (MAKE_DIRECTORY ${C_HEADER_FILE_DIRECTORY})

file (WRITE ${C_SOURCE_FILE} ${C_SOURCE_FILE_CONTENTS})
file (WRITE ${C_HEADER_FILE} ${C_HEADER_FILE_CONTENTS})
file (WRITE ${BOTH_HEADER_FILE} ${BOTH_HEADER_FILE_CONTENTS})

polysquare_scan_source_for_headers (SOURCE ${C_SOURCE_FILE}
                                    INCLUDES ${INCLUDE_DIRECTORY})

polysquare_determine_language_for_source (${BOTH_HEADER_FILE}
                                          LANGUAGE WAS_HEADER)

assert_list_contains_value (LANGUAGE STRING EQUAL "C")
assert_list_contains_value (LANGUAGE STRING EQUAL "CXX")
