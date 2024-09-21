pragma solidity >=0.8.26 <0.9.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { Vm } from "forge-std/src/Vm.sol";
import "./TestConstants.sol";

error LogFileNotCreated(string message, string fileName);
error SomeFileDoesNotExist(string message, string fileName);
error SomeFileNotCreated(string message, string fileName);

interface IWritingToFile {
  // solhint-disable-next-line foundry-test-functions
  function overwriteFileContent(string memory serialisedTextString, string memory filePath) external;

  // solhint-disable-next-line foundry-test-functions
  function createLogFileIfItDoesNotExist(
    string memory testLogTimestampFilePath,
    string memory testFunctionName,
    string memory serialisedTextString
  ) external returns (string memory hitRateFilePath);

  // solhint-disable-next-line foundry-test-functions
  function readDataFromFile(string memory path) external view returns (bytes memory data);
}

contract WritingToFile is PRBTest, StdCheats, IWritingToFile {
  // solhint-disable-next-line foundry-test-functions
  function overwriteFileContent(string memory serialisedTextString, string memory filePath) public override {
    vm.writeJson(serialisedTextString, filePath);
    if (!vm.isFile(filePath)) {
      revert SomeFileDoesNotExist("Some file does not exist.", filePath);
    }
  }

  // solhint-disable-next-line foundry-test-functions
  function createLogFileIfItDoesNotExist(
    string memory testLogTimestampFilePath,
    string memory testFunctionName,
    string memory serialisedTextString
  ) public override returns (string memory hitRateFilePath) {
    // Specify the logging directory and filepath.
    uint256 timeStamp = _createFileIfNotExists(
      serialisedTextString,
      string(abi.encodePacked(testLogTimestampFilePath, ".timestamp"))
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

  // solhint-disable-next-line foundry-test-functions
  function readDataFromFile(string memory path) public view override returns (bytes memory data) {
    string memory fileContent = vm.readFile(path);
    data = vm.parseJson(fileContent);
    return data;
  }

  // solhint-disable-next-line foundry-test-functions
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
