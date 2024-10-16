pragma solidity >=0.8.25 <0.9.0;
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { stdJson } from "forge-std/src/StdJson.sol";
import { IterableTripleMapping } from "./IterableTripleMapping.sol";
import { Triple } from "./Triple.sol";
import { WritingToFile } from "./WritingToFile.sol";

struct HitCountParams {
  string name;
  Triple.ParameterStorage[] params;
}

// solhint-disable foundry-test-functions
interface ILogMapping {
  function overwriteExistingMapLogFile(string memory hitRateFilePath) external;

  function getHitCountParams() external returns (HitCountParams memory hitCountParams);

  function readHitRatesFromLogFileAndSetToMap(string memory hitRateFilePath) external;

  function initialiseParameter(string memory variableName, uint256 hitCount, uint256 requiredHitCount) external;

  function callIncrementLogCount(string memory variableName) external;

  function updateLogParamMapping(HitCountParams memory hitRatesReadFromFile) external;

  function readJson(string memory someFilePath) external returns (HitCountParams memory localHitCountParams);

  function getHitRateFilePath() external view returns (string memory hitRateFilePath);

  function serializeHitCountParams(
    HitCountParams memory hitCountParams
  ) external pure returns (string memory finalJson);
}

contract LogMapping is PRBTest, StdCheats, ILogMapping, ReentrancyGuard {
  using IterableTripleMapping for IterableTripleMapping.Map;
  using stdJson for string;

  IterableTripleMapping.Map private _tupleMapping;
  WritingToFile private immutable _writingToFile = new WritingToFile();
  Triple.ParameterStorage public data;

  string private _hitRateFilePath;

  constructor(string memory testLogTimestampFilePath, string memory testFunctionName) {
    _hitRateFilePath = _initialiseMapping(testLogTimestampFilePath, testFunctionName);
  }

  /** Exports the current _tupleMapping to the already existing log file. Throws an error
  if the log file does not yet exist.*/
  function overwriteExistingMapLogFile(string memory hitRateFilePath) public override {
    HitCountParams memory hitCountParams = getHitCountParams();
    string memory serialisedHitCountParams = serializeHitCountParams(hitCountParams);

    // Write the final JSON to the file
    vm.writeJson(serialisedHitCountParams, hitRateFilePath);
    // TODO: assert the log filecontent equals the current _tupleMappingping values.
  }

  function getHitCountParams() public override returns (HitCountParams memory hitCountParams) {
    // Initialize an array of Param structs.
    Triple.ParameterStorage[] memory parameterStorages = _tupleMapping.getValues();
    uint256 nrOfParametsr = parameterStorages.length;
    Triple.ParameterStorage[] memory params = new Triple.ParameterStorage[](nrOfParametsr);

    for (uint256 i = 0; i < nrOfParametsr; ++i) {
      params[i] = Triple.ParameterStorage({
        hitCount: parameterStorages[i].hitCount,
        parameterName: parameterStorages[i].parameterName,
        requiredHitCount: parameterStorages[i].requiredHitCount
      });
    }

    // Initialize the HitCountParams struct
    hitCountParams = HitCountParams({ params: params, name: "TheFilename" });

    return hitCountParams;
  }

  /** Reads the log data (parameter name and value) from the file, converts it
into a struct, and then converts that struct into this _tupleMappingping.
 */
  function readHitRatesFromLogFileAndSetToMap(string memory hitRateFilePath) public override {
    HitCountParams memory hitRatesReadFromFile = readJson(hitRateFilePath);

    emit Log("Doing updateLogParamMapping");
    // Update the hit rate _tupleMappingping using the HitRatesReturnAll object.
    updateLogParamMapping({ hitRatesReadFromFile: hitRatesReadFromFile });
    emit Log("Done with update.");
    // TODO: assert the data in the log file equals the data in this _tupleMapping.
  }

  function initialiseParameter(string memory variableName, uint256 hitCount, uint256 requiredHitCount) public override {
    _tupleMapping.initialiseParameter(variableName, hitCount, requiredHitCount);
  }

  function callIncrementLogCount(string memory variableName) public override {
    _tupleMapping.incrementLogCount(variableName);
  }

  // solhint-disable-next-line foundry-test-functions
  function updateLogParamMapping(HitCountParams memory hitRatesReadFromFile) public override {
    uint256 nrOfParams = hitRatesReadFromFile.params.length;
    for (uint256 i = 0; i < nrOfParams; ++i) {
      Triple.ParameterStorage memory parameterStorage = hitRatesReadFromFile.params[i];
      _tupleMapping.set(parameterStorage.parameterName, parameterStorage);
    }
  }

  function readJson(string memory someFilePath) public override returns (HitCountParams memory localHitCountParams) {
    uint256 nrOfParams = localHitCountParams.params.length;
    string memory json = vm.readFile(someFilePath);
    bytes memory someData = vm.parseJson(json);
    localHitCountParams = abi.decode(someData, (HitCountParams));

    for (uint256 i = 0; i < nrOfParams; ++i) {
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

  function getHitRateFilePath() public view override returns (string memory hitRateFilePath) {
    // TODO: if _hitRateFilePath == "": raise exception.
    hitRateFilePath = _hitRateFilePath;
    return hitRateFilePath;
  }

  // Function to serialize the HitCountParams object to JSON
  function serializeHitCountParams(
    HitCountParams memory hitCountParams
  ) public pure override returns (string memory finalJson) {
    // Serialize params using the serializeParams function
    string memory paramsJsonArray = _serializeParams(hitCountParams.params);

    // Final JSON string combining params and name
    finalJson = "{";
    finalJson = string(abi.encodePacked(finalJson, '"params":', paramsJsonArray, ","));
    finalJson = string(abi.encodePacked(finalJson, '"name":"', hitCountParams.name, '"'));
    finalJson = string(abi.encodePacked(finalJson, "}"));

    return finalJson;
  }

  // Function to serialize the params array
  function _serializeParams(
    Triple.ParameterStorage[] memory params
  ) internal pure returns (string memory paramsJsonArray) {
    uint256 nrOfParams = params.length;
    string[] memory paramsJson = new string[](params.length);

    // Serialize each paramStorage object
    for (uint256 i = 0; i < nrOfParams; ++i) {
      string memory paramStorageJson = "{";
      bytes memory paramStorageBytes = abi.encodePacked(
        paramStorageJson,
        '"hitCount":',
        Strings.toString(params[i].hitCount),
        ","
      );
      paramStorageJson = string(paramStorageBytes);
      paramStorageJson = string(abi.encodePacked(paramStorageJson, '"parameterName":"', params[i].parameterName, '",'));
      paramStorageJson = string(
        abi.encodePacked(paramStorageJson, '"requiredHitCount":', Strings.toString(params[i].requiredHitCount))
      );
      paramStorageJson = string(abi.encodePacked(paramStorageJson, "}"));
      paramsJson[i] = paramStorageJson;
    }

    // Combine the params array into a JSON array
    uint256 nrOfJsonParams = paramsJson.length;
    paramsJsonArray = "[";
    for (uint256 i = 0; i < nrOfJsonParams; ++i) {
      bytes memory someBytes = bytes.concat(bytes(paramsJsonArray), bytes(paramsJson[i]));
      paramsJsonArray = string(someBytes);

      if (i < nrOfJsonParams - 1) {
        paramsJsonArray = string(abi.encodePacked(paramsJsonArray, ","));
      }
    }
    paramsJsonArray = string(abi.encodePacked(paramsJsonArray, "]"));

    return paramsJsonArray;
  }

  function _initialiseMapping(
    string memory testLogTimestampFilePath,
    string memory testFunctionName
  ) private returns (string memory hitRateFilePath) {
    string memory temporaryFileContentFiller = "temporaryFiller";
    hitRateFilePath = _writingToFile.createLogFileIfItDoesNotExist(
      testLogTimestampFilePath,
      testFunctionName,
      temporaryFileContentFiller
    );
    overwriteExistingMapLogFile(hitRateFilePath);
    return hitRateFilePath;
  }
}
