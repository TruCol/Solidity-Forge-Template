pragma solidity >=0.8.26 <0.9.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { _TIMESTAMP_FILE_EXT, _TEST_CASE_HIT_RATE_COUNTS_FILENAME } from "test/TestConstants.sol";

error LogFileNotCreated(string message, string fileName);
error SomeFileDoesNotExist(string message, string fileName);
error SomeFileNotCreated(string message, string fileName);
error SomeDirDoesNotExist(string message, string fileName);
error FileDoesNotContainSubstring(string message);

// solhint-disable foundry-test-functions
interface IWritingToFile {
  function overwriteFileContent(string memory serialisedTextString, string memory filePath) external;

  function createLogFileIfItDoesNotExist(
    string memory testLogTimestampFilePath,
    string memory testFunctionName,
    string memory serialisedTextString
  ) external override returns (string memory hitRateFilePath);

  function assertRelativeFileExists(string memory relativeFilePath) external;

  function assertRelativeDirExists(string memory relativeFolderPath) external;

  function assertFileContainsSubstring(string memory relFilepath, string memory desiredSubstring) external;

  function fileContainsSubstring(string memory relFilepath, string memory desiredSubstring) external returns (bool);

  function readDataFromFile(string memory path) external view returns (bytes memory data);

  function containsSubstring(string memory mainStr, string memory subStr) external pure returns (bool);
}

contract WritingToFile is PRBTest, StdCheats, IWritingToFile {
  function overwriteFileContent(string memory serialisedTextString, string memory filePath) public  {
    vm.writeJson(serialisedTextString, filePath);
    if (!vm.isFile(filePath)) {
      revert SomeFileDoesNotExist("Some file does not exist.", filePath);
    }
  }

  function createLogFileIfItDoesNotExist(
    string memory testLogTimestampFilePath,
    string memory testFunctionName,
    string memory serialisedTextString
  ) public override returns (string memory hitRateFilePath) {
    // Specify the logging directory and filepath.
    uint256 timeStamp = _createFileIfNotExists(
      serialisedTextString,
      string(abi.encodePacked(testLogTimestampFilePath, _TIMESTAMP_FILE_EXT))
    );
    string memory logDir = string(abi.encodePacked(testLogTimestampFilePath, "/", Strings.toString(timeStamp)));
    hitRateFilePath = string(
      abi.encodePacked(logDir, "/", _TEST_CASE_HIT_RATE_COUNTS_FILENAME, "__", testFunctionName, ".txt")
    );

    // If the log file does not yet exist, create it.
    if (!vm.isFile(hitRateFilePath)) {
      // Create logging structure
      vm.createDir(logDir, true);
      overwriteFileContent(serialisedTextString, hitRateFilePath);

      // Assort logging file exists.
      if (!vm.isFile(hitRateFilePath)) {
        revert LogFileNotCreated("LogFile not created.", hitRateFilePath);
      }
    }
    return hitRateFilePath;
  }

  function assertRelativeFileExists(string memory relativeFilePath) public override {
    if (!vm.isFile(relativeFilePath)) {
      revert SomeFileDoesNotExist("The file does not exist.", relativeFilePath);
    }
  }

  function assertRelativeDirExists(string memory relativeFolderPath) public override {
    if (!vm.isDir(relativeFolderPath)) {
      revert SomeDirDoesNotExist("The file does not exist.", relativeFolderPath);
    }
  }

  function assertFileContainsSubstring(string memory relFilepath, string memory desiredSubstring) public override {
    if (!fileContainsSubstring(relFilepath, desiredSubstring)) {
      revert FileDoesNotContainSubstring(
        string(abi.encodePacked("The file:", relFilepath, " does not contain substring:", desiredSubstring))
      );
    }
  }

  function fileContainsSubstring(
    string memory relFilepath,
    string memory desiredSubstring
  ) public override returns (bool) {
    assertRelativeFileExists(relFilepath);

    string memory fileContents = vm.readFile(relFilepath);
    return containsSubstring(fileContents, desiredSubstring);
  }

  function readDataFromFile(string memory path) public view override returns (bytes memory data) {
    string memory fileContent = vm.readFile(path);
    data = vm.parseJson(fileContent);
    return data;
  }

  function containsSubstring(string memory mainStr, string memory subStr) public pure override returns (bool) {
    bytes memory mainBytes = bytes(mainStr);
    bytes memory subBytes = bytes(subStr);

    if (subBytes.length > mainBytes.length) {
      return false;
    }

    for (uint256 i = 0; i <= mainBytes.length - subBytes.length; ++i) {
      bool foundMatch = true;
      for (uint256 j = 0; j < subBytes.length; j++) {
        if (mainBytes[i + j] != subBytes[j]) {
          foundMatch = false;
          break;
        }
      }
      if (foundMatch) {
        return true;
      }
    }
    return false;
  }

  function _createFileIfNotExists(
    string memory serialisedTextString,
    string memory filePath
  ) internal returns (uint256 lastModified) {
    if (!vm.isFile(filePath)) {
      overwriteFileContent(serialisedTextString, filePath);
    }
    if (!vm.isFile(filePath)) {
      revert SomeFileNotCreated("Some file not created.", filePath);
    }
    return vm.fsMetadata(filePath).modified;
  }
}
