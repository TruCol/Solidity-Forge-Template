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
  string color;
  uint8 sourness;
  uint8 sweetness;
}

struct FruitStall {
  Apple[] apples;
  string name;
}

contract TupleExportG is PRBTest, StdCheats {
  using stdJson for string;

  Tuple.StringUint256 public data;

  string public filePath = "./tuple_dataG.json";
  Parameters public parameters;

  function testStoreAndLoadTupleG() public {
    FruitStall memory fruitstall = getFruitStall();
    string memory serialisedFruitstal = serializeFruitStall(fruitstall);
    fruitstall.apples[1].sourness = 255;

    // Write the final JSON to the file
    vm.writeJson(serialisedFruitstal, filePath);

    FruitStall memory readStall = readJson(filePath);

    assertEq(fruitstall.apples[0].color, readStall.apples[0].color);
    assertEq(fruitstall.apples[1].color, readStall.apples[1].color);
    assertEq(fruitstall.apples[2].color, readStall.apples[2].color);

    assertEq(fruitstall.apples[0].sourness, readStall.apples[0].sourness);
    // The original struct has been changed.
    assertEq(fruitstall.apples[1].sourness, 255);
    // The struct read from file still has the value that the original struct had before it was written to file.
    assertEq(readStall.apples[1].sourness, 5);
    assertEq(fruitstall.apples[2].sourness, readStall.apples[2].sourness);

    assertEq(fruitstall.apples[0].sweetness, readStall.apples[0].sweetness);
    assertEq(fruitstall.apples[1].sweetness, readStall.apples[1].sweetness);
    assertEq(fruitstall.apples[2].sweetness, readStall.apples[2].sweetness);
  }

  function getFruitStall() public pure returns (FruitStall memory) {
    // Initialize an array of Apple structs

    Apple[] memory apples = new Apple[](3);
    apples[0] = Apple({ color: "Red", sourness: 3, sweetness: 7 });
    apples[1] = Apple({ color: "Green", sourness: 5, sweetness: 5 });
    apples[2] = Apple({ color: "Yellow", sourness: 1, sweetness: 9 });

    // Initialize the FruitStall struct
    FruitStall memory fruitstall = FruitStall({ apples: apples, name: "Fresh Fruit" });

    return fruitstall;
  }

  // Function to serialize the apples array
  function _serializeApples(Apple[] memory apples) internal pure returns (string memory) {
    string[] memory applesJson = new string[](apples.length);

    // Serialize each apple object
    for (uint256 i = 0; i < apples.length; i++) {
      string memory appleJson = "{";
      appleJson = string(abi.encodePacked(appleJson, '"color":"', apples[i].color, '",'));
      appleJson = string(abi.encodePacked(appleJson, '"sourness":', Strings.toString(apples[i].sourness), ","));
      appleJson = string(abi.encodePacked(appleJson, '"sweetness":', Strings.toString(apples[i].sweetness)));
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

  // Function to serialize the FruitStall object to JSON
  function serializeFruitStall(FruitStall memory fruitstall) public pure returns (string memory) {
    // Get the FruitStall data

    // Serialize apples using the serializeApples function
    string memory applesJsonArray = _serializeApples(fruitstall.apples);

    // Final JSON string combining apples and name
    string memory finalJson = "{";
    finalJson = string(abi.encodePacked(finalJson, '"apples":', applesJsonArray, ","));
    finalJson = string(abi.encodePacked(finalJson, '"name":"', fruitstall.name, '"'));
    finalJson = string(abi.encodePacked(finalJson, "}"));

    return finalJson;
  }

  function readJson(string memory someFilePath) public returns (FruitStall memory localFruitStall) {
    string memory json = vm.readFile(someFilePath);
    bytes memory someData = vm.parseJson(json);
    localFruitStall = abi.decode(someData, (FruitStall));

    emit Log("Welcome to");
    emit Log(localFruitStall.name);

    for (uint256 i = 0; i < localFruitStall.apples.length; i++) {
      Apple memory apple = localFruitStall.apples[i];

      emit Log("apple.color");
      emit Log(apple.color);
      emit Log("apple.sourness");
      emit Log(Strings.toString(apple.sourness));
      emit Log("apple.sweetness");
      emit Log(Strings.toString(apple.sweetness));
    }
    return localFruitStall;
  }
}
