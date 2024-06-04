// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;

import "forge-std/src/Vm.sol" as vm;
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { Main } from "../../src/Main.sol";

interface ITestAddTwo {
  function setUp() external;

  function testAddTwo() external;
}

contract TestAddTwo is PRBTest, StdCheats, ITestAddTwo {
  Main private _main;

  function setUp() public virtual override {
    _main = new Main(31);
  }

  function testAddTwo() public override {
    uint256 inputVal = 5;
    uint256 expectedOutput = 7;

    assertEq(_main.addTwo(inputVal), expectedOutput);
  }
}
