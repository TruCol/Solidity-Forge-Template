// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { LogMapping } from "./fuzz_helper/LogMapping.sol";
import { ReadingNrOfFuzzRunsFromToml } from "./fuzz_helper/ReadingNrOfFuzzRunsFromToml.sol";
import { SetupInitialisation } from "./fuzz_helper/SetupInitialisation.sol";
error InvalidTotal(uint256 largerThan, uint256 smallerThan, uint256 total);
error SomeFuzzCaseNotReachedEnough(string message, uint256 hitCount, uint256 requiredHitCount, uint256 total);

interface IFuzzTestWithHitRateAssertion {
  function setUp() external virtual;

  function testFuzzCaseLogging(uint256 randomValue) external virtual;

  // solhint-disable-next-line foundry-test-functions
  function assertCoverage(uint256 totalNrOfFuzzRuns) external;
}

contract FuzzTestWithHitRateAssertion is PRBTest, StdCheats, IFuzzTestWithHitRateAssertion {
  LogMapping private _logMapping;
  uint256 private _totalNrOfFuzzRuns;

  /** The setUp() method is called once each fuzz run.*/
  function setUp() public virtual override {
    ReadingNrOfFuzzRunsFromToml readingNrOfFuzzRunsFromToml = new ReadingNrOfFuzzRunsFromToml();
    _totalNrOfFuzzRuns = readingNrOfFuzzRunsFromToml.readNrOfFuzzRunsFromToml();

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

    _logMapping.initialiseParameter("Total", 0, 5);
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

    assertCoverage(_totalNrOfFuzzRuns);
    _logMapping.overwriteExistingMapLogFile(_logMapping.getHitRateFilePath());
  }

  // solhint-disable-next-line foundry-test-functions
  function assertCoverage(uint256 totalNrOfFuzzRuns) public override {
    emit Log("totalNrOfFuzzRuns=");
    emit Log(Strings.toString(totalNrOfFuzzRuns));
    emit Log("hitCount=");
    emit Log(Strings.toString(_logMapping.get("Total").hitCount));
    emit Log("Done getting.");

    emit Log("FOUND EQUALITY");

    // TODO: determine why this does not throw an error.
    if (
      _logMapping.get("LargerThan").hitCount + _logMapping.get("SmallerThan").hitCount !=
      _logMapping.get("Total").hitCount
    ) {
      revert InvalidTotal(
        _logMapping.get("LargerThan").hitCount,
        _logMapping.get("SmallerThan").hitCount,
        _logMapping.get("Total").hitCount
      );
    }

    // TODO: determine why the _+3 is necessary.
    if (totalNrOfFuzzRuns + 3 == _logMapping.get("Total").hitCount) {
      if (
        _logMapping.get("LargerThan").hitCount < _logMapping.get("LargerThan").requiredHitCount ||
        _logMapping.get("LargerThan").hitCount == 0
      ) {
        revert SomeFuzzCaseNotReachedEnough(
          "Error, did not hit the LargerThan fuzz case often enough:",
          _logMapping.get("LargerThan").hitCount,
          _logMapping.get("LargerThan").requiredHitCount,
          _logMapping.get("Total").hitCount
        );
      }

      if (
        _logMapping.get("SmallerThan").hitCount < _logMapping.get("SmallerThan").requiredHitCount ||
        _logMapping.get("SmallerThan").hitCount == 0
      ) {
        revert SomeFuzzCaseNotReachedEnough(
          "Error, did not hit the SmallerThan fuzz case often enough:",
          _logMapping.get("SmallerThan").hitCount,
          _logMapping.get("SmallerThan").requiredHitCount,
          _logMapping.get("Total").hitCount
        );
      }
    }
  }
}
