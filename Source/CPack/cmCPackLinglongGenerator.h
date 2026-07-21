/* Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
   file LICENSE.rst or https://cmake.org/licensing for details.  */
#pragma once

#include "cmConfigure.h" // IWYU pragma: keep

#include <string>

#include "cmCPackGenerator.h"

/** \class cmCPackLinglongGenerator
 * \brief A generator for Linglong (玲珑) packages
 *
 * This generator creates Linglong (linyaps) packages (.uab format)
 * by generating linglong.yaml configuration files and invoking
 * ll-builder build and ll-builder export.
 */
class cmCPackLinglongGenerator : public cmCPackGenerator
{
public:
  cmCPackTypeMacro(cmCPackLinglongGenerator, cmCPackGenerator);

  /**
   * Construct generator
   */
  cmCPackLinglongGenerator();
  ~cmCPackLinglongGenerator() override;

  static bool CanGenerate()
  {
    return !cmSystemTools::FindProgram("ll-builder").empty();
  }

protected:
  int InitializeInternal() override;
  int PackageFiles() override;
  char const* GetOutputExtension() override { return ".uab"; }
  bool SupportsComponentInstallation() const override;

private:
};
