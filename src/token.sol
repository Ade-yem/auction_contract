// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract AdeToken is ERC20 {
    // bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC20("Ade token", "ADETK") {
        // _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // _grantRole(MINTER_ROLE, minter);
    }

    /**
     * Mint token
     * @param to address to send token to
     * @param amount amount of token
     */

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

// contract address 0x3876c57dBCDaCfE288d6D5f875268c916C7b0c3f

