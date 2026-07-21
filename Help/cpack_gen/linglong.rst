CPack Linglong Generator
-----------------------

The built in (binary) CPack Linglong generator (Linux only)

Variables specific to CPack Linglong (LINGLONG) generator
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The CPack Linglong generator may be used to create Linglong (linyaps) packages
using :module:`CPack`. The CPack Linglong generator is a :module:`CPack`
generator thus it uses the :variable:`!CPACK_XXX` variables used by
:module:`CPack`.

The CPack Linglong generator requires the ``ll-builder`` tool from the
``linglong-builder`` package to be available on the system. It generates a
``linglong.yaml`` configuration file and invokes ``ll-builder build`` and
``ll-builder export`` to produce a ``.uab`` (Universal Application Bundle)
package file.

List of CPack Linglong generator specific variables:

.. variable:: CPACK_LINGLONG_PACKAGE_ID

 The Linglong package ID in reverse domain notation.

 :Mandatory: Yes
 :Default: :variable:`CPACK_PACKAGE_NAME` (converted to lower case)

 Example: ``org.kde.games.ksudoku``

.. variable:: CPACK_LINGLONG_PACKAGE_NAME

 The Linglong package name.

 :Mandatory: Yes
 :Default: :variable:`CPACK_PACKAGE_NAME`

.. variable:: CPACK_LINGLONG_PACKAGE_VERSION

 The Linglong package version. Must be a 4-part dot-separated version string
 (e.g. ``1.2.3.0``). If fewer than 4 parts are provided, trailing zeros are
 appended.

 :Mandatory: Yes
 :Default: :variable:`CPACK_PACKAGE_VERSION`

.. variable:: CPACK_LINGLONG_PACKAGE_KIND

 The Linglong package kind.

 :Mandatory: Yes
 :Default: ``app``

 Possible values: ``app``, ``runtime``

.. variable:: CPACK_LINGLONG_PACKAGE_DESCRIPTION

 The Linglong package description.

 :Mandatory: Yes
 :Default: :variable:`CPACK_PACKAGE_DESCRIPTION_SUMMARY`

.. variable:: CPACK_LINGLONG_BASE

 The Linglong base environment. This is the minimal root filesystem for the
 application.

 :Mandatory: Yes
 :Default: None

 Example: ``org.deepin.base/25.2.2``

.. variable:: CPACK_LINGLONG_RUNTIME

 The Linglong runtime environment. This provides additional framework
 libraries (e.g. Qt, DTK) for the application.

 :Mandatory: No
 :Default: None

 Example: ``org.deepin.runtime.dtk/25.2.2``

.. variable:: CPACK_LINGLONG_COMMAND

 The command to run the application. For ``app`` kind packages, this is
 mandatory. If the command does not start with ``/``, it will be prefixed
 with the Linglong install path.

 :Mandatory: Yes (for ``app`` kind)
 :Default: None

 Example: ``start.bash``

.. variable:: CPACK_LINGLONG_BUILD_DEPENDS

 List of build dependencies for the ``buildext`` section.

 :Mandatory: No
 :Default: None

.. variable:: CPACK_LINGLONG_DEPENDS

 List of runtime dependencies for the ``buildext`` section.

 :Mandatory: No
 :Default: None

.. variable:: CPACK_LINGLONG_BUILD_COMMANDS

 Custom build commands for the ``build`` section of ``linglong.yaml``.
 If not set, a default command that copies files from the project sources
 to the install prefix is used.

 :Mandatory: No
 :Default: ``cp -r /project/linglong/sources/files/* \${PREFIX}/``

.. variable:: CPACK_LINGLONG_ARCHITECTURE

 The target architecture for the package.

 :Mandatory: No
 :Default: Output of ``dpkg --print-architecture`` (or ``x86_64`` if
   ``dpkg`` is not found)

.. variable:: CPACK_LINGLONG_FILE_NAME

 The output file name for the generated ``.uab`` package.

 :Mandatory: No
 :Default: ``<CPACK_LINGLONG_PACKAGE_ID>_<CPACK_LINGLONG_PACKAGE_VERSION>_<CPACK_LINGLONG_ARCHITECTURE>.uab``

.. variable:: CPACK_LINGLONG_RUN_BUILD

 Enable or disable running ``ll-builder build`` and ``ll-builder export``
 during packaging. When disabled, only the ``linglong.yaml`` configuration
 file is generated, allowing the user to run ``ll-builder`` manually.

 :Mandatory: No
 :Default: ``OFF``

Example
^^^^^^^

.. code-block:: cmake

  set(CPACK_GENERATOR "LINGLONG")
  set(CPACK_PACKAGE_NAME "demo")
  set(CPACK_PACKAGE_VERSION "1.0.0.0")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A simple demo app.")

  set(CPACK_LINGLONG_PACKAGE_ID "cn.org.linyaps.demo")
  set(CPACK_LINGLONG_PACKAGE_NAME "demo")
  set(CPACK_LINGLONG_PACKAGE_VERSION "1.0.0.0")
  set(CPACK_LINGLONG_PACKAGE_KIND "app")
  set(CPACK_LINGLONG_PACKAGE_DESCRIPTION "A simple demo app.")
  set(CPACK_LINGLONG_COMMAND "start.bash")
  set(CPACK_LINGLONG_BASE "org.deepin.base/23.1.0")
  set(CPACK_LINGLONG_RUNTIME "org.deepin.runtime.dtk/23.1.0")

  include(CPack)
