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

struct Params {
  SomeVariableStruct[] tuples;
  string name;
}

struct SomeVariableStruct {
  uint256 some_number;
  string string_title;
}

struct Param {
  uint8 hitCount;
  string parameterName;
  uint8 requiredHitCount;
}

struct HitCountParams {
  string name;
  Param[] params;
}

contract TupleExportG is PRBTest, StdCheats {
  using stdJson for string;

  Tuple.StringUint256 public data;

  string public filePath = "./tuple_dataG.json";
  Params public parameters;

  function testStoreAndLoadTupleG() public {
    HitCountParams memory hitCountParams = getHitCountParams();
    string memory serialisedHitCountParams = serializeHitCountParams(hitCountParams);
    hitCountParams.params[1].hitCount = 255;

    // Write the final JSON to the file
    vm.writeJson(serialisedHitCountParams, filePath);

    HitCountParams memory readStall = readJson(filePath);

    assertEq(hitCountParams.params[0].parameterName, readStall.params[0].parameterName);
    assertEq(hitCountParams.params[1].parameterName, readStall.params[1].parameterName);
    assertEq(hitCountParams.params[2].parameterName, readStall.params[2].parameterName);

    assertEq(hitCountParams.params[0].hitCount, readStall.params[0].hitCount);
    // The original struct has been changed.
    assertEq(hitCountParams.params[1].hitCount, 255);
    // The struct read from file still has the value that the original struct had before it was written to file.
    assertEq(readStall.params[1].hitCount, 5);
    assertEq(hitCountParams.params[2].hitCount, readStall.params[2].hitCount);

    assertEq(hitCountParams.params[0].requiredHitCount, readStall.params[0].requiredHitCount);
    assertEq(hitCountParams.params[1].requiredHitCount, readStall.params[1].requiredHitCount);
    assertEq(hitCountParams.params[2].requiredHitCount, readStall.params[2].requiredHitCount);
  }

  function getHitCountParams() public pure returns (HitCountParams memory) {
    // Initialize an array of Param structs

    Param[] memory params = new Param[](3);
    params[0] = Param({ hitCount: 3, parameterName: "Red", requiredHitCount: 7 });
    params[1] = Param({ hitCount: 5, parameterName: "Green", requiredHitCount: 5 });
    params[2] = Param({ hitCount: 1, parameterName: "Yellow", requiredHitCount: 9 });

    // Initialize the HitCountParams struct
    HitCountParams memory hitCountParams = HitCountParams({ params: params, name: "TheFilename" });

    return hitCountParams;
  }

  // Function to serialize the params array
  function _serializeParams(Param[] memory params) internal pure returns (string memory) {
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

  function readJson(string memory someFilePath) public returns (HitCountParams memory localHitCountParams) {
    string memory json = vm.readFile(someFilePath);
    bytes memory someData = vm.parseJson(json);
    localHitCountParams = abi.decode(someData, (HitCountParams));

    emit Log(localHitCountParams.name);

    for (uint256 i = 0; i < localHitCountParams.params.length; i++) {
      Param memory apple = localHitCountParams.params[i];

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
