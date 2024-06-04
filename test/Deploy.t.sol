// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { Deploy } from "../../script/Deploy.s.sol";

interface ITestDeploy {
  function setUp() external;

  function testRunMain() external;
}

contract TestDeploy is PRBTest, ITestDeploy {
  Deploy private _deploy;

  function setUp() public override {
    _deploy = new Deploy();
  }

  function testRunMain() public override {
    _deploy.runMain(); // Call the run0 function to deploy Main.sol
  }
}
