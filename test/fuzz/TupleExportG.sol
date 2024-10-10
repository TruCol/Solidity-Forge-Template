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

struct Apple {
  uint8 hitCount;
  string parameterName;
  uint8 requiredHitCount;
}

struct HitCountParameters {
  Apple[] apples;
  string name;
}

contract TupleExportG is PRBTest, StdCheats {
  using stdJson for string;

  Tuple.StringUint256 public data;

  string public filePath = "./tuple_dataG.json";
  Parameters public parameters;

  function testStoreAndLoadTupleG() public {
    HitCountParameters memory fruitstall = getHitCountParameters();
    string memory serialisedFruitstal = serializeHitCountParameters(fruitstall);
    fruitstall.apples[1].hitCount = 255;

    // Write the final JSON to the file
    vm.writeJson(serialisedFruitstal, filePath);

    HitCountParameters memory readStall = readJson(filePath);

    assertEq(fruitstall.apples[0].parameterName, readStall.apples[0].parameterName);
    assertEq(fruitstall.apples[1].parameterName, readStall.apples[1].parameterName);
    assertEq(fruitstall.apples[2].parameterName, readStall.apples[2].parameterName);

    assertEq(fruitstall.apples[0].hitCount, readStall.apples[0].hitCount);
    // The original struct has been changed.
    assertEq(fruitstall.apples[1].hitCount, 255);
    // The struct read from file still has the value that the original struct had before it was written to file.
    assertEq(readStall.apples[1].hitCount, 5);
    assertEq(fruitstall.apples[2].hitCount, readStall.apples[2].hitCount);

    assertEq(fruitstall.apples[0].requiredHitCount, readStall.apples[0].requiredHitCount);
    assertEq(fruitstall.apples[1].requiredHitCount, readStall.apples[1].requiredHitCount);
    assertEq(fruitstall.apples[2].requiredHitCount, readStall.apples[2].requiredHitCount);
  }

  function getHitCountParameters() public pure returns (HitCountParameters memory) {
    // Initialize an array of Apple structs

    Apple[] memory apples = new Apple[](3);
    apples[0] = Apple({ hitCount: 3, parameterName: "Red", requiredHitCount: 7 });
    apples[1] = Apple({ hitCount: 5, parameterName: "Green", requiredHitCount: 5 });
    apples[2] = Apple({ hitCount: 1, parameterName: "Yellow", requiredHitCount: 9 });

    // Initialize the HitCountParameters struct
    HitCountParameters memory fruitstall = HitCountParameters({ apples: apples, name: "Fresh Fruit" });

    return fruitstall;
  }

  // Function to serialize the apples array
  function _serializeApples(Apple[] memory apples) internal pure returns (string memory) {
    string[] memory applesJson = new string[](apples.length);

    // Serialize each apple object
    for (uint256 i = 0; i < apples.length; i++) {
      string memory appleJson = "{";
      // This order is not important.
      appleJson = string(abi.encodePacked(appleJson, '"hitCount":', Strings.toString(apples[i].hitCount), ","));
      appleJson = string(abi.encodePacked(appleJson, '"parameterName":"', apples[i].parameterName, '",'));
      appleJson = string(
        abi.encodePacked(appleJson, '"requiredHitCount":', Strings.toString(apples[i].requiredHitCount))
      );
      appleJson = string(abi.encodePacked(appleJson, "}"));
      applesJson[i] = appleJson;
    }

    // Combine the apples array into a JSON array
    string memory applesJsonArray = "[";
    for (uint256 i = 0; i < applesJson.length; i++) {
      applesJsonArray = string(abi.encodePacked(applesJsonArray, applesJson[i]));
      if (i < applesJson.length - 1) {
        applesJsonArray = string(abi.encodePacked(applesJsonArray, ","));
      }
    }
    applesJsonArray = string(abi.encodePacked(applesJsonArray, "]"));

    return applesJsonArray;
  }

  // Function to serialize the HitCountParameters object to JSON
  function serializeHitCountParameters(HitCountParameters memory fruitstall) public pure returns (string memory) {
    // Get the HitCountParameters data

    // Serialize apples using the serializeApples function
    string memory applesJsonArray = _serializeApples(fruitstall.apples);

    // Final JSON string combining apples and name
    string memory finalJson = "{";
    finalJson = string(abi.encodePacked(finalJson, '"apples":', applesJsonArray, ","));
    finalJson = string(abi.encodePacked(finalJson, '"name":"', fruitstall.name, '"'));
    finalJson = string(abi.encodePacked(finalJson, "}"));

    return finalJson;
  }

  function readJson(string memory someFilePath) public returns (HitCountParameters memory localHitCountParameters) {
    string memory json = vm.readFile(someFilePath);
    bytes memory someData = vm.parseJson(json);
    localHitCountParameters = abi.decode(someData, (HitCountParameters));

    emit Log("Welcome to");
    emit Log(localHitCountParameters.name);

    for (uint256 i = 0; i < localHitCountParameters.apples.length; i++) {
      Apple memory apple = localHitCountParameters.apples[i];

      emit Log("apple.parameterName");
      emit Log(apple.parameterName);
      emit Log("apple.hitCount");
      emit Log(Strings.toString(apple.hitCount));
      emit Log("apple.requiredHitCount");
      emit Log(Strings.toString(apple.requiredHitCount));
    }
    return localHitCountParameters;
  }
}
