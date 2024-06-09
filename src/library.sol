// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
library stringManipulation {
    function toLowerCase(string memory str) internal pure returns (string memory) {
        bytes memory stri = bytes(str);
        bytes memory lower = new bytes(stri.length);
        for (uint i = 0; i < stri.length; i++) {
            if (uint8(stri[i]) >= 65 && uint8(stri[i]) <= 91)
                lower[i] = bytes1(uint8(stri[i]) + 32);
            else lower[i] = stri[i];
        }
        return string(lower);
    }
    function compare(string memory str1, string memory str2) internal pure returns (bool) {
        return(keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2)));
    }

    /**
     * creates a bytes32 array from two strings
     * @param str1 first string
     * @param str2 second string
     */
    function generateID(string memory str1, string memory str2) internal pure returns (bytes32) {
        return(keccak256(abi.encodePacked(str1, str2)));
    }
    
}