# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.rst or https://cmake.org/licensing for details.

# CPack script for creating Linglong (linyaps) packages
#
# This module prepares and validates CPack variables for Linglong
# package generation, then writes the linglong.yaml configuration file.

if(CMAKE_BINARY_DIR)
  message(FATAL_ERROR "CPackLinglong.cmake may only be used by CPack internally.")
endif()

function(cpack_linglong_variable_fallback OUTPUT_VAR_NAME)
  set(FALLBACK_VAR_NAMES ${ARGN})

  foreach(variable_name IN LISTS FALLBACK_VAR_NAMES)
    if(DEFINED ${variable_name})
      set(${OUTPUT_VAR_NAME} "${${variable_name}}")
      set(${OUTPUT_VAR_NAME} "${${variable_name}}" PARENT_SCOPE)
      return()
    endif()
  endforeach()
endfunction()

function(cpack_linglong_prepare_package_vars)
  # Package ID: (mandatory)
  # Use reverse domain notation, e.g. "org.kde.games.ksudoku"
  if(NOT CPACK_LINGLONG_PACKAGE_ID)
    if(CPACK_PACKAGE_NAME)
      string(TOLOWER "${CPACK_PACKAGE_NAME}" CPACK_LINGLONG_PACKAGE_ID)
    else()
      message(FATAL_ERROR
        "CPackLinglong: Linglong package requires a package ID. "
        "Set CPACK_LINGLONG_PACKAGE_ID or CPACK_PACKAGE_NAME.")
    endif()
  endif()
  string(TOLOWER "${CPACK_LINGLONG_PACKAGE_ID}" CPACK_LINGLONG_PACKAGE_ID)

  # Package Name: (mandatory)
  if(NOT CPACK_LINGLONG_PACKAGE_NAME)
    set(CPACK_LINGLONG_PACKAGE_NAME "${CPACK_PACKAGE_NAME}")
  endif()

  # Package Version: (mandatory, must be 4-part dot-separated)
  if(NOT CPACK_LINGLONG_PACKAGE_VERSION)
    set(CPACK_LINGLONG_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}")
  endif()

  # Ensure 4-part version format (e.g., "1.2.3.0")
  string(REPLACE "." ";" _version_parts "${CPACK_LINGLONG_PACKAGE_VERSION}")
  list(LENGTH _version_parts _version_len)
  while(_version_len LESS 4)
    list(APPEND _version_parts "0")
    math(EXPR _version_len "${_version_len} + 1")
  endwhile()
  list(JOIN _version_parts "." CPACK_LINGLONG_PACKAGE_VERSION)

  # Package Kind: (mandatory, "app" or "runtime")
  if(NOT CPACK_LINGLONG_PACKAGE_KIND)
    set(CPACK_LINGLONG_PACKAGE_KIND "app")
  endif()
  if(NOT CPACK_LINGLONG_PACKAGE_KIND MATCHES "^(app|runtime)$")
    message(FATAL_ERROR
      "CPackLinglong: Package kind must be 'app' or 'runtime', "
      "got '${CPACK_LINGLONG_PACKAGE_KIND}'.")
  endif()

  # Package Description: (mandatory)
  cpack_linglong_variable_fallback(
        CPACK_LINGLONG_PACKAGE_DESCRIPTION
    CPACK_PACKAGE_DESCRIPTION_SUMMARY
  )
  if(NOT CPACK_LINGLONG_PACKAGE_DESCRIPTION)
    set(CPACK_LINGLONG_PACKAGE_DESCRIPTION "${CPACK_PACKAGE_NAME}")
  endif()

  # Base: (mandatory)
  if(NOT CPACK_LINGLONG_BASE)
    message(FATAL_ERROR
      "CPackLinglong: Linglong package requires a base environment. "
      "Set CPACK_LINGLONG_BASE, e.g. 'org.deepin.base/25.2.2'.")
  endif()

  # Command: (mandatory for app kind)
  if(CPACK_LINGLONG_PACKAGE_KIND STREQUAL "app")
    if(NOT CPACK_LINGLONG_COMMAND)
      message(FATAL_ERROR
        "CPackLinglong: App packages require a command. "
        "Set CPACK_LINGLONG_COMMAND.")
    endif()
    if(NOT CPACK_LINGLONG_COMMAND MATCHES "^/")
      set(CPACK_LINGLONG_COMMAND
        "/opt/apps/${CPACK_LINGLONG_PACKAGE_ID}/files/bin/${CPACK_LINGLONG_COMMAND}")
    endif()
  endif()

  # Architecture: (optional, auto-detect)
  if(NOT CPACK_LINGLONG_ARCHITECTURE)
    find_program(DPKG_EXECUTABLE dpkg)
    if(DPKG_EXECUTABLE)
      execute_process(
        COMMAND "${DPKG_EXECUTABLE}" --print-architecture
        OUTPUT_VARIABLE CPACK_LINGLONG_ARCHITECTURE
        OUTPUT_STRIP_TRAILING_WHITESPACE
      )
    else()
      set(CPACK_LINGLONG_ARCHITECTURE "x86_64")
    endif()
  endif()

  # Build commands: (optional)
  if(NOT CPACK_LINGLONG_BUILD_COMMANDS)
    set(CPACK_LINGLONG_BUILD_COMMANDS
      "cp -r /project/linglong/sources/files/* \${PREFIX}/")
  endif()

  # Output file name
  if(NOT CPACK_LINGLONG_FILE_NAME)
    set(CPACK_LINGLONG_FILE_NAME
      "${CPACK_LINGLONG_PACKAGE_ID}_${CPACK_LINGLONG_PACKAGE_VERSION}_${CPACK_LINGLONG_ARCHITECTURE}.uab")
  endif()

  # Generate the working directory path
  if(CPACK_TOPLEVEL_DIRECTORY AND CPACK_PACKAGE_FILE_NAME)
    cmake_path(
      APPEND CPACK_TOPLEVEL_DIRECTORY "${CPACK_PACKAGE_FILE_NAME}"
      OUTPUT_VARIABLE WDIR
    )
  elseif(CPACK_TEMPORARY_DIRECTORY)
    set(WDIR "${CPACK_TEMPORARY_DIRECTORY}")
  else()
    set(WDIR "${CMAKE_CURRENT_BINARY_DIR}")
  endif()

  # Export variables to parent scope
  set(GEN_LINGLONG_PACKAGE_ID "${CPACK_LINGLONG_PACKAGE_ID}" PARENT_SCOPE)
  set(GEN_LINGLONG_PACKAGE_NAME "${CPACK_LINGLONG_PACKAGE_NAME}" PARENT_SCOPE)
  set(GEN_LINGLONG_PACKAGE_VERSION "${CPACK_LINGLONG_PACKAGE_VERSION}" PARENT_SCOPE)
  set(GEN_LINGLONG_PACKAGE_KIND "${CPACK_LINGLONG_PACKAGE_KIND}" PARENT_SCOPE)
  set(GEN_LINGLONG_PACKAGE_DESCRIPTION "${CPACK_LINGLONG_PACKAGE_DESCRIPTION}" PARENT_SCOPE)
  set(GEN_LINGLONG_BASE "${CPACK_LINGLONG_BASE}" PARENT_SCOPE)
  set(GEN_LINGLONG_RUNTIME "${CPACK_LINGLONG_RUNTIME}" PARENT_SCOPE)
  set(GEN_LINGLONG_COMMAND "${CPACK_LINGLONG_COMMAND}" PARENT_SCOPE)
  set(GEN_LINGLONG_ARCHITECTURE "${CPACK_LINGLONG_ARCHITECTURE}" PARENT_SCOPE)
  set(GEN_LINGLONG_BUILD_DEPENDS "${CPACK_LINGLONG_BUILD_DEPENDS}" PARENT_SCOPE)
  set(GEN_LINGLONG_DEPENDS "${CPACK_LINGLONG_DEPENDS}" PARENT_SCOPE)
  set(GEN_LINGLONG_BUILD_COMMANDS "${CPACK_LINGLONG_BUILD_COMMANDS}" PARENT_SCOPE)
  set(GEN_LINGLONG_OUTPUT_FILE_NAME "${CPACK_LINGLONG_FILE_NAME}" PARENT_SCOPE)
  set(GEN_WDIR "${WDIR}" PARENT_SCOPE)
endfunction()

function(cpack_linglong_generate_yaml)
  # Generate linglong.yaml from prepared variables
  cmake_path(
    APPEND GEN_WDIR "linglong.yaml"
    OUTPUT_VARIABLE YAML_FILE
  )

  file(WRITE "${YAML_FILE}"
    "version: \"1\"\n"
    "\n"
    "package:\n"
    "  id: ${GEN_LINGLONG_PACKAGE_ID}\n"
    "  name: ${GEN_LINGLONG_PACKAGE_NAME}\n"
    "  version: ${GEN_LINGLONG_PACKAGE_VERSION}\n"
    "  kind: ${GEN_LINGLONG_PACKAGE_KIND}\n"
    "  description: |\n"
    "    ${GEN_LINGLONG_PACKAGE_DESCRIPTION}\n"
  )

  if(GEN_LINGLONG_ARCHITECTURE)
    file(APPEND "${YAML_FILE}"
      "  architecture: ${GEN_LINGLONG_ARCHITECTURE}\n"
    )
  endif()

  file(APPEND "${YAML_FILE}" "\n")

  if(GEN_LINGLONG_COMMAND)
    file(APPEND "${YAML_FILE}"
      "command:\n"
      "  - ${GEN_LINGLONG_COMMAND}\n"
      "\n"
    )
  endif()

  file(APPEND "${YAML_FILE}"
    "base: ${GEN_LINGLONG_BASE}\n"
  )

  if(GEN_LINGLONG_RUNTIME)
    file(APPEND "${YAML_FILE}"
      "runtime: ${GEN_LINGLONG_RUNTIME}\n"
    )
  endif()

  file(APPEND "${YAML_FILE}" "\n")

  # Build dependencies (buildext section)
  if(GEN_LINGLONG_BUILD_DEPENDS OR GEN_LINGLONG_DEPENDS)
    file(APPEND "${YAML_FILE}"
      "buildext:\n"
      "  apt:\n"
    )
    if(GEN_LINGLONG_BUILD_DEPENDS)
      file(APPEND "${YAML_FILE}"
        "    build_depends:\n"
      )
      foreach(_dep IN LISTS GEN_LINGLONG_BUILD_DEPENDS)
        file(APPEND "${YAML_FILE}"
          "      - ${_dep}\n"
        )
      endforeach()
    endif()
    if(GEN_LINGLONG_DEPENDS)
      file(APPEND "${YAML_FILE}"
        "    depends:\n"
      )
      foreach(_dep IN LISTS GEN_LINGLONG_DEPENDS)
        file(APPEND "${YAML_FILE}"
          "      - ${_dep}\n"
        )
      endforeach()
    endif()
    file(APPEND "${YAML_FILE}" "\n")
  endif()

  # Build commands
  file(APPEND "${YAML_FILE}"
    "build: |\n"
    "  ${GEN_LINGLONG_BUILD_COMMANDS}\n"
  )
endfunction()

# Main execution
cpack_linglong_prepare_package_vars()
cpack_linglong_generate_yaml()
