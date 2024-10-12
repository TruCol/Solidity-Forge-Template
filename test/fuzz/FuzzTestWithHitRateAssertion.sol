// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { Vm } from "forge-std/src/Vm.sol";
import "test/TestConstants.sol";
import { FuzzTestCaseCounter } from "./fuzz_helper/FuzzTestCaseCounter.sol";
import { IterableTripleMapping } from "./fuzz_helper/IterableTripleMapping.sol";
import { SetupInitialisation } from "./fuzz_helper/SetupInitialisation.sol";

contract FuzzTestWithHitRateAssertion is PRBTest, StdCheats {
  using IterableTripleMapping for IterableTripleMapping.Map;
  IterableTripleMapping.Map private _tupleMapping;

  FuzzTestCaseCounter private _logMapping;

  string private _hitRateFilePath;

  /** The setUp() method is called once each fuzz run.*/
  function setUp() public virtual {
    // Specify this testfilepath and fuzz test function for logging purposes.
    string memory fileNameWithoutExt = "FuzzTestWithHitRateAssertion";
    string memory testFunctionName = "testFuzzCaseLogging";
    string memory relFilePathAfterTestDir = string(abi.encodePacked("fuzz"));

    // Set up the hit rate logging structure.
    SetupInitialisation setupInitialisation = new SetupInitialisation();
    _logMapping = setupInitialisation.setupFuzzCaseHitLogging(
      fileNameWithoutExt,
      testFunctionName,
      relFilePathAfterTestDir
    );
  }

  /** Example of a basic fuzz test with a random variable. After the test, you can go to:

  <test_logging>/<relative path towards this file from test/><timestamp of the fuzz run>/
  <this_filename__this_test_function_name>_counter.txt

    to see how often each test case was hit.
   */
  function testFuzzCaseLogging(uint256 randomValue) public virtual {
    emit Log("FIRST CALL");
    _logMapping.readHitRatesFromLogFileAndSetToMap(_logMapping.getHitRateFilePath());

    if (randomValue > 42) {
      // _tupleMapping.incrementLogCount("LargerThan");
      _logMapping.callIncrementLogCount("LargerThan");
    } else {
      // _tupleMapping.incrementLogCount("SmallerThan");
      _logMapping.callIncrementLogCount("SmallerThan");
    }
    // _tupleMapping.incrementLogCount("Total");
    _logMapping.callIncrementLogCount("Total");

    _logMapping.overwriteExistingMapLogFile(_logMapping.getHitRateFilePath());
  }
}
