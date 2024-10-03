// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { Vm } from "forge-std/src/Vm.sol";
import "test/TestConstants.sol";
import { Tuple } from "./fuzz_helper/Tuple.sol";
import { TestCaseHitRateLoggerToFile } from "./fuzz_helper/TestCaseHitRateLoggerToFile.sol";

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
    ExampleStruct memory readLogParams = abi.decode(data, (ExampleStruct));
  }

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

  function testFuzzFunction(uint256 randomValue) public virtual {
    emit Log("FIRST CALL");
  }
}
