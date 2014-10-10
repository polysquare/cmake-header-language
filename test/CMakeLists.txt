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

set (CMAKE_MODULE_PATH
     ${CMAKE_UNIT_DIRECTORY}
     ${POLYSQUARE_HL_CMAKE_DIRECTORY}
     ${CMAKE_MODULE_PATH})

foreach (PATH ${CMAKE_MODULE_PATH})
     set (POLYSQUARE_INITIAL_CACHE_CONTENTS
          "${POLYSQUARE_INITIAL_CACHE_CONTENTS}\n"
          "set (CMAKE_MODULE_PATH ${PATH} \${CMAKE_MODULE_PATH}\n"
          "     CACHE STRING \"\" FORCE)\n")
endforeach ()

include (CMakeUnitRunner)

bootstrap_cmake_unit (INITIAL_CACHE_CONTENTS
                      POLYSQUARE_INITIAL_CACHE_CONTENTS)

add_cmake_test (CheckTransientIncludesForLanguage)
add_cmake_test (CheckForCAndCPPWhereHeaderHasIfdefCPlusPlus)
add_cmake_test (ScanForBothWithCustomCPPIdentifier)
add_cmake_test (ScanForBothWithCustomCPPIdentifierAndCSourceFirst)
add_cmake_test (BreakIncludeCyclesWhenScanningForHeaders)
add_cmake_test (DetectLanguageOfGeneratedHeader)
add_cmake_test (DetectCLanguageForHeaders)
add_cmake_test (DetectCLanguageForHeadersWhenIncludeInQuotes)
add_cmake_test (DetectCPPLanguageForHeaders)
add_cmake_test (DefaultToCLanguageForHeaders)
add_cmake_test (SourceWasHeaderTrueForHeader)
add_cmake_test (SourceWasHeaderFalseForSource)