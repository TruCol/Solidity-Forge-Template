// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { LogMapping } from "./fuzz_helper/LogMapping.sol";
import { ReadingNrOfFuzzRunsFromToml } from "./fuzz_helper/ReadingNrOfFuzzRunsFromToml.sol";
import { SetupInitialisation } from "./fuzz_helper/SetupInitialisation.sol";

interface IFuzzTestWithHitRateAssertion {
  function setUp() external virtual;

  function testFuzzCaseLogging(uint256 randomValue) external virtual;
}

contract FuzzTestWithHitRateAssertion is PRBTest, StdCheats, IFuzzTestWithHitRateAssertion {
  LogMapping private _logMapping;

  /** The setUp() method is called once each fuzz run.*/
  function setUp() public virtual override {
    ReadingNrOfFuzzRunsFromToml readingNrOfFuzzRunsFromToml = new ReadingNrOfFuzzRunsFromToml();
    readingNrOfFuzzRunsFromToml.readNrOfFuzzRunsFromToml();

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

    _logMapping.initialiseParameter("Total", 0, 7);
    _logMapping.initialiseParameter("LargerThan", 0, 5);
    _logMapping.initialiseParameter("SmallerThan", 0, 5);
  }

  /** Example of a basic fuzz test with a random variable. After the test, you can go to:

  <test_logging>/<relative path towards this file from test/><timestamp of the fuzz run>/
  <this_filename__this_test_function_name>_counter.txt

    to see how often each test case was hit.
   */
  function testFuzzCaseLogging(uint256 randomValue) public virtual override {
    _logMapping.readHitRatesFromLogFileAndSetToMap(_logMapping.getHitRateFilePath());

    if (randomValue > 4200) {
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
