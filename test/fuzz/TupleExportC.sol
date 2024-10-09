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

struct Parameters {
  SomeVariableStruct[] tupples;
  string name;
}

struct SomeVariableStruct {
  uint256 some_number;
  string string_title;
}

contract TupleExportC is PRBTest, StdCheats {
  using stdJson for string;

  Tuple.StringUint256 public data;
  string public filePath = "./tuple_dataC.json";
  Parameters public parameters;

  function testStoreAndLoadTupleC() public {
    initializeParameters("Hi");
  }

  function initializeParameters(string memory _name) public {
    // Initialize the Parameters struct in storage
    parameters.name = _name;

    // Now you can push elements to the 'tupples' array
    addElement("FirstParameter!", 12345);
    addElement("SecondParameter!", 987);
    addElement("ThirdParameter!", 54321);
    // Add as many elements as you want dynamically

    _exportParametersToFile(filePath);
  }

  // Function to dynamically add elements to the struct array
  function addElement(string memory _title, uint256 _number) public {
    SomeVariableStruct memory newElement = SomeVariableStruct({ string_title: _title, some_number: _number });

    parameters.tupples.push(newElement); // Dynamically add to storage array
  }

  function _storeTuple(string memory _str, uint256 _num, string memory _filePath) internal {
    // Tuple.StringUint256 memory tuple = Tuple.StringUint256({ str: _str, number: _num });

    string memory obj1 = "ThisDissapearsIntoTheVoidForTheFirstKey";
    vm.serializeUint(obj1, "some_number", _num);
    string memory output = vm.serializeString(obj1, "string_title", _str);
    vm.writeJson(output, _filePath);
  }

  function _exportParametersToFile(string memory _filePath) internal {
    string memory obj = "parameters";

    // Create an empty array to hold the tuple entries
    string memory firstOutput = vm.serializeString(obj, "name", parameters.name);
    string memory someOutput;
    for (uint256 i = 0; i < parameters.tupples.length; i++) {
        // Create a unique key for each tuple entry
        // string memory tupleObj = string(abi.encodePacked("tupple_", Strings.toString(i)));

        // // Serialize the fields of the tuple into a temporary object
        // output = vm.serializeUint(tupleObj, "some_number", parameters.tupples[i].some_number);
        // output = vm.serializeString(tupleObj, "string_title", parameters.tupples[i].string_title);

        string memory obj1 = "ThisDissapearsIntoTheVoidForTheFirstKey";
        vm.serializeUint(firstOutput, "some_number", parameters.tupples[i].some_number);
        string memory output = vm.serializeString(firstOutput, "string_title", parameters.tupples[i].string_title);

        // Merge the serialized tuple into the main array under "parameters"
        someOutput = vm.serializeString(obj, string(abi.encodePacked("parameters[", Strings.toString(i), "]")), output);
    }

    // Write the JSON to the file
    vm.writeJson(someOutput, _filePath);
}
  // Helper function to convert uint256 to string
  function _uint2str(uint256 _i) internal pure returns (string memory) {
    if (_i == 0) {
      return "0";
    }
    uint256 j = _i;
    uint256 len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint256 k = len - 1;
    while (_i != 0) {
      bstr[k--] = bytes1(uint8(48 + (_i % 10)));
      _i /= 10;
    }
    return string(bstr);
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
