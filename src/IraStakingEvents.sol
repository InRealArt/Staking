// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;


/**
 * @dev event emit when staker deposit amount to stake
 */
event RewardTokenStaked(address indexed staker, uint indexed amount);

/**
 * @dev event emit when staker claims his reward on the specific element of staking array 
 */
event RewardTokenClaimed(address indexed staker, uint16 indexed _indexStakingDate, uint indexed rewardAmountClaimed);

/**
 * @dev event emit when staker unstakes an amount of staking tokens on the specific element of staking array 
 */
event RewardTokenUnstaked(address indexed staker, uint16 indexed _indexStakingDate, uint indexed tokenAmountUnstaked);
