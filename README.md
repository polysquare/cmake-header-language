# CMake Determine Header Language #

CMake macro to determine the language of a header file.

## Status ##

| Travis-CI (Ubuntu) | AppVeyor (Windows) | Coveralls |
|--------------------|--------------------|-----------|
|[![Travis](https://travis-ci.org/polysquare/cmake-determine-header-language.svg?branch=master)](https://travis-ci.org/polysquare/cmake-determine-header-language)|[![AppVeyor](https://ci.appveyor.com/api/projects/status/3q97d9iw7dset8ty/branch/master?svg=true)](https://ci.appveyor.com/project/smspillaz/cmake-determine-header-language/branch/master)|[![Coveralls](https://coveralls.io/repos/polysquare/cmake-determine-header-language/badge.png)](https://coveralls.io/r/polysquare/cmake-determine-header-language)|

## Description ##

`cmake-determine-header-language` can be used to detect the language of header
files based on what other files include them.  This can be used for various bits
of build tooling, where the build tooling itself quite require a language to be
explicitly set for the header file to be scanned.

## Usage ##

`cmake-determine-header-language` works by scanning source files for `#include`
statements and then checks the passed include directories for files matching the
name of files specified in the `#include` statements.

### Scanning for header files ###

You can scan a source file for headers recursively using
`polysquare_scan_source_for_headers`.  The macro will apply the following rules
to any detected header file.

* If source file including the header is a C++ source and the header file was
  not already marked as a C source, then the language of the header is set to
  CXX
* If the source file including the header is a C source, then the header will
  unconditionally be marked as a C header.
* If, when scanning the header, certain indicators such as `__cplusplus` or
  any of the indicators specified in `CPP_IDENTIFIERS` were found, then the
  header is set to C and C++

See, for example:

    polysquare_scan_source_for_headers (SOURCE my_source.c
                                        INCLUDES /path/to/include/dir
                                        CPP_IDENTIFIERS
                                        MY_SOURCE_IS_COMPILING_CXX)

### Getting the language of any source ###

Once sources have been scanned for header files, their language can be obtained
with `polysquare_determine_language_from_source`.  If this function is used on a
header which was not part of an already scanned source, then a fatal error will
result.

See, for example:

    polysquare_determine_language_from_source (my_header.h LANGUAGE WAS_HEADER)

`LANGUAGE` will be set to C, CXX or both should the header be compilable in both
modes.  `WAS_HEADER` will be set to TRUE if the scanned source was a header,
FALSE otherwise.

## Reference ##

### `psq_source_type_from_source_file_extension` ###

Returns the initial type of a source file from its extension. It doesn't
properly analyze headers and source inclusions to determine the language
of any headers.

The type of the source will be set in the variable specified in
RETURN_TYPE. Valid values are C_SOURCE, CXX_SOURCE, HEADER and UNKNOWN

* `SOURCE`: Source file to scan
* `RETURN_TYPE`: Variable to set the source type in

### `polysquare_scan_source_for_headers` ###

Opens the source file `SOURCE` at its absolute path and scans it
for `#include` statements if we have not done so already. The content of the
include statement is pasted together with each provided `INCLUDE`
and checked to see if it forms the path to an existing or generated
source. If it does, then the following rules apply to determine
the language of the header file:

If the source including the header is a `CXX` source (including a `CXX`
header, and no other language has been set for this header, then
the language of the header is set to `CXX`

If any source including the header is a `C` source (including a `C` header)
then the language of the header is forced to "`C`", with one caveat:

The header file will be opened and scanned for any tokens which match
any provided tokens in `CPP_IDENTIFIERS` or `__cplusplus`. If it does, then
the header language will be set to `C;CXX`

* `SOURCE`: The source file to be scanned
* [Optional] `INCLUDES`: Any include directories to search for header files
* [Optional] `CPP_IDENTIFIERS`: Any identifiers which might indicate that this
                                source can be compiled with both C and CXX.

### `polysquare_determine_language_for_source` ###

Takes any source, including a header file and writes the determined
language into `LANGUAGE_RETURN`. If the source is a header file
`SOURCE_WAS_HEADER_RETURN` will be set to true as well.

This function only works for header files if those header files
were included by sources previously scanned by
`polysquare_scan_source_for_headers`. They must be scanned before
this function is called, otherwise this function will be unable
to determine the language of the source file and report an error.

* `SOURCE`: The source whose language is to be determined
* `LANGUAGE_RETURN`: A variable where the language can be written into
* `SOURCE_WAS_HEADER_RETURN`: A variable where a boolean variable, indicating
                              whether this was a header or a source that was
                              checked.
* [Optional] `FORCE_LANGUAGE`: Performs scanning, but forces language to be one
                               of `C` or `CXX`.
