// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {sToken} from "./sToken.sol";

contract StackupVault {
    // mapping of token address to underlying tokens and claim tokens
    mapping(address => IERC20) public tokens;
    mapping(address => sToken) public claimTokens;

    constructor(address uniAddr, address linkAddr) {
        // initialize mapping of underlying token address => claim tokens
        claimTokens[uniAddr] = new sToken("Claim Uni", "sUNI");
        claimTokens[linkAddr] = new sToken("Claim Link", "sLINK");

        // initialize mapping of underlying token address => underlying tokens
        tokens[uniAddr] = IERC20(uniAddr);
        tokens[linkAddr] = IERC20(linkAddr);
    }

    function deposit(address tokenAddr, uint256 amount) external {
        // create local variables
        IERC20 token = tokens[tokenAddr]; // assign it the IERC20 instance corresponding to the tokenAddr from the tokens mapping
        sToken claimToken = claimTokens[tokenAddr]; // assign it the sToken instance corresponding to the tokenAddr from the claimTokens mapping

        // transfer underlying tokens from user to vault, assume that user has already approved vault to transfer underlying tokens
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "transferFrom failed"
        );

        // mint sTokens
        claimToken.mint(msg.sender, amount);
    }

    function withdraw(address tokenAddr, uint256 amount) external {
        sToken claimToken = claimTokens[tokenAddr];
        IERC20 token = tokens[tokenAddr];

        // burn sTokens
        claimToken.burn(msg.sender, amount);

        // transfer underlying tokens from vault to user
        require(token.transfer(msg.sender, amount), "transfer failed");
    }
}
