// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { Vm } from "forge-std/src/Vm.sol";
import "test/TestConstants.sol";
import { FuzzTestCaseCounter } from "./fuzz_helper/FuzzTestCaseCounter.sol";
import { IterableStringMapping } from "./fuzz_helper/IterableStringMapping.sol";

contract FuzzTestWithHitRateAssertion is PRBTest, StdCheats {
  using IterableStringMapping for IterableStringMapping.Map;
  IterableStringMapping.Map private _variableNameMapping;

  FuzzTestCaseCounter private _logMapping;

  string private _hitRateFilePath;

  /** The setUp() method is called once each fuzz run.*/
  function setUp() public virtual {
    // Specify the path to this file, the test file name, and the fuzz test name, used for test case coverage logging.
    string memory relBareFolderPath = "test_logging/fuzz";
    string memory fileNameWithoutExt = "FuzzTestWithHitRateAssertion";
    string memory testFunctionName = "testFuzzWithHitRateAssertion";
    string memory relTestLogTimestampFilePath = string(abi.encodePacked(relBareFolderPath, "/", fileNameWithoutExt));

    // Create those directories that will contain the test coverage timestamp and logging files.
    vm.createDir(relBareFolderPath, true);
    vm.createDir(relTestLogTimestampFilePath, true);

    /** I do not know exactly why, but per file, this yields a single timestamp regardless of how many fuzz runs are
    ran per test function. (As long as 1 fuzz test per file is used).*/
    if (vm.isFile(string(abi.encodePacked(relTestLogTimestampFilePath, _TIMESTAMP_FILE_EXT)))) {
      vm.removeFile(string(abi.encodePacked(relTestLogTimestampFilePath, _TIMESTAMP_FILE_EXT)));
    }
    // Set up test case hit counter logging.
    _logMapping = new FuzzTestCaseCounter(relTestLogTimestampFilePath, testFunctionName);

    // Specify which test cases are logged within this test file.
    _variableNameMapping.set("LargerThan", "a");
    _variableNameMapping.set("SmallerThan", "b");
    _variableNameMapping.set("Total", "c");
  }

  /** Example of a basic fuzz test with a random variable. After the test, you can go to:

  <test_logging>/<relative path towards this file from test/><timestamp of the fuzz run>/
  <this_filename__this_test_function_name>_counter.txt

  to see how often each test case was hit.
   */
  function testFuzzDebugtestFuzzWithHitRateAssertion(uint256 randomValue) public virtual {
    _logMapping.readHitRatesFromLogFileAndSetToMap(_logMapping.getHitRateFilePath());

    if (randomValue > 42) {
      _incrementLogCount(_logMapping, _variableNameMapping, "LargerThan");
    } else {
      _incrementLogCount(_logMapping, _variableNameMapping, "SmallerThan");
    }
    _incrementLogCount(_logMapping, _variableNameMapping, "Total");
    _logMapping.overwriteExistingMapLogFile(_logMapping.getHitRateFilePath());
  }

  /**Increments the test case hit counts in the testIterableMapping
   */
  function _incrementLogCount(
    FuzzTestCaseCounter logMapping,
    IterableStringMapping.Map storage variableNameMapping,
    string memory variableName
  ) internal virtual {
    logMapping.set(variableNameMapping.get(variableName), logMapping.get(variableNameMapping.get(variableName)) + 1);
  }
}
