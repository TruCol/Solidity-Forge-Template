// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26 <0.9.0;

import { Main } from "./../src/Main.sol";
import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
  // solhint-disable-next-line comprehensive-interface
  function runMain() public broadcast returns (Main main) {
    main = new Main(31);
  }

  // To make forge coverage skip this file.
  // solhint-disable-next-line no-empty-blocks
  function test() public override {}
}
