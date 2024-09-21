// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { Vm } from "forge-std/src/Vm.sol";
import "test/TestConstants.sol";
import { FuzzTestCaseCounter } from "./fuzz_helper/FuzzTestCaseCounter.sol";
import { IterableStringMapping } from "./fuzz_helper/IterableStringMapping.sol";

contract FuzzTestWithHitRateAssertionCopy is PRBTest, StdCheats {
  using IterableStringMapping for IterableStringMapping.Map;
  IterableStringMapping.Map private _variableNameMapping;

  FuzzTestCaseCounter private _logMapping;

  string private _hitRateFilePath;

  /** The setUp() method is called once each fuzz run.*/
  function setUp() public virtual {
    string memory relBareFolderPath = "test_logging/fuzz";
    string memory fileNameWithoutExt = "FuzzTestWithHitRateAssertionCopy";
    string memory testFunctionName = "testFuzzWithHitRateAssertion";
    string memory relTestLogTimestampFilePath = string(abi.encodePacked(relBareFolderPath, "/", fileNameWithoutExt));
    emit Log("relTestLogTimestampFilePath=");
    emit Log(relTestLogTimestampFilePath);
    vm.createDir(relTestLogTimestampFilePath, true);
    vm.createDir(relBareFolderPath, true);

    // Delete the temp file at the start of running this test file.
    // if (vm.isFile(_LOG_TIME_CREATOR)) {
    if (vm.isFile(relTestLogTimestampFilePath)) {
      vm.removeFile(relTestLogTimestampFilePath);
      /** The _LOG_TIME_CREATOR file is recreated if it does not exist in: `new
      FuzzTestCaseCounter()` and then the timestamp of that file is taken as
      the log dir for that fuzz run.

      If the setUp() function would be called before each fuzz run, then it
      would (likely) create 1000 different timestamps if 1000 fuzz runs were
      ran.

      If the setUp() function would be called once before each fuzz run, then
      the _LOG_TIME_CREATOR file would be created by the first Fuzz run of a
      fuzz test.*/
    }
    _logMapping = new FuzzTestCaseCounter(relTestLogTimestampFilePath, testFunctionName);

    _variableNameMapping.set("LargerThan", "a");
    _variableNameMapping.set("SmallerThan", "b");
    _variableNameMapping.set("Total", "c");
  }

  /**
  @dev The investor has invested 0.5 eth, and the investment target is 0.6 eth after 12 weeks.
  So the investment target is not reached, so all the funds should be returned.
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

  function _incrementLogCount(
    FuzzTestCaseCounter logMapping,
    IterableStringMapping.Map storage variableNameMapping,
    string memory variableName
  ) internal virtual {
    logMapping.set(variableNameMapping.get(variableName), logMapping.get(variableNameMapping.get(variableName)) + 1);
  }
}
