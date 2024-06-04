// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26; // Specifies the Solidity compiler version.

error ThisIsSomeCustomError(string message, uint256 someValue);

interface IMain {
  function addTwo(uint256 x) external pure returns (uint256 y);
}

// solhint-disable-next-line max-states-count
contract Main is IMain {
  // solhint-disable-next-line immutable-vars-naming
  uint256 private immutable _someValue;

  /**
  @notice This Initialises the main contract.

  @dev This is for devs.
  */
  // solhint-disable-next-line comprehensive-interface
  constructor(uint256 someValue) {
    _someValue = someValue;
  }

  /**
   * @dev Adds 2 to an incoming int.
   *
   * @param x The starting value to which 2 is added.
   *
   * @return y The value after adding two.
   */
  function addTwo(uint256 x) public pure override returns (uint256 y) {
    y = x + 2;
    return y;
  }
}
