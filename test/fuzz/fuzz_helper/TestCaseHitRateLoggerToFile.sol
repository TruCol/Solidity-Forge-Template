pragma solidity >=0.8.25 <0.9.0;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { Vm } from "forge-std/src/Vm.sol";
import "test/TestConstants.sol";
import { OverWriteFile } from "./OverWriteFile.sol";
import { Tuple } from "./Tuple.sol";
import { WritingToFile } from "./WritingToFile.sol";

error InvalidExportLogMapError(string message, string[] keys, Tuple.StringUint256[] values, uint256);
error UnexpectedNrOfKeys(string message);

contract TestCaseHitRateLoggerToFile is PRBTest, StdCheats {
  /**
    @dev This is a function stores the log elements used to verify each test case in the fuzz test is reached.
     */
  // solhint-disable-next-line foundry-test-functions
  function convertHitRatesToString(
    string[] memory keys,
    Tuple.StringUint256[] memory values
  ) public returns (string memory serialisedTextString) {
    if (keys.length > _MAX_NR_OF_TEST_LOG_VALUES_PER_LOG_FILE) {
      revert InvalidExportLogMapError(
        "More log keys than supported.",
        keys,
        values,
        _MAX_NR_OF_TEST_LOG_VALUES_PER_LOG_FILE
      );
    }
    string memory obj1 = "ThisValueDissapearsIntoTheVoid";
    string[_MAX_NR_OF_TEST_LOG_VALUES_PER_LOG_FILE] memory tupleStrings;
    // TODO: tighten asserts.
    if (keys.length > 1) {
      for (uint256 i = 0; i < keys.length - 1; i++) {
        tupleStrings[i] = string(
          abi.encodePacked('{ "number":', Strings.toString(values[i].number), ', "str": "', values[i].str, '"}')
        );

        emit Log("tupleString=");
        emit Log(tupleStrings[i]);
        string
          memory jsonObj = "{ 'boolean': true, 'number': 342, 'myObject': { 'title': 'finally json serialization' } }";

        // The last instance is different because it needs to be stored into a variable.
        uint256 lastKeyIndex = keys.length - 1;

        tupleStrings[lastKeyIndex] = string(
          // No trailing comma for last entry.
          abi.encodePacked('{"number":', Strings.toString(values[i].number), ',"str":"', values[i].str, '"}')
        );
      }
      // serialisedTextString = vm.serializeUint(obj1, keys[lastKeyIndex], values[lastKeyIndex]);
    } else {
      revert UnexpectedNrOfKeys(
        string(abi.encodePacked("The number of keys:", Strings.toString(keys.length), " was unexpected"))
      );
    }
    // Create final object that is exported to Json.
    serialisedTextString = string(
      abi.encodePacked(
        '{"a":',
        tupleStrings[0],
        ",",
        '"b":',
        tupleStrings[1],
        ",",
        '"c":',
        tupleStrings[2],
        ",",
        '"d":',
        tupleStrings[3],
        ",",
        '"e":',
        tupleStrings[4],
        ",",
        '"f":',
        tupleStrings[5],
        ",",
        '"g":',
        tupleStrings[6],
        ",",
        '"h":',
        tupleStrings[7],
        ",",
        '"i":',
        tupleStrings[8],
        ",",
        '"j":',
        tupleStrings[9],
        ",",
        '"k":',
        tupleStrings[10],
        ",",
        '"l":',
        tupleStrings[11],
        ",",
        '"m":',
        tupleStrings[12],
        ",",
        '"n":',
        tupleStrings[13],
        ",",
        '"o":',
        tupleStrings[14],
        ",",
        '"p":',
        tupleStrings[15],
        ",",
        '"q":',
        tupleStrings[16],
        ",",
        '"r":',
        tupleStrings[17],
        ",",
        '"s":',
        tupleStrings[18],
        ",",
        '"t":',
        tupleStrings[19],
        ",",
        '"u":',
        tupleStrings[20],
        ",",
        '"v":',
        tupleStrings[21],
        ",",
        '"w":',
        tupleStrings[22],
        ",",
        '"x":',
        tupleStrings[23],
        ",",
        '"y":',
        tupleStrings[24],
        ",",
        '"z":',
        tupleStrings[25],
        "}"
      )
    );
    return serialisedTextString;
  }

  function readDataFromFile(string memory path) public returns (bytes memory jsonData) {
    string memory fileContent = vm.readFile(path);
    jsonData = vm.parseJson(fileContent);
    return jsonData;
  }

  function overwriteFileContent(string memory serialisedTextString, string memory filePath) public {
    vm.writeJson(serialisedTextString, filePath);
    if (!vm.isFile(filePath)) {
      revert("File does not exist.");
    }
  }

  /**
@dev Ensures the struct with the log data for this test file is exported into a log file if it does not yet exist.
Afterwards, it can load that new file.
 */
  // solhint-disable-next-line foundry-test-functions
  function createLogIfNotExistAndReadLogData(
    string memory testLogTimestampFilePath,
    string memory testFunctionName,
    string[] memory keys,
    Tuple.StringUint256[] memory values
  ) public returns (string memory hitRateFilePath) {
    // initialiseHitRates();
    // Output hit rates to file if they do not exist yet.
    string memory serialisedTextString = convertHitRatesToString(keys, values);
    WritingToFile writingToFile = new WritingToFile();
    hitRateFilePath = writingToFile.createLogFileIfItDoesNotExist(
      testLogTimestampFilePath,
      testFunctionName,
      serialisedTextString
    );

    return (hitRateFilePath);
  }
}
