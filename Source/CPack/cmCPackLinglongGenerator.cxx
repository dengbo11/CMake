/* Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
   file LICENSE.rst or https://cmake.org/licensing for details.  */
#include "cmCPackLinglongGenerator.h"

#include <ostream>
#include <utility>
#include <vector>

#include "cmCPackLog.h"
#include "cmStringAlgorithms.h"
#include "cmSystemTools.h"
#include "cmValue.h"

cmCPackLinglongGenerator::cmCPackLinglongGenerator() = default;

cmCPackLinglongGenerator::~cmCPackLinglongGenerator() = default;

int cmCPackLinglongGenerator::InitializeInternal()
{
  // Set defaults before calling CMake module
  if (this->GetOption("CPACK_SET_DESTDIR").IsOff()) {
    this->SetOption("CPACK_SET_DESTDIR", "I_ON");
  }

  return this->Superclass::InitializeInternal();
}

int cmCPackLinglongGenerator::PackageFiles()
{
  cmCPackLogger(cmCPackLog::LOG_VERBOSE,
                "CPackLinglong: Packaging files..." << std::endl);

  // Call the CMake module for variable preparation and YAML generation
  if (!this->ReadListFile("Internal/CPack/CPackLinglong.cmake")) {
    cmCPackLogger(cmCPackLog::LOG_ERROR,
                  "Error while executing CPackLinglong.cmake" << std::endl);
    return 0;
  }

  // Get the project root directory (where linglong.yaml was generated)
  cmValue genWDir = this->GetOption("GEN_WDIR");
  if (!cmNonempty(genWDir)) {
    cmCPackLogger(cmCPackLog::LOG_ERROR,
                  "CPackLinglong: GEN_WDIR not set. "
                  "CMake module may not have been executed."
                  << std::endl);
    return 0;
  }

  // Create the linglong/sources/files/ directory structure for ll-builder
  std::string const sourcesDir =
    cmStrCat(*genWDir, "/linglong/sources/files");
  if (!cmSystemTools::MakeDirectory(sourcesDir)) {
    cmCPackLogger(cmCPackLog::LOG_ERROR,
                  "CPackLinglong: Failed to create sources directory: "
                    << sourcesDir << std::endl);
    return 0;
  }

  // Copy installed files from the temporary directory to the sources directory
  cmCPackLogger(cmCPackLog::LOG_VERBOSE,
                "CPackLinglong: Copying files from "
                  << this->toplevel << " to " << sourcesDir << std::endl);
  for (std::string const& file : this->files) {
    if (file.length() <= this->toplevel.length() + 1) {
      continue;
    }
    std::string const relativePath =
      file.substr(this->toplevel.length() + 1);
    std::string const destPath = cmStrCat(sourcesDir, '/', relativePath);
    std::string const destDir = cmSystemTools::GetFilenamePath(destPath);
    cmSystemTools::MakeDirectory(destDir);
    if (!cmSystemTools::CopyFileAlways(file, destPath)) {
      cmCPackLogger(cmCPackLog::LOG_ERROR,
                    "CPackLinglong: Failed to copy file: "
                      << file << " to " << destPath << std::endl);
      return 0;
    }
  }

  // Run ll-builder build if enabled
  if (this->IsOn("CPACK_LINGLONG_RUN_BUILD")) {
    std::string const projectDir = *genWDir;
    cmCPackLogger(cmCPackLog::LOG_VERBOSE,
                  "CPackLinglong: Running ll-builder build in "
                    << projectDir << std::endl);

    std::vector<std::string> buildCommand = {
      "ll-builder", "build",
      "--skip-fetch-source",
      "--skip-pull-depend"
    };

    int retVal = 1;
    bool res = cmSystemTools::RunSingleCommand(
      buildCommand, nullptr, nullptr, &retVal, projectDir.c_str(),
      cmSystemTools::OutputOption::OUTPUT_PASSTHROUGH);
    if (!res || retVal) {
      cmCPackLogger(cmCPackLog::LOG_ERROR,
                    "CPackLinglong: ll-builder build failed."
                    << std::endl);
      return 0;
    }

    // Run ll-builder export
    cmValue packageId = this->GetOption("GEN_LINGLONG_PACKAGE_ID");
    cmValue packageVersion = this->GetOption("GEN_LINGLONG_PACKAGE_VERSION");
    cmValue architecture = this->GetOption("GEN_LINGLONG_ARCHITECTURE");
    cmValue outputFileName = this->GetOption("GEN_LINGLONG_OUTPUT_FILE_NAME");

    if (cmNonempty(packageId) && cmNonempty(packageVersion) &&
        cmNonempty(architecture) && cmNonempty(outputFileName)) {
      std::string const ref =
        cmStrCat(*packageId, '/', *packageVersion, '/', *architecture);
      std::string const outputPath =
        cmStrCat(this->GetOption("CPACK_TOPLEVEL_DIRECTORY"), '/',
                 *outputFileName);

      cmCPackLogger(cmCPackLog::LOG_VERBOSE,
                    "CPackLinglong: Running ll-builder export with ref: "
                      << ref << std::endl);

      std::vector<std::string> exportCommand = {
        "ll-builder", "export",
        "--ref", ref,
        "-o", outputPath
      };

      retVal = 1;
      res = cmSystemTools::RunSingleCommand(
        exportCommand, nullptr, nullptr, &retVal, projectDir.c_str(),
        cmSystemTools::OutputOption::OUTPUT_PASSTHROUGH);
      if (!res || retVal) {
        cmCPackLogger(cmCPackLog::LOG_ERROR,
                      "CPackLinglong: ll-builder export failed."
                      << std::endl);
        return 0;
      }

      this->packageFileNames.push_back(outputPath);
    }
  } else {
    cmCPackLogger(cmCPackLog::LOG_VERBOSE,
                  "CPackLinglong: ll-builder integration disabled. "
                  "Set CPACK_LINGLONG_RUN_BUILD to ON to enable."
                  << std::endl);
  }

  return 1;
}

bool cmCPackLinglongGenerator::SupportsComponentInstallation() const
{
  return false;
}
