pragma solidity >=0.8.25 <0.9.0;
/**
  The logging flow is described with:
    1. Initialise the mapping at all 0 values, and export those to file and set them in the struct.
      initialiseMapping(_tupleMapping)
  Loop:
    2. The values from the log file are read from file and overwrite those in the mapping.
    readHitRatesFromLogFileAndSetToMap()
    3. The code is ran, the mapping values are updated.
    4. The mapping values are logged to file.

  The mapping key value pairs exist in this map unstorted. Then they are
  written to a file in a sorted fashion. They are sorted automatically.
  Then they are read from file in alphabetical order. Since they are read in
  alphabetical order (automatically), they can stored into the alphabetical
  keys of the map using a switch case and enumeration (counts as indices).

  TODO: verify the non-alphabetical keys of a mapping are exported to an
  alphabetical order.
  TODO: verify the non-alphabetical keys of a file are exported and read into
  alphabetical order.
  */
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { stdJson } from "forge-std/src/StdJson.sol";
import "forge-std/src/Vm.sol";
import "test/TestConstants.sol";
import { IterableTripleMapping } from "./IterableTripleMapping.sol";
import { OverWriteFile } from "./OverWriteFile.sol";
import { TestCaseHitRateLoggerToFile } from "./TestCaseHitRateLoggerToFile.sol";
import { Triple } from "./Triple.sol";
import { WritingToFile } from "./WritingToFile.sol";

// struct Params {
//   SomeVariableStruct[] tuples;
//   string name;
// }

// struct SomeVariableStruct {
//   uint256 some_number;
//   string string_title;
// }

struct HitCountParams {
  string name;
  Triple.ParameterStorage[] params;
}

contract FuzzTestCaseCounter is PRBTest, StdCheats {
  using IterableTripleMapping for IterableTripleMapping.Map;
  IterableTripleMapping.Map private _tupleMapping;
  WritingToFile private _writingToFile = new WritingToFile();

  using stdJson for string;

  Triple.ParameterStorage public data;

  TestCaseHitRateLoggerToFile private _testCaseHitRateLoggerToFile;
  string private _hitRateFilePath;

  constructor(string memory testLogTimestampFilePath, string memory testFunctionName) {
    _testCaseHitRateLoggerToFile = new TestCaseHitRateLoggerToFile();
    _hitRateFilePath = initialiseMapping(testLogTimestampFilePath, testFunctionName);
  }

  function getHitRateFilePath() public view returns (string memory) {
    // TODO: if _hitRateFilePath == "": raise exception.
    return _hitRateFilePath;
  }

  /** Exports the current _tupleMapping to the already existing log file. Throws an error
  if the log file does not yet exist.*/
  function overwriteExistingMapLogFile(string memory hitRateFilePath) public {
    HitCountParams memory hitCountParams = getHitCountParams();
    string memory serialisedHitCountParams = serializeHitCountParams(hitCountParams);

    // Write the final JSON to the file
    vm.writeJson(serialisedHitCountParams, hitRateFilePath);
    emit Log("Wrote to file!");
    // TODO: assert the log filecontent equals the current _tupleMappingping values.
  }

  function getHitCountParams() public returns (HitCountParams memory) {
    // Initialize an array of Param structs.

    Triple.ParameterStorage[] memory params = new Triple.ParameterStorage[](_tupleMapping.getKeys().length);
    for (uint256 i = 0; i < _tupleMapping.getKeys().length; i++) {
      Triple.ParameterStorage memory parameterStorage = _tupleMapping.get(Strings.toString(i));
      params[i] = Triple.ParameterStorage({
        hitCount: parameterStorage.hitCount,
        parameterName: parameterStorage.parameterName,
        requiredHitCount: parameterStorage.requiredHitCount
      });
    }

    // Initialize the HitCountParams struct
    HitCountParams memory hitCountParams = HitCountParams({ params: params, name: "TheFilename" });

    return hitCountParams;
  }

  /** Reads the log data (parameter name and value) from the file, converts it
into a struct, and then converts that struct into this _tupleMappingping.
 */
  function readHitRatesFromLogFileAndSetToMap(string memory hitRateFilePath) public {
    HitCountParams memory hitRatesReadFromFile = readJson(hitRateFilePath);

    emit Log("Doing updateLogParamMapping");
    // Update the hit rate _tupleMappingping using the HitRatesReturnAll object.
    updateLogParamMapping({ hitRatesReadFromFile: hitRatesReadFromFile });
    emit Log("Done with update.");
    // TODO: assert the data in the log file equals the data in this _tupleMapping.
  }

  // TODO: make private.
  function initialiseMapping(
    string memory testLogTimestampFilePath,
    string memory testFunctionName
  ) public returns (string memory hitRateFilePath) {
    string memory temporaryFileContentFiller = "temporaryFiller";
    hitRateFilePath = _writingToFile.createLogFileIfItDoesNotExist(
      testLogTimestampFilePath,
      testFunctionName,
      temporaryFileContentFiller
    );
    overwriteExistingMapLogFile(hitRateFilePath);
    return hitRateFilePath;
  }

  function callIncrementLogCount(string memory variableName) public {
    _tupleMapping.incrementLogCount(variableName);
  }

  // solhint-disable-next-line foundry-test-functions
  function updateLogParamMapping(HitCountParams memory hitRatesReadFromFile) public {
    // First remove all existing entries (key value pairs) form map:
    _tupleMapping.emptyMap();
    emit Log("Emptied map.");

    // IterableTripleMapping.Map memory emptyTupleMapping;
    // using IterableTripleMapping for IterableTripleMapping.Map;
    // IterableTripleMapping.Map memory emptyTupleMapping;
    for (uint256 i = 0; i < hitRatesReadFromFile.params.length; i++) {
      _tupleMapping.set(Strings.toString(i), hitRatesReadFromFile.params[i]);
    }
  }

  // Function to serialize the HitCountParams object to JSON
  function serializeHitCountParams(HitCountParams memory hitCountParams) public pure returns (string memory) {
    // Get the HitCountParams data

    // Serialize params using the serializeParams function
    string memory paramsJsonArray = _serializeParams(hitCountParams.params);

    // Final JSON string combining params and name
    string memory finalJson = "{";
    finalJson = string(abi.encodePacked(finalJson, '"params":', paramsJsonArray, ","));
    finalJson = string(abi.encodePacked(finalJson, '"name":"', hitCountParams.name, '"'));
    finalJson = string(abi.encodePacked(finalJson, "}"));

    return finalJson;
  }

  // Function to serialize the params array
  function _serializeParams(Triple.ParameterStorage[] memory params) internal pure returns (string memory) {
    string[] memory paramsJson = new string[](params.length);

    // Serialize each paramStorage object
    for (uint256 i = 0; i < params.length; i++) {
      string memory paramStorageJson = "{";
      // This order is not important.
      paramStorageJson = string(
        abi.encodePacked(paramStorageJson, '"hitCount":', Strings.toString(params[i].hitCount), ",")
      );
      paramStorageJson = string(abi.encodePacked(paramStorageJson, '"parameterName":"', params[i].parameterName, '",'));
      paramStorageJson = string(
        abi.encodePacked(paramStorageJson, '"requiredHitCount":', Strings.toString(params[i].requiredHitCount))
      );
      paramStorageJson = string(abi.encodePacked(paramStorageJson, "}"));
      paramsJson[i] = paramStorageJson;
    }

    // Combine the params array into a JSON array
    string memory paramsJsonArray = "[";
    for (uint256 i = 0; i < paramsJson.length; i++) {
      paramsJsonArray = string(abi.encodePacked(paramsJsonArray, paramsJson[i]));
      if (i < paramsJson.length - 1) {
        paramsJsonArray = string(abi.encodePacked(paramsJsonArray, ","));
      }
    }
    paramsJsonArray = string(abi.encodePacked(paramsJsonArray, "]"));

    return paramsJsonArray;
  }

  function readJson(string memory someFilePath) public returns (HitCountParams memory localHitCountParams) {
    string memory json = vm.readFile(someFilePath);
    bytes memory someData = vm.parseJson(json);
    localHitCountParams = abi.decode(someData, (HitCountParams));

    for (uint256 i = 0; i < localHitCountParams.params.length; i++) {
      Triple.ParameterStorage memory paramStorage = localHitCountParams.params[i];

      emit Log("paramStorage.parameterName");
      emit Log(paramStorage.parameterName);
      emit Log("paramStorage.hitCount");
      emit Log(Strings.toString(paramStorage.hitCount));
      emit Log("paramStorage.requiredHitCount");
      emit Log(Strings.toString(paramStorage.requiredHitCount));
    }
    return localHitCountParams;
  }
}
