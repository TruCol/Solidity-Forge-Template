pragma solidity >=0.8.25 <0.9.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { console2 } from "forge-std/src/console2.sol";
import "test/TestConstants.sol";
import { Triple } from "./Triple.sol";

error VariableNotFoundError(string message, string variableName);
error DidNotFindEmptyLogEntry(string message, string variableName);

library IterableTripleMapping {
  struct ValueEntryTriple {
    Triple.ParameterStorage something;
    uint256 number;
  }
  // Iterable mapping from string[] to uint;
  struct Map {
    string[] keys;
    mapping(string => Triple.ParameterStorage) values;
    mapping(string => uint256) indexOf;
    mapping(string => bool) inserted;
  }

  function get(Map storage map, string memory key) public view returns (Triple.ParameterStorage memory someValue) {
    someValue = map.values[key];
    return someValue;
  }

  function getKeys(Map storage map) public view returns (string[] memory) {
    return map.keys;
  }

  function getValues(Map storage map) public view returns (Triple.ParameterStorage[] memory) {
    Triple.ParameterStorage[] memory listOfValues = new Triple.ParameterStorage[](
      _MAX_NR_OF_TEST_LOG_VALUES_PER_LOG_FILE
    );

    if (map.keys.length > 1) {
      for (uint256 i = 0; i < map.keys.length; i++) {
        listOfValues[i] = map.values[map.keys[i]];
      }
    }
    return listOfValues;
  }

  function getKeyAtIndex(Map storage map, uint256 index) public view returns (string memory) {
    return map.keys[index];
  }

  function size(Map storage map) public view returns (uint256) {
    return map.keys.length;
  }

  function set(Map storage map, string memory key, Triple.ParameterStorage memory val) public {
    if (map.inserted[key]) {
      map.values[key] = val;
    } else {
      map.inserted[key] = true;
      map.values[key] = val;
      map.indexOf[key] = map.keys.length;
      map.keys.push(key);
    }
  }

  function setDuplicateFunction(Map storage map, string memory key, Triple.ParameterStorage memory val) public {
    if (map.inserted[key]) {
      // map.values[key] = val;
    } else {
      // map.inserted[key] = true;
      // map.values[key] = val;
      // map.indexOf[key] = map.keys.length;
      // map.keys.push(key);
    }
  }

  function getCurrentCount(Map storage map, string memory variableName) public returns (uint256 currentCount) {
    // Loop values.
    // If a value tuple string equals variableName, get the uint256 of that tuple and return it.
    // otherwise, return 0.
    for (uint256 i = 0; i < map.keys.length; i++) {
      if (keccak256(bytes(map.values[map.keys[i]].parameterName)) == keccak256(bytes(variableName))) {
        return map.values[map.keys[i]].hitCount;
      }
    }
    return 0;
  }

  function incrementCount(Map storage map, string memory variableName, uint256 increment) public {
    // otherwise, return 0.
    bool foundVariable = false;
    for (uint256 i = 0; i < map.keys.length; i++) {
      // If a value tuple string equals variableName, increment its value.
      if (keccak256(bytes(map.values[map.keys[i]].parameterName)) == keccak256(bytes(variableName))) {
        map.values[map.keys[i]].hitCount = map.values[map.keys[i]].hitCount + increment;
        foundVariable = true;
      }
    }
    if (!foundVariable) {
      revert VariableNotFoundError("Was not able to find variable for incrementation.", variableName);
    }
  }

  function variableIsStored(Map storage map, string memory variableName) public returns (bool isStored) {
    for (uint256 i = 0; i < map.keys.length; i++) {
      // Per key, get the tuple value, per tuple string, check if it equals the variableName.
      if (keccak256(bytes(map.values[map.keys[i]].parameterName)) == keccak256(bytes(variableName))) {
        return true;
      }
    }

    return false;
  }

  /** Increments the test case hit counts in the testIterableMapping. */
  function incrementLogCount(Map storage map, string memory variableName) public {
    if (variableIsStored(map, variableName)) {
      uint256 currentCount = getCurrentCount(map, variableName);

      incrementCount(map, variableName, 1);
      // uint256 variableLetterKey = getCurrentVariableLetter(variableName);
    } else {
      uint256 newCount = 1;
      // Store the variable name and 0 value at the next index/letterkey.
      // TODO: fix duplicate count entry.
      Triple.ParameterStorage memory newValue = Triple.ParameterStorage(newCount, variableName, newCount);
      set(map, Strings.toString(map.keys.length), newValue);
    }
  }

  function emptyMap(Map storage map) public {
    for (uint256 i = 0; i < map.keys.length; i++) {
      string memory key = map.keys[i];
      delete map.values[key];
      delete map.inserted[key];
      delete map.indexOf[key];
    }
    delete map.keys;
  }
}
