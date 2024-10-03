pragma solidity >=0.8.25 <0.9.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { console2 } from "forge-std/src/console2.sol";
import "test/TestConstants.sol";
import { Tuple } from "./Tuple.sol";

error VariableNotFoundError(string message, string variableName);
error DidNotFindEmptyLogEntry(string message, string variableName);

library IterableTupleMapping {
  struct ValueEntryTuple {
    Tuple.StringUint256 something;
    uint256 number;
  }
  // Iterable mapping from string[] to uint;
  struct Map {
    string[] keys;
    mapping(string => Tuple.StringUint256) values;
    mapping(string => uint256) indexOf;
    mapping(string => bool) inserted;
  }

  function get(Map storage map, string memory key) public view returns (Tuple.StringUint256 memory someValue) {
    someValue = map.values[key];
    return someValue;
  }

  function getKeys(Map storage map) public view returns (string[] memory) {
    return map.keys;
  }

  function getValues(Map storage map) public view returns (Tuple.StringUint256[] memory) {
    Tuple.StringUint256[] memory listOfValues = new Tuple.StringUint256[](_MAX_NR_OF_TEST_LOG_VALUES_PER_LOG_FILE);

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

  function set(Map storage map, string memory key, Tuple.StringUint256 memory val) public {
    if (map.inserted[key]) {
      map.values[key] = val;
    } else {
      map.inserted[key] = true;
      map.values[key] = val;
      map.indexOf[key] = map.keys.length;
      map.keys.push(key);
    }
  }

  function setDuplicateFunction(Map storage map, string memory key, Tuple.StringUint256 memory val) public {
    if (map.inserted[key]) {
      console2.log("The key is already inserted.");
      console2.log("val.str=.");
      console2.log(val.str);
      console2.log(Strings.toString(val.number));
      // map.values[key] = val;
    } else {
      console2.log("The key is not yet inserted.");
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
      if (keccak256(bytes(map.values[map.keys[i]].str)) == keccak256(bytes(variableName))) {
        return map.values[map.keys[i]].number;
      }
    }
    return 0;
  }

  function incrementCount(Map storage map, string memory variableName, uint256 increment) public {
    // otherwise, return 0.
    bool foundVariable = false;
    for (uint256 i = 0; i < map.keys.length; i++) {
      // If a value tuple string equals variableName, increment its value.
      if (keccak256(bytes(map.values[map.keys[i]].str)) == keccak256(bytes(variableName))) {
        map.values[map.keys[i]].number = map.values[map.keys[i]].number + increment;
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
      if (keccak256(bytes(map.values[map.keys[i]].str)) == keccak256(bytes(variableName))) {
        return true;
      }
    }
    return false;
  }

  /** Increments the test case hit counts in the testIterableMapping. */
  function incrementLogCount(Map storage map, string memory variableName) public {
    if (variableIsStored(map, variableName)) {
      console2.log("IS SET: variableName");
      console2.log(variableName);
      uint256 currentCount = getCurrentCount(map, variableName);

      incrementCount(map, variableName, 1);
      // uint256 variableLetterKey = getCurrentVariableLetter(variableName);
    } else {
      uint256 newCount = 1;
      // Store the variable name and 0 value at the next index/letterkey.
      Tuple.StringUint256 memory newValue = Tuple.StringUint256(variableName, newCount);
      // set(map, variableName, newValue);

      // TODO: find out the first empty place, and put it there.
      bool foundEmptyEntry = false;
      console2.log("setting for variableName=");
      console2.log(variableName);
      for (uint256 i = 0; i < map.keys.length; i++) {
        console2.log("get(map, map.keys[i]).str=");
        console2.log(get(map, map.keys[i]).str);
        if (
          keccak256(abi.encodePacked(get(map, map.keys[i]).str)) ==
          keccak256(abi.encodePacked(_INITIAL_VARIABLE_PLACEHOLDER)) ||
          keccak256(abi.encodePacked(get(map, map.keys[i]).str)) == keccak256(abi.encodePacked(""))
        ) {
          console2.log("Setting for key=");
          console2.log(map.keys[i]);
          setDuplicateFunction(map, map.keys[i], newValue);
          foundEmptyEntry = true;
          break;
        }
      }

      if (!foundEmptyEntry) {
        revert DidNotFindEmptyLogEntry("Error, did not find empty log entry for variable:", variableName);
      }
    }
  }
}
