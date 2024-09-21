// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { Vm } from "forge-std/src/Vm.sol";
import "test/TestConstants.sol";
import { TestFileLogging } from "./../TestFileLogging.sol";
import { IterableStringMapping } from "./fuzz_helper/IterableStringMapping.sol";
import { TestIterableMapping } from "./fuzz_helper/TestIterableMapping.sol";

contract FuzzTest is PRBTest, StdCheats {
  using IterableStringMapping for IterableStringMapping.Map;
  IterableStringMapping.Map private _variableNameMapping;

  TestIterableMapping private _logMapping;
  TestFileLogging private _testFileLogging;

  string private _hitRateFilePath;

  function setUp() public virtual {
    _testFileLogging = new TestFileLogging();

    // Delete the temp file.
    if (vm.isFile(_LOG_TIME_CREATOR)) {
      vm.removeFile(_LOG_TIME_CREATOR);
    }
    _logMapping = new TestIterableMapping();

    _variableNameMapping.set("LargerThan", "a");
    _variableNameMapping.set("SmallerThan", "b");
    _variableNameMapping.set("Total", "c");
  }

  /**
  @dev The investor has invested 0.5 eth, and the investment target is 0.6 eth after 12 weeks.
  So the investment target is not reached, so all the funds should be returned.
   */
  function testFuzzDebug(uint256 randomValue) public virtual {
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
    TestIterableMapping logMapping,
    IterableStringMapping.Map storage variableNameMapping,
    string memory variableName
  ) internal virtual {
    logMapping.set(variableNameMapping.get(variableName), logMapping.get(variableNameMapping.get(variableName)) + 1);
  }
}
