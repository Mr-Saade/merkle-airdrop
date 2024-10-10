// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Stablecoin Contract
/// @dev Represents the stablecoin token pegged to $1
contract FCToken is ERC20, Ownable {
    constructor() ERC20("FCToken", "FCT") Ownable(msg.sender) {}

    /// @notice Mint new tokens
    /// @param to The address to receive the tokens
    /// @param amount The amount of tokens to mint
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
