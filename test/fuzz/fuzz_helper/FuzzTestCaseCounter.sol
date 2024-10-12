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

  string public filePath = "./tuple_dataG.json";

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
    vm.writeJson(serialisedHitCountParams, filePath);
    emit Log("Wrote to file!");
    // TODO: assert the log filecontent equals the current _tupleMappingping values.
  }

  function getHitCountParams() public pure returns (HitCountParams memory) {
    // Initialize an array of Param structs.

    Triple.ParameterStorage[] memory params = new Triple.ParameterStorage[](3);
    params[0] = Triple.ParameterStorage({ hitCount: 3, parameterName: "Red", requiredHitCount: 7 });
    params[1] = Triple.ParameterStorage({ hitCount: 5, parameterName: "Green", requiredHitCount: 5 });
    params[2] = Triple.ParameterStorage({ hitCount: 1, parameterName: "Yellow", requiredHitCount: 9 });

    // Initialize the HitCountParams struct
    HitCountParams memory hitCountParams = HitCountParams({ params: params, name: "TheFilename" });

    return hitCountParams;
  }

  /** Reads the log data (parameter name and value) from the file, converts it
into a struct, and then converts that struct into this _tupleMappingping.
 */
  function readHitRatesFromLogFileAndSetToMap(string memory hitRateFilePath) public {
    HitCountParams memory hitRatesReadFromFile = readJson(filePath);

    // Update the hit rate _tupleMappingping using the HitRatesReturnAll object.
    updateLogParamMapping({ hitRatesReadFromFile: hitRatesReadFromFile });

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

    // Serialize each apple object
    for (uint256 i = 0; i < params.length; i++) {
      string memory appleJson = "{";
      // This order is not important.
      appleJson = string(abi.encodePacked(appleJson, '"hitCount":', Strings.toString(params[i].hitCount), ","));
      appleJson = string(abi.encodePacked(appleJson, '"parameterName":"', params[i].parameterName, '",'));
      appleJson = string(
        abi.encodePacked(appleJson, '"requiredHitCount":', Strings.toString(params[i].requiredHitCount))
      );
      appleJson = string(abi.encodePacked(appleJson, "}"));
      paramsJson[i] = appleJson;
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

    emit Log(localHitCountParams.name);

    for (uint256 i = 0; i < localHitCountParams.params.length; i++) {
      Triple.ParameterStorage memory apple = localHitCountParams.params[i];

      emit Log("apple.parameterName");
      emit Log(apple.parameterName);
      emit Log("apple.hitCount");
      emit Log(Strings.toString(apple.hitCount));
      emit Log("apple.requiredHitCount");
      emit Log(Strings.toString(apple.requiredHitCount));
    }
    return localHitCountParams;
  }
}
