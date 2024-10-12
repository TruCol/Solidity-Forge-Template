pragma solidity >=0.8.25 <0.9.0;

contract Triple {
  struct ParameterStorage {
    string parameterName;
    uint256 hitCount;
    uint256 requiredHitCount;
  }
}
