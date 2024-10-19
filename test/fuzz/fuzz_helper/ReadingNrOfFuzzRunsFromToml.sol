pragma solidity >=0.8.26 <0.9.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { _FOUNDRY_TOML_FILENAME_WITH_EXT, _FOUNDRY_TOML_FUZZ_RUN_START_ID, _FOUNDRY_TOML_FUZZ_RUN_END_ID } from "test/TestConstants.sol";
import { WritingToFile } from "./WritingToFile.sol";

error LogFileNotCreated(string message, string fileName);
error TomleFileDoesNotExist(string message, string fileName);
error SomeFileNotCreated(string message, string fileName);
error SomeDirDoesNotExist(string message, string fileName);
error SubstringOccurredMoreThanOnce(string message, string substring);

// solhint-disable foundry-test-functions
interface IReadingNrOfFuzzRunsFromToml {
  function readNrOfFuzzRunsFromToml() external returns (uint256 nrOfFuzzRuns);

  // function getRunsValueFromToml(string memory mainStr, string memory identifyingSubstr) external returns (uint256);
}

contract ReadingNrOfFuzzRunsFromToml is PRBTest, StdCheats, IReadingNrOfFuzzRunsFromToml {
  function readNrOfFuzzRunsFromToml() public override returns (uint256 nrOfFuzzRuns) {
    WritingToFile writingToFile = new WritingToFile();

    // Assert the foundry toml file exists.
    writingToFile.assertRelativeFileExists(_FOUNDRY_TOML_FILENAME_WITH_EXT);

    // Assert the substring is found in the toml filecontent.
    writingToFile.assertFileContainsSubstring(_FOUNDRY_TOML_FILENAME_WITH_EXT, _FOUNDRY_TOML_FUZZ_RUN_START_ID);

    // Get the foundry file content.
    string memory fileContents = vm.readFile(_FOUNDRY_TOML_FILENAME_WITH_EXT);

    if (countSubstringOccurrences(fileContents, _FOUNDRY_TOML_FUZZ_RUN_START_ID) != 1) {
      revert SubstringOccurredMoreThanOnce(
        "Error, substring occurred more than once.",
        _FOUNDRY_TOML_FUZZ_RUN_START_ID
      );
    }

    // 0. Get start position of relevant string.
    uint256 startPos = indexOf(fileContents, _FOUNDRY_TOML_FUZZ_RUN_START_ID);

    // 1. Get remaining relevant string.
    string memory fromCutOffToEnd = substring(fileContents, startPos, bytes(fileContents).length);

    // 2. Assert closing identifier exists in remaining substring.
    writingToFile.assertStrContainsSubstring(fromCutOffToEnd, _FOUNDRY_TOML_FUZZ_RUN_END_ID);
    // 3. Find closing identifier position.
    uint256 endPos = indexOf(fromCutOffToEnd, _FOUNDRY_TOML_FUZZ_RUN_END_ID);

    // 4. Get remaining relevant substring.
    string memory nrOfFuzzRunsSubstring = substring(
      fromCutOffToEnd,
      bytes(_FOUNDRY_TOML_FUZZ_RUN_START_ID).length,
      endPos
    );
    emit Log("nrOfFuzzRunsSubstring");
    emit Log(nrOfFuzzRunsSubstring);
    // 5. Remove spaces from relevant remaining substring.
    string memory withoutSpaces = removeCharacter(nrOfFuzzRunsSubstring, " ");
    emit Log("withoutSpaces");
    emit Log(withoutSpaces);
    // 6. Remove underscores from relevant remaining substring.
    string memory withoutUnderscores = removeCharacter(withoutSpaces, "_");
    emit Log("withoutUnderscores");
    emit Log(withoutUnderscores);
    // 7. Assert remaining characters are all digits.
    assertAllCharactersAreDigits(withoutUnderscores);
    // 8. Convert the remaining relevant substring to uint256.
    nrOfFuzzRuns = stringToUint(withoutUnderscores);
    return nrOfFuzzRuns;
  }

  function _boolToString(bool b) internal pure returns (string memory) {
    return b ? "true" : "false";
  }

  function substring(string memory str, uint256 start, uint256 stop) public returns (string memory) {
    emit Log(Strings.toString(start));
    emit Log(Strings.toString(stop));

    require(stop > start, "Stop must be greater than start");

    bytes memory strBytes = bytes(str);
    require(stop <= strBytes.length, "Stop is out of bounds");

    bytes memory result = new bytes(stop - start);

    for (uint256 i = start; i < stop; i++) {
      result[i - start] = strBytes[i];
    }

    return string(result);
  }

  function indexOf(string memory mainStr, string memory subStr) public pure returns (uint256) {
    bytes memory mainBytes = bytes(mainStr);
    bytes memory subBytes = bytes(subStr);
    uint256 mainLength = mainBytes.length;
    uint256 subLength = subBytes.length;

    if (subLength == 0 || mainLength < subLength) {
      // TODO: throw error.
      return 6; // Return -1 if the substring is empty or longer than the main string
    }

    for (uint256 i = 0; i <= mainLength - subLength; i++) {
      bool foundMatch = true;
      for (uint256 j = 0; j < subLength; j++) {
        if (mainBytes[i + j] != subBytes[j]) {
          foundMatch = false;
          break;
        }
      }
      if (foundMatch) {
        return uint256(i); // Return the index of the first occurrence
      }
    }

    // TODO: throw error.
    // return -1; // Return -1 if the substring is not found
    return 5;
  }

  function removeCharacter(string memory str, bytes1 charToRemove) public pure returns (string memory) {
    bytes memory strBytes = bytes(str);
    uint256 count = 0;

    // Count occurrences of the character to remove
    for (uint256 i = 0; i < strBytes.length; i++) {
      if (strBytes[i] == charToRemove) {
        count++;
      }
    }

    // Create a new bytes array without the specified character
    bytes memory result = new bytes(strBytes.length - count);
    uint256 j = 0;

    for (uint256 i = 0; i < strBytes.length; i++) {
      if (strBytes[i] != charToRemove) {
        result[j] = strBytes[i];
        j++;
      }
    }

    return string(result);
  }

  function assertAllCharactersAreDigits(string memory str) public pure {
    bytes memory strBytes = bytes(str);

    for (uint256 i = 0; i < strBytes.length; i++) {
      require(strBytes[i] >= "0" && strBytes[i] <= "9", "String contains non-digit characters");
    }
  }

  function stringToUint(string memory str) public pure returns (uint256) {
    bytes memory strBytes = bytes(str);
    uint256 result = 0;

    for (uint256 i = 0; i < strBytes.length; i++) {
      require(strBytes[i] >= "0" && strBytes[i] <= "9", "String contains non-numeric characters");
      result = result * 10 + (uint256(uint8(strBytes[i])) - 48);
    }

    return result;
  }

  function countSubstringOccurrences(string memory mainStr, string memory subStr) public pure returns (uint256) {
    bytes memory mainBytes = bytes(mainStr);
    bytes memory subBytes = bytes(subStr);
    uint256 mainLength = mainBytes.length;
    uint256 subLength = subBytes.length;

    if (subLength == 0 || mainLength < subLength) {
      return 0; // Return 0 if the substring is empty or longer than the main string
    }

    uint256 count = 0;

    for (uint256 i = 0; i <= mainLength - subLength; i++) {
      bool foundMatch = true;
      for (uint256 j = 0; j < subLength; j++) {
        if (mainBytes[i + j] != subBytes[j]) {
          foundMatch = false;
          break;
        }
      }
      if (foundMatch) {
        count++;
        i += subLength - 1; // Move index to skip past the found substring
      }
    }

    return count;
  }
}
