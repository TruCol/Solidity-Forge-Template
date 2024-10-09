// SPDX-License-Identifier: MIT
pragma solidity >=0.8.26 <0.9.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { stdJson } from "forge-std/src/StdJson.sol";
import { Vm } from "forge-std/src/Vm.sol";
import "test/TestConstants.sol";
import { TestCaseHitRateLoggerToFile } from "./fuzz_helper/TestCaseHitRateLoggerToFile.sol";
import { Tuple } from "./fuzz_helper/Tuple.sol";

struct SomeVariableStruct {
  uint256 some_number;
  string string_title;
}

contract TupleExportB is PRBTest, StdCheats {
  using stdJson for string;

  Tuple.StringUint256 public data;
  string public filePath = "./tuple_dataB.json";

  function testStoreAndLoadTupleB() public {
    // Arrange
    string memory testStr = "Hello, Forge!";
    uint256 testNum = 12345;

    // Store the tuple
    _storeTuple(testStr, testNum, filePath);

    // Reset the data
    data = Tuple.StringUint256({ str: "", number: 0 });

    assertEq(data.str, "");
    assertEq(data.number, 0);

    // Act: Load the tuple back
    _loadTuple(filePath);

    // Assert
    assertEq(data.str, "Hello, Forge!");
    assertEq(data.number, 12345);
  }

  function _storeTuple(string memory _str, uint256 _num, string memory _filePath) internal {
    // Tuple.StringUint256 memory tuple = Tuple.StringUint256({ str: _str, number: _num });

    string memory obj1 = "ThisDissapearsIntoTheVoidForTheFirstKey";
    vm.serializeUint(obj1, "some_number", _num);
    string memory output = vm.serializeString(obj1, "string_title", _str);
    vm.writeJson(output, _filePath);
  }

  function _loadTuple(string memory _filePath) internal {
    string memory json = vm.readFile(_filePath);
    bytes memory jsonData = vm.parseJson(json);
    // string memory jsonData = vm.readFile(_filePath);
    SomeVariableStruct memory someVariableStruct = abi.decode(jsonData, (SomeVariableStruct));

    // data.number = jsonData.readUint("some_number");
    // data.str = jsonData.readString("string_title");
    data.number = someVariableStruct.some_number;
    data.str = someVariableStruct.string_title;
  }
}
