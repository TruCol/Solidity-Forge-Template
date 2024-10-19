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
error StringnContainsNonDigits(string message, string someString);
error InvalidRange(string message, uint256 start, uint256 stop);
error OutOfBounds(string message, uint256 stop, uint256 maxLength);
error SubstringError(string message);
error SubstringNotFound(string message);

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

  function substring(string memory str, uint256 start, uint256 stop) public returns (string memory someSubstring) {
    emit Log(Strings.toString(start));
    emit Log(Strings.toString(stop));

    if (stop < start + 1) {
      revert InvalidRange("Error, stop must be larger than start.", start, stop);
    }

    bytes memory strBytes = bytes(str);
    // require(stop < strBytes.length + 1, "Stop is out of bounds");
    if (stop > strBytes.length) {
      revert OutOfBounds("Stop is out of bounds.", stop, strBytes.length);
    }
    bytes memory result = new bytes(stop - start);

    for (uint256 i = start; i < stop; ++i) {
      result[i - start] = strBytes[i];
    }
    someSubstring = string(result);
    return someSubstring;
  }

  function indexOf(string memory mainStr, string memory subStr) public pure returns (uint256 theIndex) {
    bytes memory mainBytes = bytes(mainStr);
    bytes memory subBytes = bytes(subStr);
    uint256 mainLength = mainBytes.length;
    uint256 subLength = subBytes.length;

    if (subLength == 0 || mainLength < subLength) {
      revert SubstringNotFound("Error: Substring not found.");
    }

    for (uint256 i = 0; i < mainLength - subLength + 1; ++i) {
      bool foundMatch = true;
      for (uint256 j = 0; j < subLength; ++j) {
        if (mainBytes[i + j] != subBytes[j]) {
          foundMatch = false;
          break;
        }
      }
      if (foundMatch) {
        theIndex = uint256(i); // Return the index of the first occurrence
        return theIndex;
      }
    }

    revert SubstringError("Error: Substring is empty or longer than the main string.");
  }

  function removeCharacter(string memory str, bytes1 charToRemove) public pure returns (string memory remainingStr) {
    bytes memory strBytes = bytes(str);
    uint256 count = 0;

    uint256 nrOfCharacters = strBytes.length;
    // Count occurrences of the character to remove
    for (uint256 i = 0; i < nrOfCharacters; ++i) {
      if (strBytes[i] == charToRemove) {
        ++count;
      }
    }

    // Create a new bytes array without the specified character
    bytes memory result = new bytes(nrOfCharacters - count);
    uint256 j = 0;

    for (uint256 i = 0; i < nrOfCharacters; ++i) {
      if (strBytes[i] != charToRemove) {
        result[j] = strBytes[i];
        ++j;
      }
    }

    remainingStr = string(result);
    return remainingStr;
  }

  function assertAllCharactersAreDigits(string memory str) public pure {
    bytes memory strBytes = bytes(str);
    uint256 nrOfCharacters = strBytes.length;
    for (uint256 i = 0; i < nrOfCharacters; ++i) {
      if (strBytes[i] < "0" || strBytes[i] > "9") {
        revert StringnContainsNonDigits("String contains non-digit characters", str);
      }
    }
  }

  function stringToUint(string memory str) public pure returns (uint256 theNumber) {
    bytes memory strBytes = bytes(str);
    uint256 theNumber = 0;
    uint256 nrOfCharacters = strBytes.length;
    for (uint256 i = 0; i < nrOfCharacters; ++i) {
      if (strBytes[i] < "0" || strBytes[i] > "9") {
        revert StringnContainsNonDigits("String contains non-digit characters", str);
      }

      theNumber = theNumber * 10 + (uint256(uint8(strBytes[i])) - 48);
    }

    return theNumber;
  }

  function countSubstringOccurrences(
    string memory mainStr,
    string memory subStr
  ) public pure returns (uint256 nrOfSubstrOccurrences) {
    bytes memory mainBytes = bytes(mainStr);
    bytes memory subBytes = bytes(subStr);
    uint256 mainLength = mainBytes.length;
    uint256 subLength = subBytes.length;

    if (subLength == 0 || mainLength < subLength) {
      return 0; // Return 0 if the substring is empty or longer than the main string
    }

    nrOfSubstrOccurrences = 0;

    for (uint256 i = 0; i < mainLength - subLength + 1; ++i) {
      bool foundMatch = true;
      for (uint256 j = 0; j < subLength; ++j) {
        if (mainBytes[i + j] != subBytes[j]) {
          foundMatch = false;
          break;
        }
      }
      if (foundMatch) {
        ++nrOfSubstrOccurrences;
        i += subLength - 1; // Move index to skip past the found substring
      }
    }

    return nrOfSubstrOccurrences;
  }
}
