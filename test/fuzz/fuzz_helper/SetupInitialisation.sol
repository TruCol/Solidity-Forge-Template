pragma solidity >=0.8.26 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { _TIMESTAMP_FILE_EXT, _FUZZ_TEST_LOGGING_DIR_NAME, _TEST_DIR_NAME } from "test/TestConstants.sol";
import { LogMapping } from "./LogMapping.sol";
import { WritingToFile } from "./WritingToFile.sol";

// solhint-disable foundry-test-functions
interface ISetupInitialisation {
  function setupFuzzCaseHitLogging(
    string memory fileNameWithoutExt,
    string memory testFunctionName,
    string memory relFilePathAfterTestDir
  ) external returns (LogMapping _logMapping);
}

contract SetupInitialisation is PRBTest, StdCheats, ISetupInitialisation {
  function setupFuzzCaseHitLogging(
    string memory fileNameWithoutExt,
    string memory testFunctionName,
    string memory relFilePathAfterTestDir
  ) public override returns (LogMapping _logMapping) {
    WritingToFile writingToFile = new WritingToFile();
    // Specify the path to this file, the test file name, and the fuzz test name, used for test case coverage logging.

    string memory testFilePath = string(
      abi.encodePacked(_TEST_DIR_NAME, "/", relFilePathAfterTestDir, "/", fileNameWithoutExt, ".sol")
    );
    writingToFile.assertRelativeFileExists(testFilePath);
    writingToFile.assertFileContainsSubstring(
      testFilePath,
      string(abi.encodePacked("function ", testFunctionName, "("))
    );

    // TODO: assert the specified test function exists in that file.
    string memory relTestLogTimestampFilePath = string(
      abi.encodePacked(_FUZZ_TEST_LOGGING_DIR_NAME, "/", relFilePathAfterTestDir, "/", fileNameWithoutExt)
    );

    // Create those directories that will contain the test coverage timestamp and logging files.
    vm.createDir(relTestLogTimestampFilePath, true);
    writingToFile.assertRelativeDirExists(relTestLogTimestampFilePath);

    /** I do not know exactly why, but per file, this yields a single timestamp regardless of how many fuzz runs are
    ran per test function. (As long as 1 fuzz test per file is used).*/
    if (vm.isFile(string(abi.encodePacked(relTestLogTimestampFilePath, _TIMESTAMP_FILE_EXT)))) {
      vm.removeFile(string(abi.encodePacked(relTestLogTimestampFilePath, _TIMESTAMP_FILE_EXT)));
    }
    // Set up test case hit counter logging.
    return new LogMapping(relTestLogTimestampFilePath, testFunctionName);
  }
}
