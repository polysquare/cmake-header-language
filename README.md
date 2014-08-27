cmake-determine-header-language
===============================

CMake macro to determine the language of a header file.

Status
======
[![Build Status](https://travis-ci.org/polysquare/cmake-determine-header-language.svg?branch=master)](https://travis-ci.org/polysquare/cmake-determine-header-language)

Description
===========
`cmake-determine-header-language` can be used to detect the language of header files based on what other files include them. This can be used for various bits of build tooling, where the build tooling itself quite require a language to be explicitly set for the header file to be scanned.

Usage
=====
`cmake-determine-header-language` works by scanning source files for `#include` statements and then checks the passed include directories for files matching the name of files specified in the `#include` statements.

Scanning for header files
-------------------------
You can scan a source file for headers recursively using `polysquare_scan_source_for_headers`. The macro will apply the following rules to any detected header file.

 1. If source file including the header is a C++ source and the header file was not already marked as a C source, then the language of the header is set to CXX
 2. If the source file including the header is a C source, then the header will unconditionally be marked as a C header.
 3. If, when scanning the header, certain indicators such as `__cplusplus` or any of the indicators specified in `CPP_IDENTIFIERS` were found, then the header is set to C and C++

See, for example:

    polysquare_scan_source_for_headers (SOURCE my_source.c INCLUDES /path/to/include/dir CPP_IDENTIFIERS MY_SOURCE_IS_COMPILING_CXX)

Getting the language of any source
----------------------------------
Once sources have been scanned for header files, their language can be obtained with `polysquare_determine_language_from_source`. If this function is used on a header which was not part of an already scanned source, then a fatal error will result.

See, for example:

    polysquare_determine_language_from_source (my_header.h LANGUAGE WAS_HEADER)

`LANGUAGE` will be set to C, CXX or both should the header be compilable in both modes.
`WAS_HEADER` will be set to TRUE if the scanned source was a header, FALSE otherwise.
