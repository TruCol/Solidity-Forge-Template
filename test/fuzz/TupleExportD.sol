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
  SomeVariableStruct[] tuples;
  string name;
}

struct SomeVariableStruct {
  uint256 some_number;
  string string_title;
}

contract TupleExportD is PRBTest, StdCheats {
  using stdJson for string;

  Tuple.StringUint256 public data;
  string public filePath = "./tuple_dataD.json";
  Parameters public parameters;

  function testStoreAndLoadTupleD() public {
    initializeParameters("Hi");
  }

  function initializeParameters(string memory _name) public {
    // Initialize the Parameters struct in storage
    parameters.name = _name;

    // Now you can push elements to the 'tuples' array
    addElement("FirstParameter!", 12345);
    addElement("SecondParameter!", 987);
    addElement("ThirdParameter!", 54321);
    // Add as many elements as you want dynamically
    bytes memory someBytes = abi.encode(parameters);

    addElement(string(someBytes), 888);
    vm.writeJson(string(someBytes), filePath);
    string memory json = vm.readFile(filePath);
    // bytes memory jsonData = vm.parseJson(json);
    emit Log("Done Reading");
    emit Log("Done writing");
    // Parameters memory anotherParameters = abi.decode(jsonData);
    // Parameters memory anotherParameters = abi.decode(jsonData, (Parameters));
    // assertEq(anotherParameters.tuples[1].some_number, 987);

    // _exportParametersToFile(filePath);
  }

  // Function to dynamically add elements to the struct array
  function addElement(string memory _title, uint256 _number) public {
    SomeVariableStruct memory newElement = SomeVariableStruct({ string_title: _title, some_number: _number });

    parameters.tuples.push(newElement); // Dynamically add to storage array
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

    // Create the root object and serialize the name
    string memory jsonOutput = vm.serializeString(obj, "name", parameters.name);

    // Initialize the parameters array as a JSON array string
    string memory parametersArray = "[";

    // Loop through each tuple and serialize it as an object in the parameters array
    for (uint256 i = 0; i < parameters.tuples.length; i++) {
      // Create a temporary object for each tuple
      string memory parameterObj = vm.serializeUint("", "some_number", parameters.tuples[i].some_number);
      parameterObj = vm.serializeString(parameterObj, "string_title", parameters.tuples[i].string_title);

      // Append the serialized object to the parameters array
      parametersArray = string(abi.encodePacked(parametersArray, parameterObj));

      // Add a comma if it's not the last element
      if (i < parameters.tuples.length - 1) {
        parametersArray = string(abi.encodePacked(parametersArray, ","));
      }
    }

    // Close the parameters array
    parametersArray = string(abi.encodePacked(parametersArray, "]"));

    // Merge the parameters array into the JSON output
    jsonOutput = vm.serializeString(jsonOutput, "parameters", parametersArray);

    // Write the JSON to the file
    vm.writeJson(jsonOutput, _filePath);
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
