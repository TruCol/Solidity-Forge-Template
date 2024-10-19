pragma solidity >=0.8.26 <0.9.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { _FOUNDRY_TOML_FILENAME_WITH_EXT, _FOUNDRY_TOML_FUZZ_RUN_ID } from "test/TestConstants.sol";
import { WritingToFile } from "./WritingToFile.sol";

error LogFileNotCreated(string message, string fileName);
error TomleFileDoesNotExist(string message, string fileName);
error SomeFileNotCreated(string message, string fileName);
error SomeDirDoesNotExist(string message, string fileName);
error FileDoesNotContainSubstring(string message);

// solhint-disable foundry-test-functions
interface IReadingNrOfFuzzRunsFromToml {
  function readNrOfFuzzRunsFromToml() external returns (uint256 nrOfFuzzRuns);

  function getRunsValueFromToml(string memory mainStr, string memory identifyingSubstr) external returns (uint256);
}

contract ReadingNrOfFuzzRunsFromToml is PRBTest, StdCheats, IReadingNrOfFuzzRunsFromToml {
  function readNrOfFuzzRunsFromToml() public override returns (uint256 nrOfFuzzRuns) {
    WritingToFile writingToFile = new WritingToFile();

    // Assert the foundry toml file exists.
    writingToFile.assertRelativeFileExists(_FOUNDRY_TOML_FILENAME_WITH_EXT);

    // Assert the substring is found in the toml filecontent.
    writingToFile.assertFileContainsSubstring(_FOUNDRY_TOML_FILENAME_WITH_EXT, _FOUNDRY_TOML_FUZZ_RUN_ID);

    // Get the foundry file content.
    string memory fileContents = vm.readFile(_FOUNDRY_TOML_FILENAME_WITH_EXT);

    // Get the line with the substring.
    getRunsValueFromToml(fileContents, _FOUNDRY_TOML_FUZZ_RUN_ID);

    // Parse the substring.
    nrOfFuzzRuns = 5;
  }

  function getRunsValueFromToml(
    string memory mainStr,
    string memory identifyingSubstr
  ) public returns (uint256 nrOfFuzzRuns) {
    bytes memory mainBytes = bytes(mainStr);
    bytes memory target = bytes(identifyingSubstr);
    uint256 targetLength = target.length;
    uint256 nrOfMainBytes = mainBytes.length;

    // Ensure the target string can fit within the main string
    if (nrOfMainBytes <= targetLength) {
      return 0;
    }

    // Search for the target substring
    for (uint256 i = 0; i < nrOfMainBytes - targetLength + 1; ++i) {
      bool foundMatch = true;
      emit Log("foundMatch=");
      for (uint256 j = 0; j < targetLength; ++j) {
        if (mainBytes[i + j] != target[j]) {
          foundMatch = false;
          break;
        }
      }

      // If target is found, extract the number that follows
      if (foundMatch) {
        uint256 nrOfFuzzRuns = 0;
        uint256 k = i + targetLength;
        emit Log("nrOfMainBytes");
        emit Log(Strings.toString(nrOfMainBytes));

        while ((k < nrOfMainBytes && mainBytes[k] >= "0" && mainBytes[k] <= "9") || mainBytes[k] == "_") {
          if (mainBytes[k] == "_") {
            continue;
          } else {
            emit Log("k=");
            emit Log(Strings.toString(k));
            emit Log("mainbytes=");
            emit Log(Strings.toString(uint8(mainBytes[k])));

            nrOfFuzzRuns = nrOfFuzzRuns * 10 + (uint256(uint8(mainBytes[k])) - 48);
            k++;
            emit Log("k=");
            emit Log(Strings.toString(k));

            emit Log("mainBytes[k] >= 0");
            emit Log(_boolToString(mainBytes[k] >= "0"));

            emit Log("mainBytes[k] <= 9");
            emit Log(_boolToString(mainBytes[k] <= "9"));

            emit Log(Strings.toString(uint8(mainBytes[k])));
          }
        }
        return nrOfFuzzRuns;
      }
    }

    emit Log("Didnot foundMatch=");
    // Return 0 if the substring is not found or no number is found after it
    return 0;
  }

  function _boolToString(bool b) internal pure returns (string memory) {
    return b ? "true" : "false";
  }
}
