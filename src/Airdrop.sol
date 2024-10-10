// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    IERC20 private immutable i_airdropToken;
    bytes32 private immutable i_merkleRoot;
    mapping(address => bool) private s_hasClaimed;

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");

    //Message struct
    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    event Claimed(address account, uint256 amount);
    event MerkleRootUpdated(bytes32 newMerkleRoot);

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("Merkle Airdrop", "1.0.0") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    // Claim the airdrop for the user themselves
    function claimSelf(uint256 amount, bytes32[] calldata merkleProof) external {
        _claim(msg.sender, amount, merkleProof);
    }

    // Claim the airdrop on behalf of a whitelisted user
    function claimOnBehalf(address account, uint256 amount, bytes32[] calldata merkleProof, bytes calldata signature)
        external
    {
        bytes32 digest = getMessageHash(account, amount);
        if (!_isValidSignature(account, digest, signature)) {
            revert MerkleAirdrop__InvalidSignature();
        }

        _claim(account, amount, merkleProof);
    }

    // Get the message hash that needs to be signed
    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        AirdropClaim memory claim = AirdropClaim({account: account, amount: amount});
        return _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, claim.account, claim.amount)));
    }

    /*//////////////////////////////////////////////////////////////
                             INTERNAL
    //////////////////////////////////////////////////////////////*/

    // Internal function to handle the common claiming logic
    function _claim(address account, uint256 amount, bytes32[] calldata merkleProof) internal {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        // Verify the Merkle proof
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        // Mark as claimed and transfer tokens
        s_hasClaimed[account] = true;
        emit Claimed(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    // Verify whether the recovered signer is the expected signer (the account to airdrop tokens to)
    function _isValidSignature(address signer, bytes32 digest, bytes calldata signature) internal pure returns (bool) {
        (address recovered,,) = ECDSA.tryRecover(digest, signature);
        return recovered == signer;
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW AND PURE
    //////////////////////////////////////////////////////////////*/
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
