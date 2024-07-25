// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;
/**
 * @dev error throws when the address is null
 */
error AddressZeroError();

/**
 * @dev error throws when the staker wants to unstake an amount greater than he staked
 */
error AmountToUnstakeTooHighError();

/**
 * @dev error throws when the staker wants to stake a null amount 
 */
error AmountStakedZeroError();

/**
 * @dev error throws when the balance of the smart contract is too low
 */
error BalanceSmartContractError();

/**
 * @dev error throws when the balance of staker is not enough.
 */
error BalanceStakingTokenError();

/**
 * @dev error throws when the staker wants to claim rewards before the minimal amount of months
 */
error ClaimError();

/**
 * @dev error throws when the index of staking array is out of range
 */
error IndexStakingOutsideRangeError();

/**
 * @dev error throws when the staking deposit index does not work
 */
error IndexStakingDepositError();

/**
 * @dev error throws when the staker wants to unstake before the minimal amount of months
 */
error UnstakeError();


