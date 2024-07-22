// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @dev error throws when the balance of staker is not enough.
 */
error BalanceStakingTokenError();

/**
 * @dev error throws when the balance of the smart contract is too low
 */
error BalanceSmartContractError();

/**
 * @dev error throws when the balance of the smart contract is too low
 */
event IraTokenStaked(address indexed staker, uint indexed amount, uint indexed rewardsEarned);


contract IraStaking is Ownable {

    IERC20 private immutable stakingToken;
    IERC20 private immutable rewardToken;

    uint private finishedAt;
    uint private rewardRate1;
    uint private rewardRate2;
    uint private rewardRate3;

    constructor(address _stakingToken, address _rewardToken) Ownable(msg.sender){
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }


    /**
     * @notice Function called when a staker wants to stake the 'amountStaked'
     */
    function stake(uint amountStaked) external {
        if (stakingToken.balanceOf(msg.sender) == 0) revert BalanceStakingTokenError();

        stakingToken.transferFrom(msg.sender, address(this), amountStaked);
    }

    /**
     * @dev Enables the owner to withdrawamount of staking token staked
     */
    function withdraw(address to_, uint amount_) external onlyOwner() {
        if (stakingToken.balanceOf(address(this)) < amount_) revert BalanceSmartContractError();
        stakingToken.transfer(to_, amount_);
    }

    function getRewardsEarned(address account_) external view returns(uint) {

    }

    function claimReward() external {

    }

    /**
     * @dev Getter for 'stakingToken'
     */
    function getStakingToken() public view returns(address) {
        return address(stakingToken);
    }

    /**
     * @dev Getter for 'rewardToken'
     */
    function getRewardToken() public view returns(address) {
        return address(rewardToken);
    }

   function getFinishedAt() public view returns(uint) {
        return finishedAt;
    }

    /**
     * @dev Getter for 'rewardRate1'
     */
    function getRewardRate1() public view returns(uint) {
        return rewardRate1;
    }

    /**
     * @dev Getter for 'rewardRate2'
     */
    function getRewardRate2() public view returns(uint) {
        return rewardRate2;
    }

    /**
     * @dev Getter for 'rewardRate2'
     */
    function getRewardRate3() public view returns(uint) {
        return rewardRate3;
    }
}