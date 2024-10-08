// SPDX-License-Identifier: MIT
pragma solidity >=0.8.26 <0.9.0;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { stdJson } from "forge-std/src/StdJson.sol";
import { Vm } from "forge-std/src/Vm.sol";
import "test/TestConstants.sol";
import { TestCaseHitRateLoggerToFile } from "./fuzz_helper/TestCaseHitRateLoggerToFile.sol";
import { Tuple } from "./fuzz_helper/Tuple.sol"; // Correct import for stdJson

contract TupleExportA is PRBTest, StdCheats {
  using stdJson for string;

  Tuple.StringUint256 public data;
  string public filePath = "./tuple_data.json";

  function testStoreAndLoadTupleA() public {
    // Arrange
    string memory testStr = "Hello, Forge!";
    uint256 testNum = 12345;

    // Store the tuple
    _storeTuple(testStr, testNum, filePath);

    // Reset the data
    data = Tuple.StringUint256({ str: "", number: 0 });

    // Act: Load the tuple back
    // _loadTuple(filePath);

    // Assert
    assertEq(data.str, testStr);
    assertEq(data.number, testNum);
  }

  function _storeTuple(string memory _str, uint256 _num, string memory _filePath) internal {
    Tuple.StringUint256 memory tuple = Tuple.StringUint256({ str: _str, number: _num });

    // Serialize both string and number into one JSON object
    string memory jsonData = vm.serializeUint("", "number", tuple.number);
    jsonData = vm.serializeString(jsonData, "str", tuple.str);

    vm.writeFile(_filePath, jsonData);
  }

  function _loadTuple(string memory _filePath) internal {
    string memory jsonData = vm.readFile(_filePath);
    data.number = jsonData.readUint("number");
    data.str = jsonData.readString("str");
  }
}
