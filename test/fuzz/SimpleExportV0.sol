// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { Vm } from "forge-std/src/Vm.sol";
import "test/TestConstants.sol";
import { TestCaseHitRateLoggerToFile } from "./fuzz_helper/TestCaseHitRateLoggerToFile.sol";
import { Tuple } from "./fuzz_helper/Tuple.sol";

struct ExampleStruct {
  Tuple.StringUint256 a;
  Tuple.StringUint256 b;
  Tuple.StringUint256 c;
}

contract SimpleExport is PRBTest, StdCheats {
  ExampleStruct private _exampleStruct;
  string private _tempFilePath = "tempFile.json";
  TestCaseHitRateLoggerToFile private _testCaseHitRateLoggerToFile;

  /** The setUp() method is called once each fuzz run.*/
  function setUp() public virtual {
    _testCaseHitRateLoggerToFile = new TestCaseHitRateLoggerToFile();
    _exampleStruct = ExampleStruct({
      a: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 4),
      b: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 3),
      c: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 5)
    });

    // TODO: Serialise the struct.
    string memory serialisedTextString = _serialiseExampleStruct(_exampleStruct);

    vm.writeJson(serialisedTextString, _tempFilePath);

    bytes memory data = _testCaseHitRateLoggerToFile.readDataFromFile(_tempFilePath);
    // abi.decode(data, (LogParams));
    // Unpack sorted HitRate data from file into HitRatesReturnAll object.
    emit Log("About to do decode");
    // ExampleStruct memory readLogParams = abi.decode(data, (ExampleStruct));
    _retryDecode(data);
    string memory jsonString = string(data);
    emit Log("AFTER jsonString=");
    emit Log(jsonString);
  }

  function _retryDecode(bytes memory readData) private returns (ExampleStruct memory readLogParams) {
    // Convert bytes to string using proper conversion
    string memory jsonString = _bytesToString(readData);
    emit Log("jsonString=");
    emit Log(jsonString);
    // Parse the JSON fields
    bytes memory jsonABytes = vm.parseJson(jsonString, ".a");
    bytes memory jsonBBytes = vm.parseJson(jsonString, ".b");
    bytes memory jsonCBytes = vm.parseJson(jsonString, ".c");

    // Convert parsed JSON bytes into string for each field
    string memory jsonA = _bytesToString(jsonABytes);
    emit Log("jsonA=");
    emit Log(jsonA);
    string memory jsonB = _bytesToString(jsonBBytes);
    string memory jsonC = _bytesToString(jsonCBytes);

    emit Log('_bytesToString(vm.parseJson(jsonA, ".str")=');
    emit Log(_bytesToString(vm.parseJson(jsonA, ".str")));
    emit Log('_bytesToString(vm.parseJson(jsonA, ".number")=');
    emit Log(_bytesToString(vm.parseJson(jsonA, ".number")));
    // Manually construct the ExampleStruct from parsed JSON
    readLogParams.a = Tuple.StringUint256(
      _bytesToString(vm.parseJson(jsonA, ".str")),
      vm.parseJsonUint(jsonA, ".number")
    );
    readLogParams.b = Tuple.StringUint256(
      _bytesToString(vm.parseJson(jsonB, ".str")),
      vm.parseJsonUint(jsonB, ".number")
    );
    readLogParams.c = Tuple.StringUint256(
      _bytesToString(vm.parseJson(jsonC, ".str")),
      vm.parseJsonUint(jsonC, ".number")
    );

    return readLogParams;
  }

  function _bytesToString(bytes memory data) private pure returns (string memory) {
    return string(data);
  }

  // function _retryDecode(bytes memory readData) private returns (ExampleStruct memory readLogParams){
  //       string memory jsonString = string(readData);
  //   // Read the file and parse the JSON into the ExampleStruct
  //   string memory data = vm.readFile(_tempFilePath);
  //   string memory jsonA = vm.parseJson(jsonString, ".a");
  //   string memory jsonB = vm.parseJson(jsonString, ".b");
  //   string memory jsonC = vm.parseJson(jsonString, ".c");

  //   // Manually construct the ExampleStruct from parsed JSON
  //   readLogParams.a = Tuple.StringUint256(vm.parseJson(jsonA, ".str"), vm.parseJsonUint(jsonA, ".number"));
  //   readLogParams.b = Tuple.StringUint256(vm.parseJson(jsonB, ".str"), vm.parseJsonUint(jsonB, ".number"));
  //   readLogParams.c = Tuple.StringUint256(vm.parseJson(jsonC, ".str"), vm.parseJsonUint(jsonC, ".number"));
  //   return readLogParams;

  // }

  function _serialiseExampleStruct(ExampleStruct memory example) internal pure returns (string memory) {
    string memory serialised = "{";
    serialised = string(
      abi.encodePacked(
        serialised,
        '"a": { "str": "',
        example.a.str,
        '", "number": ',
        Strings.toString(example.a.number),
        "},"
      )
    );
    serialised = string(
      abi.encodePacked(
        serialised,
        '"b": { "str": "',
        example.b.str,
        '", "number": ',
        Strings.toString(example.b.number),
        "},"
      )
    );
    serialised = string(
      abi.encodePacked(
        serialised,
        '"c": { "str": "',
        example.c.str,
        '", "number": ',
        Strings.toString(example.c.number),
        "}"
      )
    );
    serialised = string(abi.encodePacked(serialised, "}"));
    return serialised;
  }

  function oldDestFuzzFunction(uint256 randomValue) public virtual {
    emit Log("FIRST CALL");
  }
}
