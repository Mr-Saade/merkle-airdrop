// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop, IERC20} from "../src/Airdrop.sol";
import {Script} from "forge-std/Script.sol";
import {FCToken} from "../src/FCToken.sol";
import {console} from "forge-std/console.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    // 4 users, 25 FC tokens each
    uint256 public AMOUNT_TO_TRANSFER = 4 * (25 * 1e18);

    function deployMerkleAirdrop() public returns (MerkleAirdrop, FCToken) {
        vm.startBroadcast();
        FCToken fcToken = new FCToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(ROOT, IERC20(fcToken));
        // Send Bagel tokens -> Merkle Air Drop contract
        fcToken.mint(fcToken.owner(), AMOUNT_TO_TRANSFER);
        IERC20(fcToken).transfer(address(airdrop), AMOUNT_TO_TRANSFER);
        vm.stopBroadcast();
        return (airdrop, fcToken);
    }

    function run() external returns (MerkleAirdrop, FCToken) {
        return deployMerkleAirdrop();
    }
}
