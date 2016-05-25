from conans import ConanFile
from conans.tools import download, unzip
import os

VERSION = "0.0.2"


class CMakeHeaderLanguageConan(ConanFile):
    name = "cmake-header-language"
    version = os.environ.get("CONAN_VERSION_OVERRIDE", VERSION)
    generators = "cmake"
    requires = ("cmake-include-guard/master@smspillaz/cmake-include-guard",)
    url = "http://github.com/polysquare/cmake-header-language"
    license = "MIT"
    options = {
        "dev": [True, False]
    }
    default_options = "dev=False"

    def requirements(self):
        if self.options.dev:
            self.requires("cmake-module-common/master@smspillaz/cmake-module-common")

    def source(self):
        zip_name = "cmake-header-language.zip"
        download("https://github.com/polysquare/"
                 "cmake-header-language/archive/{version}.zip"
                 "".format(version="v" + VERSION),
                 zip_name)
        unzip(zip_name)
        os.unlink(zip_name)

    def package(self):
        self.copy(pattern="*.cmake",
                  dst="cmake/cmake-header-language",
                  src="cmake-header-language-" + VERSION,
                  keep_path=True)
