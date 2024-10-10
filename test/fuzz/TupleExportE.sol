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

struct Parameters {
  SomeVariableStruct[] tuples;
  string name;
}

struct SomeVariableStruct {
  uint256 some_number;
  string string_title;
}

contract TupleExportA is PRBTest, StdCheats {
  using stdJson for string;

  Tuple.StringUint256 public data;

  string public filePath = "./tuple_dataE.json";
  Parameters public parameters;

  function testStoreAndLoadTupleE() public {
    // Initialize the Parameters struct in storage
    parameters.name = "parameterName";

    // Now you can push elements to the 'tuples' array
    addElement("FirstParameter!", 12345);
    addElement("SecondParameter!", 987);
    addElement("ThirdParameter!", 54321);
    bytes memory someBytes = abi.encode(parameters);
    // addElement(string(someBytes), 888);

    // Arrange
    string memory testStr = string(someBytes);
    uint256 testNum = 12345;

    // vm.writeJson(string(someBytes), filePath);

    // Store the tuple
    _storeTuple(testStr, testNum, filePath);
    emit Log("hi");

    // Reset the data
    data = Tuple.StringUint256({ str: "", number: 0 });
    assertEq(data.str, "");

    // Act: Load the tuple back
    _loadTuple(filePath);
    emit Log("Decoding");
    emit Log(data.str);
    Parameters memory anotherParameters = abi.decode(bytes(data.str), (Parameters));
    // Assert
    assertEq(data.str, testStr);
    assertEq(data.number, testNum);
  }

  function addElement(string memory _title, uint256 _number) public {
    SomeVariableStruct memory newElement = SomeVariableStruct({ string_title: _title, some_number: _number });

    parameters.tuples.push(newElement); // Dynamically add to storage array
  }

  function _storeTuple(string memory _str, uint256 _num, string memory _filePath) internal {
    Tuple.StringUint256 memory tuple = Tuple.StringUint256({ str: _str, number: _num });

    // Serialize both string and number into one JSON object
    string memory jsonData = vm.serializeUint("", "number", tuple.number);
    string memory another = vm.serializeString(jsonData, "str", tuple.str);

    // vm.writeFile(_filePath, jsonData);
    vm.writeFile(_filePath, another);
  }

  function _loadTuple(string memory _filePath) internal {
    string memory jsonData = vm.readFile(_filePath);
    emit Log("jsonData=");
    emit Log(jsonData);
    // data.number = jsonData.readUint("number");
    data.str = jsonData.readString("str");
  }
}
