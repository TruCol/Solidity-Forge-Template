pragma solidity >=0.8.25 <0.9.0;
/**
  The logging flow is described with:
    1. Initialise the mapping at all 0 values, and export those to file and set them in the struct.
      initialiseMapping(_uint256Map)
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
import { IterableUint256Mapping } from "./IterableUint256Mapping.sol";
import { TestCaseHitRateLoggerToFile } from "./TestCaseHitRateLoggerToFile.sol";
/**
Stores the counters used to track how often the different branches of the tests are covered.*/
struct LogParams {
  uint256 a;
  uint256 b;
  uint256 c;
  uint256 d;
  uint256 e;
  uint256 f;
  uint256 g;
  uint256 h;
  uint256 i;
  uint256 j;
  uint256 k;
  uint256 l;
  uint256 m;
  uint256 n;
  uint256 o;
  uint256 p;
  uint256 q;
  uint256 r;
  uint256 s;
  uint256 t;
  uint256 u;
  uint256 v;
  uint256 w;
  uint256 x;
  uint256 y;
  uint256 z;
}

contract TestIterableMapping is PRBTest, StdCheats {
  using IterableUint256Mapping for IterableUint256Mapping.Map;
  IterableUint256Mapping.Map private _uint256Map;

  TestCaseHitRateLoggerToFile private _testCaseHitRateLoggerToFile;
  string private _hitRateFilePath;
  LogParams private _logParams;

  constructor(string memory testLogTimestampFilePath, string memory testFunctionName) {
    _testCaseHitRateLoggerToFile = new TestCaseHitRateLoggerToFile();
    _hitRateFilePath = initialiseMapping(testLogTimestampFilePath, testFunctionName);
  }

  function get(string memory key) public view returns (uint256) {
    return _uint256Map.values[key];
  }

  function set(string memory key, uint256 val) public {
    if (_uint256Map.inserted[key]) {
      _uint256Map.values[key] = val;
    } else {
      _uint256Map.inserted[key] = true;
      _uint256Map.values[key] = val;
      _uint256Map.indexOf[key] = _uint256Map.keys.length;
      _uint256Map.keys.push(key);
    }
  }

  function getHitRateFilePath() public view returns (string memory) {
    // TODO: if _hitRateFilePath == "": raise exception.
    return _hitRateFilePath;
  }

  /** Exports the current _uint256Map to the already existing log file. Throws an error
  if the log file does not yet exist.*/
  function overwriteExistingMapLogFile(string memory hitRateFilePath) public {
    // TODO: assert the file already exists, throw error if file does not yet exist.
    string memory serialisedTextString = _testCaseHitRateLoggerToFile.convertHitRatesToString(
      _uint256Map.getKeys(),
      _uint256Map.getValues()
    );
    // overwriteFileContent(serialisedTextString, hitRateFilePath);
    _testCaseHitRateLoggerToFile.overwriteFileContent(serialisedTextString, hitRateFilePath);
    // TODO: assert the log filecontent equals the current _uint256Mapping values.
  }

  /** Reads the log data (parameter name and value) from the file, converts it
into a struct, and then converts that struct into this _uint256Mapping.
 */
  function readHitRatesFromLogFileAndSetToMap(string memory hitRateFilePath) public {
    bytes memory data = _testCaseHitRateLoggerToFile.readLogData(hitRateFilePath);
    abi.decode(data, (LogParams));
    // Unpack sorted HitRate data from file into HitRatesReturnAll object.
    LogParams memory readLogParams = abi.decode(data, (LogParams));
    // Update the hit rate _uint256Mapping using the HitRatesReturnAll object.
    updateLogParamMapping({ logParams: readLogParams });

    // TODO: assert the data in the log file equals the data in this _uint256Map.
  }

  // TODO: make private.
  function initialiseMapping(
    string memory testLogTimestampFilePath,
    string memory testFunctionName
  ) public returns (string memory hitRateFilePath) {
    _logParams = LogParams({
      a: 0,
      b: 0,
      c: 0,
      d: 0,
      e: 0,
      f: 0,
      g: 0,
      h: 0,
      i: 0,
      j: 0,
      k: 0,
      l: 0,
      m: 0,
      n: 0,
      o: 0,
      p: 0,
      q: 0,
      r: 0,
      s: 0,
      t: 0,
      u: 0,
      v: 0,
      w: 0,
      x: 0,
      y: 0,
      z: 0
    });

    updateLogParamMapping(_logParams);

    // This should just be to get the hitRateFilePath because the data should
    // already exist.
    hitRateFilePath = _testCaseHitRateLoggerToFile.createLogIfNotExistAndReadLogData(
      testLogTimestampFilePath,
      testFunctionName,
      _uint256Map.getKeys(),
      _uint256Map.getValues()
    );

    return hitRateFilePath;
  }

  // solhint-disable-next-line foundry-test-functions
  function updateLogParamMapping(LogParams memory logParams) public {
    // TODO: update the keys to represent the actual keys in the logParams object.
    for (uint256 i = 0; i < _MAX_NR_OF_TEST_LOG_VALUES_PER_LOG_FILE; i++) {
      if (i == 0) {
        _uint256Map.set("a", logParams.a);
      } else if (i == 1) {
        _uint256Map.set("b", logParams.b);
      } else if (i == 2) {
        _uint256Map.set("c", logParams.c);
      } else if (i == 3) {
        _uint256Map.set("d", logParams.d);
      } else if (i == 4) {
        _uint256Map.set("e", logParams.e);
      } else if (i == 5) {
        _uint256Map.set("f", logParams.f);
      } else if (i == 6) {
        _uint256Map.set("g", logParams.g);
      } else if (i == 7) {
        _uint256Map.set("h", logParams.h);
      } else if (i == 8) {
        _uint256Map.set("i", logParams.i);
      } else if (i == 9) {
        _uint256Map.set("j", logParams.j);
      } else if (i == 10) {
        _uint256Map.set("k", logParams.k);
      } else if (i == 11) {
        _uint256Map.set("l", logParams.l);
      } else if (i == 12) {
        _uint256Map.set("m", logParams.m);
      } else if (i == 13) {
        _uint256Map.set("n", logParams.n);
      } else if (i == 14) {
        _uint256Map.set("o", logParams.o);
      } else if (i == 15) {
        _uint256Map.set("p", logParams.p);
      } else if (i == 16) {
        _uint256Map.set("q", logParams.q);
      } else if (i == 17) {
        _uint256Map.set("r", logParams.r);
      } else if (i == 18) {
        _uint256Map.set("s", logParams.s);
      } else if (i == 19) {
        _uint256Map.set("t", logParams.t);
      } else if (i == 20) {
        _uint256Map.set("u", logParams.u);
      } else if (i == 21) {
        _uint256Map.set("v", logParams.v);
      } else if (i == 22) {
        _uint256Map.set("w", logParams.w);
      } else if (i == 23) {
        _uint256Map.set("x", logParams.x);
      } else if (i == 24) {
        _uint256Map.set("y", logParams.y);
      } else if (i == 25) {
        _uint256Map.set("z", logParams.z);
      }
    }
  }
}
