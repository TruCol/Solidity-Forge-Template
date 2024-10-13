pragma solidity >=0.8.25 <0.9.0;

import { Triple } from "./Triple.sol";

error VariableNotFoundError(string message, string variableName);
error VariableAlreadyInitialisedError(string message, string variableName);
error VariableNotYetInitialisedError(string message, string variableName);
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

  // solhint-disable-next-line foundry-test-functions
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

  // solhint-disable-next-line foundry-test-functions
  function incrementCount(Map storage map, string memory variableName, uint256 increment) public {
    // otherwise, return 0.
    bool foundVariable = false;
    uint256 nrOfKeys = map.keys.length;
    for (uint256 i = 0; i < nrOfKeys; ++i) {
      // TODO: simplify by just comparing key to variable name. Add assert that the param variableName is the same.
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

  // solhint-disable-next-line foundry-test-functions
  function initialiseParameter(
    Map storage map,
    string memory variableName,
    uint256 hitCount,
    uint256 requiredHitCount
  ) public {
    if (map.inserted[variableName]) {
      revert VariableAlreadyInitialisedError("Error, the map already contains the key:", variableName);
    }

    Triple.ParameterStorage memory newValue = Triple.ParameterStorage(hitCount, variableName, requiredHitCount);
    set(map, variableName, newValue);
  }

  /** Increments the test case hit counts in the testIterableMapping. */
  // solhint-disable-next-line foundry-test-functions
  function incrementLogCount(Map storage map, string memory variableName) public {
    if (map.inserted[variableName]) {
      incrementCount(map, variableName, 1);
    } else {
      revert VariableNotYetInitialisedError("Error, following key is not yet initialised:", variableName);
    }
  }

  // solhint-disable-next-line foundry-test-functions
  function emptyMap(Map storage map) public {
    uint256 nrOfKeys = map.keys.length;
    for (uint256 i = 0; i < nrOfKeys; ++i) {
      string memory key = map.keys[i];
      delete map.values[key];
      delete map.inserted[key];
      delete map.indexOf[key];
    }
    delete map.keys;
  }

  // solhint-disable-next-line foundry-test-functions
  function getValues(Map storage map) public view returns (Triple.ParameterStorage[] memory listOfValues) {
    uint256 nrOfKeys = map.keys.length;
    listOfValues = new Triple.ParameterStorage[](nrOfKeys);

    if (nrOfKeys > 1) {
      for (uint256 i = 0; i < nrOfKeys; ++i) {
        listOfValues[i] = map.values[map.keys[i]];
      }
    }
    return listOfValues;
  }

  // solhint-disable-next-line foundry-test-functions
  function size(Map storage map) public view returns (uint256 nrOfKeys) {
    nrOfKeys = map.keys.length;
    return nrOfKeys;
  }
}
