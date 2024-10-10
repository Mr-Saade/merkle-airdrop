// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../src/Airdrop.sol";
import {FCToken} from "../src/FCToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployMerkleAirdrop} from "../script/MerkleAirdropDeploy.s.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop airdrop;
    FCToken token;
    address gasPayer;
    address whitelistedUser;
    uint256 userPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80; //defaiult anvil private key

    uint256 amountToCollect = (25 * 1e18); // 25.0 FC

    bytes32 proofOne = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [proofOne, proofTwo];

    function setUp() public {
        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        (airdrop, token) = deployer.run();

        gasPayer = makeAddr("gasPayer");
        whitelistedUser = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // Default anvil user address
    }

    function signMessage(uint256 userPrivKey, address account) public view returns (bytes memory) {
        bytes32 hashedMessage = airdrop.getMessageHash(account, amountToCollect);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, hashedMessage);
        return abi.encodePacked(r, s, v);
    }

    function testUsersCanCallClaimOnBehalfOfAnotherUserWithValidSignature() public {
        uint256 startingBalance = token.balanceOf(whitelistedUser);

        // get the signature
        bytes memory signature = signMessage(userPrivateKey, whitelistedUser);

        // gasPayer claims the airdrop for the user
        vm.prank(gasPayer);
        airdrop.claimOnBehalf(whitelistedUser, amountToCollect, proof, signature);
        uint256 endingBalance = token.balanceOf(whitelistedUser);
        console.log("Ending balance: %d", endingBalance);
        assertEq(endingBalance - startingBalance, amountToCollect);
    }

    function testUsersCanClaimForTheirOwnAccount() public {
        uint256 startingBalance = token.balanceOf(whitelistedUser);
        vm.prank(whitelistedUser);
        airdrop.claimSelf(amountToCollect, proof);
        uint256 endingBalance = token.balanceOf(whitelistedUser);
        console.log("Ending balance: %d", endingBalance);
        assertEq(endingBalance - startingBalance, amountToCollect);
    }
}
