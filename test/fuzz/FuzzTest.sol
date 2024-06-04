// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;

import "forge-std/src/Vm.sol" as vm;
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "test/TestConstants.sol";
import { TestFileLogging } from "../TestFileLogging.sol";

struct HitRatesReturnAll {
  uint256 largeValue;
  uint256 smallValue;
}

interface IFuzzTest {
  function setUp() external;

  // solhint-disable-next-line foundry-test-functions
  function converthitRatesToString(
    HitRatesReturnAll memory hitRates
  ) external returns (string memory serialisedTextString);

  // solhint-disable-next-line foundry-test-functions
  function updateLogFile() external returns (string memory hitRateFilePath, HitRatesReturnAll memory hitRates);

  function testFuzzDebug(uint256 randomValue) external;

  // solhint-disable-next-line foundry-test-functions
  function initialiseHitRates() external pure returns (HitRatesReturnAll memory hitRates);
}

contract FuzzTest is PRBTest, StdCheats, IFuzzTest {
  address internal _projectLead;
  TestFileLogging private _testFileLogging;

  // solhint-disable-next-line foundry-test-functions
  function converthitRatesToString(
    HitRatesReturnAll memory hitRates
  ) public override returns (string memory serialisedTextString) {
    string memory obj1 = "ThisValueDissapearsIntoTheVoid";
    vm.serializeUint(obj1, "largeValue", hitRates.largeValue);
    serialisedTextString = vm.serializeUint(obj1, "smallValue", hitRates.smallValue);
    return serialisedTextString;
  }

  // solhint-disable-next-line foundry-test-functions
  function updateLogFile() public override returns (string memory hitRateFilePath, HitRatesReturnAll memory hitRates) {
    // solhint-disable-next-line foundry-test-functions
    hitRates = initialiseHitRates();
    // Output hit rates to file if they do not exist yet.
    // solhint-disable-next-line foundry-test-functions
    string memory serialisedTextString = converthitRatesToString(hitRates);
    hitRateFilePath = _testFileLogging.createLogFileIfItDoesNotExist(_LOG_TIME_CREATOR, serialisedTextString);
    // Read the latest hitRates from file.
    bytes memory data = _testFileLogging.readDataFromFile(hitRateFilePath);
    hitRates = abi.decode(data, (HitRatesReturnAll));

    return (hitRateFilePath, hitRates);
  }

  function setUp() public virtual override {
    _testFileLogging = new TestFileLogging();
    // Delete the temp file if it already exists.
    if (vm.isFile(_LOG_TIME_CREATOR)) {
      vm.removeFile(_LOG_TIME_CREATOR);
    }
  }

  /**
  @dev The investor has invested 0.5 eth, and the investment target is 0.6 eth after 12 weeks.
  So the investment target is not reached, so all the funds should be returned.
   */
  function testFuzzDebug(uint256 randomValue) public virtual override {
    // solhint-disable-next-line foundry-test-functions
    (string memory hitRateFilePath, HitRatesReturnAll memory hitRates) = updateLogFile();

    if (randomValue > 42) {
      ++hitRates.largeValue;
    } else {
      ++hitRates.smallValue;
    }
    emit Log("Outputting File");
    string memory serialisedTextString = converthitRatesToString(hitRates);
    _testFileLogging.overwriteFileContent(serialisedTextString, hitRateFilePath);
    emit Log("Outputted File");
  }

  // solhint-disable-next-line foundry-test-functions
  function initialiseHitRates() public pure override returns (HitRatesReturnAll memory hitRates) {
    return HitRatesReturnAll({ largeValue: 0, smallValue: 0 });
  }
}
