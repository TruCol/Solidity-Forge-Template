// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { Vm } from "forge-std/src/Vm.sol";
import "test/TestConstants.sol";
import { FuzzTestCaseCounter } from "./fuzz_helper/FuzzTestCaseCounter.sol";
import { IterableStringMapping } from "./fuzz_helper/IterableStringMapping.sol";
import { SetupInitialisation } from "./fuzz_helper/SetupInitialisation.sol";

contract FuzzTestWithHitRateAssertion is PRBTest, StdCheats {
  using IterableStringMapping for IterableStringMapping.Map;
  IterableStringMapping.Map private _variableNameMapping;

  FuzzTestCaseCounter private _logMapping;

  string private _hitRateFilePath;

  /** The setUp() method is called once each fuzz run.*/
  function setUp() public virtual {
    // Specify this testfilepath and fuzz test function for logging purposes.
    string memory fileNameWithoutExt = "FuzzTestWithHitRateAssertion";
    string memory testFunctionName = "testFuzzWithHitRateAssertion";
    string memory relFilePathAfterTestDir = string(abi.encodePacked("fuzz"));

    // Set up the hit rate logging structure.
    SetupInitialisation setupInitialisation = new SetupInitialisation();
    _logMapping = setupInitialisation.setupFuzzCaseHitLogging(
      fileNameWithoutExt,
      testFunctionName,
      relFilePathAfterTestDir
    );

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
