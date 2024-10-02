pragma solidity >=0.8.25 <0.9.0;
/**
  The logging flow is described with:
    1. Initialise the mapping at all 0 values, and export those to file and set them in the struct.
      initialiseMapping(_tupleMapping)
  Loop:
    2. The values from the log file are read from file and overwrite those in the mapping.
    readHitRatesFromLogFileAndSetToMap()
    3. The code is ran, the mapping values are updated.
    4. The mapping values are logged to file.

  The mapping key value pairs exist in this map unstorted. Then they are
  written to a file in a sorted fashion. They are sorted automatically.
  Then they are read from file in alphabetical order. Since they are read in
  alphabetical order (automatically), they can stored into the alphabetical
  keys of the map using a switch case and enumeration (counts as indices).

  TODO: verify the non-alphabetical keys of a mapping are exported to an
  alphabetical order.
  TODO: verify the non-alphabetical keys of a file are exported and read into
  alphabetical order.
  */
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import "forge-std/src/Vm.sol";
import "test/TestConstants.sol";
import { IterableTupleMapping } from "./IterableTupleMapping.sol";
import { OverWriteFile } from "./OverWriteFile.sol";
import { TestCaseHitRateLoggerToFile } from "./TestCaseHitRateLoggerToFile.sol";
import { Tuple } from "./Tuple.sol";
/**
Stores the counters used to track how often the different branches of the tests are covered.*/
struct LogParams {
  Tuple.StringUint256 a;
  Tuple.StringUint256 b;
  Tuple.StringUint256 c;
  Tuple.StringUint256 d;
  Tuple.StringUint256 e;
  Tuple.StringUint256 f;
  Tuple.StringUint256 g;
  Tuple.StringUint256 h;
  Tuple.StringUint256 i;
  Tuple.StringUint256 j;
  Tuple.StringUint256 k;
  Tuple.StringUint256 l;
  Tuple.StringUint256 m;
  Tuple.StringUint256 n;
  Tuple.StringUint256 o;
  Tuple.StringUint256 p;
  Tuple.StringUint256 q;
  Tuple.StringUint256 r;
  Tuple.StringUint256 s;
  Tuple.StringUint256 t;
  Tuple.StringUint256 u;
  Tuple.StringUint256 v;
  Tuple.StringUint256 w;
  Tuple.StringUint256 x;
  Tuple.StringUint256 y;
  Tuple.StringUint256 z;
}

contract FuzzTestCaseCounter is PRBTest, StdCheats {
  using IterableTupleMapping for IterableTupleMapping.Map;
  IterableTupleMapping.Map private _tupleMapping;

  TestCaseHitRateLoggerToFile private _testCaseHitRateLoggerToFile;
  string private _hitRateFilePath;
  LogParams private _logParams;

  constructor(string memory testLogTimestampFilePath, string memory testFunctionName) {
    _testCaseHitRateLoggerToFile = new TestCaseHitRateLoggerToFile();
    _hitRateFilePath = initialiseMapping(testLogTimestampFilePath, testFunctionName);
  }

  function getHitRateFilePath() public view returns (string memory) {
    // TODO: if _hitRateFilePath == "": raise exception.
    return _hitRateFilePath;
  }

  /** Exports the current _tupleMapping to the already existing log file. Throws an error
  if the log file does not yet exist.*/
  function overwriteExistingMapLogFile(string memory hitRateFilePath) public {
    // TODO: assert the file already exists, throw error if file does not yet exist.
    string memory serialisedTextString = _testCaseHitRateLoggerToFile.convertHitRatesToString(
      _tupleMapping.getKeys(),
      _tupleMapping.getValues()
    );
    // overwriteFileContent(serialisedTextString, hitRateFilePath);
    _testCaseHitRateLoggerToFile.overwriteFileContent(serialisedTextString, hitRateFilePath);
    emit Log("Wrote to file!");
    // TODO: assert the log filecontent equals the current _tupleMappingping values.
  }

  /** Reads the log data (parameter name and value) from the file, converts it
into a struct, and then converts that struct into this _tupleMappingping.
 */
  function readHitRatesFromLogFileAndSetToMap(string memory hitRateFilePath) public {
    bytes memory data = _testCaseHitRateLoggerToFile.readDataFromFile(hitRateFilePath);
    emit Log("About to do decode");
    abi.decode(data, (LogParams));
    // Unpack sorted HitRate data from file into HitRatesReturnAll object.
    LogParams memory readLogParams = abi.decode(data, (LogParams));
    // Update the hit rate _tupleMappingping using the HitRatesReturnAll object.
    updateLogParamMapping({ logParams: readLogParams });

    // TODO: assert the data in the log file equals the data in this _tupleMapping.
  }

  // TODO: make private.
  function initialiseMapping(
    string memory testLogTimestampFilePath,
    string memory testFunctionName
  ) public returns (string memory hitRateFilePath) {
    _logParams = LogParams({
      a: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      b: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      c: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      d: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      e: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      f: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      g: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      h: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      i: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      j: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      k: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      l: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      m: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      n: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      o: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      p: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      q: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      r: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      s: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      t: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      u: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      v: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      w: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      x: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      y: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0),
      z: Tuple.StringUint256(_INITIAL_VARIABLE_PLACEHOLDER, 0)
    });

    updateLogParamMapping(_logParams);

    // This should just be to get the hitRateFilePath because the data should
    // already exist.
    hitRateFilePath = _testCaseHitRateLoggerToFile.createLogIfNotExistAndReadLogData(
      testLogTimestampFilePath,
      testFunctionName,
      _tupleMapping.getKeys(),
      _tupleMapping.getValues()
    );

    return hitRateFilePath;
  }

  function callIncrementLogCount(string memory variableName) public {
    _tupleMapping.incrementLogCount(variableName);
  }

  // solhint-disable-next-line foundry-test-functions
  function updateLogParamMapping(LogParams memory logParams) public {
    // TODO: update the keys to represent the actual keys in the logParams object.
    for (uint256 i = 0; i < _MAX_NR_OF_TEST_LOG_VALUES_PER_LOG_FILE; i++) {
      if (i == 0) {
        _tupleMapping.set("a", logParams.a);
      } else if (i == 1) {
        _tupleMapping.set("b", logParams.b);
      } else if (i == 2) {
        _tupleMapping.set("c", logParams.c);
      } else if (i == 3) {
        _tupleMapping.set("d", logParams.d);
      } else if (i == 4) {
        _tupleMapping.set("e", logParams.e);
      } else if (i == 5) {
        _tupleMapping.set("f", logParams.f);
      } else if (i == 6) {
        _tupleMapping.set("g", logParams.g);
      } else if (i == 7) {
        _tupleMapping.set("h", logParams.h);
      } else if (i == 8) {
        _tupleMapping.set("i", logParams.i);
      } else if (i == 9) {
        _tupleMapping.set("j", logParams.j);
      } else if (i == 10) {
        _tupleMapping.set("k", logParams.k);
      } else if (i == 11) {
        _tupleMapping.set("l", logParams.l);
      } else if (i == 12) {
        _tupleMapping.set("m", logParams.m);
      } else if (i == 13) {
        _tupleMapping.set("n", logParams.n);
      } else if (i == 14) {
        _tupleMapping.set("o", logParams.o);
      } else if (i == 15) {
        _tupleMapping.set("p", logParams.p);
      } else if (i == 16) {
        _tupleMapping.set("q", logParams.q);
      } else if (i == 17) {
        _tupleMapping.set("r", logParams.r);
      } else if (i == 18) {
        _tupleMapping.set("s", logParams.s);
      } else if (i == 19) {
        _tupleMapping.set("t", logParams.t);
      } else if (i == 20) {
        _tupleMapping.set("u", logParams.u);
      } else if (i == 21) {
        _tupleMapping.set("v", logParams.v);
      } else if (i == 22) {
        _tupleMapping.set("w", logParams.w);
      } else if (i == 23) {
        _tupleMapping.set("x", logParams.x);
      } else if (i == 24) {
        _tupleMapping.set("y", logParams.y);
      } else if (i == 25) {
        _tupleMapping.set("z", logParams.z);
      }
    }
  }
}
