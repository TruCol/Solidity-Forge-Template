// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import "forge-std/src/Vm.sol";
import "test/TestConstants.sol";
import { TestFileLogging } from "./../TestFileLogging.sol";
import { IterableStringMapping } from "./fuzz_helper/IterableStringMapping.sol";
import { TestIterableMapping } from "./fuzz_helper/TestIterableMapping.sol";
import { TestMathHelper } from "./fuzz_helper/TestMathHelper.sol";

struct HitRatesReturnAll {
  uint256 largeValue;
  uint256 smallValue;
}

interface IFuzzTest {
  function setUp() external;
}

contract FuzzTest is PRBTest, StdCheats, IFuzzTest {
  using IterableStringMapping for IterableStringMapping.Map;
  IterableStringMapping.Map private _variableNameMapping;

  TestIterableMapping private _testIterableMapping;
  TestFileLogging private _testFileLogging;

  TestMathHelper private _testMathHelper;
  string private _hitRateFilePath;

  function setUp() public virtual override {
    _testFileLogging = new TestFileLogging();
    _testMathHelper = new TestMathHelper();

    // Delete the temp file.
    if (vm.isFile(_LOG_TIME_CREATOR)) {
      vm.removeFile(_LOG_TIME_CREATOR);
    }
    _testIterableMapping = new TestIterableMapping();

    _variableNameMapping.set("LargerThan", "a");
    _variableNameMapping.set("SmallerThan", "b");
    _variableNameMapping.set("Total", "c");
  }

  /**
  @dev The investor has invested 0.5 eth, and the investment target is 0.6 eth after 12 weeks.
  So the investment target is not reached, so all the funds should be returned.
   */
  function testFuzzDebug(uint256 randomValue) public virtual {
    _testIterableMapping.readHitRatesFromLogFileAndSetToMap(_testIterableMapping.getHitRateFilePath());

    if (randomValue > 42) {
      _testIterableMapping.set(
        _variableNameMapping.get("LargerThan"),
        _testIterableMapping.get(_variableNameMapping.get("LargerThan")) + 1
      );
    } else {
      _testIterableMapping.set(
        _variableNameMapping.get("SmallerThan"),
        _testIterableMapping.get(_variableNameMapping.get("SmallerThan")) + 1
      );
    }
    _testIterableMapping.set(
      _variableNameMapping.get("Total"),
      _testIterableMapping.get(_variableNameMapping.get("Total")) + 1
    );
    emit Log("Overwriting with:");
    emit Log(_variableNameMapping.get("SmallerThan"));
    emit Log(Strings.toString(_testIterableMapping.get(_variableNameMapping.get("SmallerThan"))));
    _testIterableMapping.overwriteExistingMapLogFile(_testIterableMapping.getHitRateFilePath());
  }
}
