pragma solidity >=0.8.25 <0.9.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { Vm } from "forge-std/src/Vm.sol";

contract OverWriteFile is PRBTest, StdCheats {
  // Function to replace occurrences of string a with string b
  function replaceString(
    string memory original,
    string memory search,
    string memory replacement
  ) public returns (string memory) {
    bytes memory originalBytes = bytes(original);

    bytes memory searchBytes = bytes(search);

    bytes memory replacementBytes = bytes(replacement);

    uint256 counterLimit = originalBytes.length - searchBytes.length;

    // Count occurrences of the search string
    uint256 occurrences = 0;
    for (uint256 i = 0; i <= counterLimit; i++) {
      bool isMatch;
      isMatch = true;
      for (uint256 j = 0; j < searchBytes.length; j++) {
        if (originalBytes[i + j] != searchBytes[j]) {
          isMatch = false;
          break;
        }
      }

      if (isMatch) {
        occurrences++;

        i += searchBytes.length - 1;
      }
    }
    emit Log("originalBytes.length");
    emit Log(Strings.toString(originalBytes.length));
    emit Log("replacementBytes.length");
    emit Log(Strings.toString(replacementBytes.length));
    emit Log("searchBytes.length");
    emit Log(Strings.toString(searchBytes.length));
    emit Log("occurrences");
    emit Log(Strings.toString(occurrences));
    // Create a new bytes array to store the modified string

    bytes memory result;
    if (replacementBytes.length > searchBytes.length) {
      result = new bytes(originalBytes.length + (replacementBytes.length - searchBytes.length) * occurrences);
    } else if (replacementBytes.length < searchBytes.length) {
      result = new bytes(originalBytes.length - (searchBytes.length - replacementBytes.length) * occurrences);
    } else {
      result = new bytes(originalBytes.length);
    }

    uint256 k = 0;
    for (uint256 i = 0; i < originalBytes.length; ) {
      bool isMatch = true;
      for (uint256 j = 0; j < searchBytes.length; j++) {
        if (i + j >= originalBytes.length || originalBytes[i + j] != searchBytes[j]) {
          isMatch = false;
          break;
        }
      }

      if (isMatch) {
        for (uint256 j = 0; j < replacementBytes.length; j++) {
          result[k++] = replacementBytes[j];
        }

        i += searchBytes.length;
      } else {
        result[k++] = originalBytes[i++];
      }
    }
    return string(result);
  }

  function testStringReplacementInFile() public {
    // Step 1: Read the file content into a string
    string memory filePath = "./test_logging/replacements.txt";
    string memory fileContents = vm.readFile(filePath);

    // Step 2: Call the replaceString function to modify the content
    string memory modifiedContents = replaceString(fileContents, "oldString", "newString");

    // Step 3: Write the modified content back to the file
    vm.writeFile(filePath, modifiedContents);

    // Optionally, you can add asserts to verify if the file content was modified as expected
    string memory newFileContents = vm.readFile(filePath);
    assertEq(newFileContents, modifiedContents);
  }

  function removeFirstAndLastChar(string memory str) public pure returns (string memory) {
    bytes memory strBytes = bytes(str);
    if (strBytes.length <= 2) {
        return ""; // Return empty string if length is less than or equal to 2
    }
    bytes memory result = new bytes(strBytes.length - 2);
    for (uint i = 1; i < strBytes.length - 1; i++) {
        result[i - 1] = strBytes[i];
    }
    return string(result);
}

}
