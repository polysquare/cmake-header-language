# /tests/CMakeLists.txt
# Main entry point for the common-universal-cmake tests.
#
# See LICENCE.md for Copyright information

if (POLICY CMP0025)

    cmake_policy (SET CMP0025 NEW)

endif (POLICY CMP0025)
project (PolysquareCMakeHeaderLanguageTests)
cmake_minimum_required (VERSION 2.8)

# We assume that it is one-above us
set (POLYSQUARE_HL_RELATIVE_CMAKE_DIRECTORY
     ${CMAKE_CURRENT_SOURCE_DIR}/..)
get_filename_component (POLYSQUARE_HL_CMAKE_DIRECTORY
                        ${POLYSQUARE_HL_RELATIVE_CMAKE_DIRECTORY}
                        ABSOLUTE)
set (CMAKE_UNIT_DIRECTORY
     ${POLYSQUARE_HL_CMAKE_DIRECTORY}/cmake-unit)

set (CPPCHECK_INITIAL_CACHE_CONTENTS
     "set (POLYSQUARE_HL_CMAKE_DIRECTORY\n"
     "     ${POLYSQUARE_HL_CMAKE_DIRECTORY}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (POLYSQUARE_HL_CMAKE_TESTS_DIRECTORY\n"
     "     ${CMAKE_UNIT_DIRECTORY}\n"
     "     CACHE STRING \"\" FORCE)\n")

set (CMAKE_MODULE_PATH
     ${CMAKE_UNIT_DIRECTORY}
     ${CMAKE_MODULE_PATH})

include (CMakeUnitRunner)

bootstrap_cmake_unit (INITIAL_CACHE_CONTENTS
                      CPPCHECK_INITIAL_CACHE_CONTENTS)

add_cmake_test (CheckTransientIncludesForLanguage)
add_cmake_test (CheckForCAndCPPWhereHeaderHasIfdefCPlusPlus)
add_cmake_test (ScanForBothWithCustomCPPIdentifier)
add_cmake_test (BreakIncludeCyclesWhenScanningForHeaders)
add_cmake_test (DetectLanguageOfGeneratedHeader)
add_cmake_test (DetectCLanguageForHeaders)
add_cmake_test (DetectCLanguageForHeadersWhenIncludeInQuotes)
add_cmake_test (DetectCPPLanguageForHeaders)
add_cmake_test (DefaultToCLanguageForHeaders)
