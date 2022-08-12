# Appcircle Android Unit Tests

This step runs the unit tests of the project. Test results will be included in the artifacts archive.

Required Input Variables
- `$AC_REPOSITORY_DIR`: Specifies the cloned repository path
- `$AC_MODULE`: Specifies the project module for build
- `$AC_VARIANTS`: Specifies build variants

Optional Input Variables
- `$AC_PROJECT_PATH`: Specifies the project path. Defaults to `./`

Output Variables
- `$AC_TEST_RESULT_PATH`: The directory where your Junit XML report will be written to
