// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { Vm } from "forge-std/src/Vm.sol";

contract Debug is PRBTest, StdCheats {
  uint256 private _someNr;

  /** The setUp() method is called once each fuzz runs is performed.*/
  function setUp() public virtual {
    _someNr = 5;
  }

  function testFuzzDebug(uint256 randomValue) public virtual {
    assertEq(_someNr, 5);
    _someNr = 6;
    emit Log(Strings.toString(randomValue));
  }
}
