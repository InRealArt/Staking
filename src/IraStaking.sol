// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Pausable} from "openzeppelin-contracts/contracts/utils/Pausable.sol";

/**
 * @dev error throws when the balance of staker is not enough.
 */
error BalanceStakingTokenError();

/**
 * @dev error throws when the balance of the smart contract is too low
 */
error BalanceSmartContractError();

/**
 * @dev error throws when the staking deposit index does not work
 */
error IndexStakingDepositError();

/**
 * @dev error throws when the address is null
 */
error AddressZeroError();

/**
 * @dev error throws when the staker wants to unstake before the minimal amount of months
 */
error UnstakeError();

/**
 * @dev error throws when the staker wants to claim rewards before the minimal amount of months
 */
error ClaimError();

/**
 * @dev error throws when the staker wants to unstake an amount greater than he staked
 */
error AmountToUnstakeTooHighError();

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


contract IraStaking is Ownable, Pausable {

    using SafeERC20 for IERC20;
    IERC20 private immutable s_stakingToken;
    IERC20 private immutable s_rewardToken;
    address private immutable s_rewarder;

    uint8 constant DECIMALS_HOURLY_REWARD_RATE = 10;
    uint8 constant DECIMALS_PERCENTAGE = 2;

    uint32 constant ONE_YEAR = 8760 hours;
    uint32 constant SIX_MONTHS = 4380 hours;
    uint32 constant THREE_MONTHS = 2190 hours;
    uint32 constant HOURS_IN_ONE_YEAR = 8760;
    uint32 private s_hourlyRewardRate1;
    uint32 private s_hourlyRewardRate2;
    uint32 private s_hourlyRewardRate3;

    uint16 private s_rewardRate1;
    uint16 private s_rewardRate2;
    uint16 private s_rewardRate3;


    uint private s_finishedAt;

    // key 1 : address of staker
    // key 2 : datetime of staking
    // key 3 : staked amount 
    mapping(address => mapping(uint => uint)) private s_amountStakedBy;
    mapping(address => mapping(uint => uint)) private s_amountRewardClaimedBy;
    mapping(address => uint[]) private s_stakingDatesOf;

    /**
     * @param _stakingToken : address of stakingToken
     * @param _rewardToken : address of rewardToken
     * @param _rewarder : address of rewarder that will send rewards to stakers
     */
    constructor(address _stakingToken, address _rewardToken, address _rewarder) Ownable(msg.sender) payable {
        s_stakingToken = IERC20(_stakingToken);
        s_rewardToken = IERC20(_rewardToken);
        s_rewarder = _rewarder;
        s_rewardRate1 = 6; //6%
        s_rewardRate2 = 9; //9%
        s_rewardRate3 = 12; //12%
        s_hourlyRewardRate1 = (s_rewardRate1 / HOURS_IN_ONE_YEAR) * DECIMALS_HOURLY_REWARD_RATE;
        s_hourlyRewardRate2 = (s_rewardRate2 / HOURS_IN_ONE_YEAR) * DECIMALS_HOURLY_REWARD_RATE;
        s_hourlyRewardRate3 = (s_rewardRate3 / HOURS_IN_ONE_YEAR) * DECIMALS_HOURLY_REWARD_RATE;
    }

    /**
     * @dev Check if the staker is granted to do some actions after minimum amount of locking
     */
    modifier ckeckStakingUnlock(uint16 _indexStakingDate) {
        uint[] storage stakingDates = s_stakingDatesOf[msg.sender];
        uint stakingDate = stakingDates[_indexStakingDate];
        uint stakingDurationInSeconds = (block.timestamp - stakingDate); 
        if (stakingDurationInSeconds < THREE_MONTHS) {
            revert UnstakeError();
        }
        _;
    }

    /**
     * @notice Function called when a staker wants to stake the 'amountStaked'
     * 
     */
    function stake(uint _amountStaked) external {
        if (s_stakingToken.balanceOf(msg.sender) == 0) revert BalanceStakingTokenError();

        //Store the staked amount by its address and the datetime of staking
        s_amountStakedBy[msg.sender][block.timestamp] = _amountStaked; 
        //Store the different datetilme of staking for a staker
        s_stakingDatesOf[msg.sender].push(block.timestamp);
        //The rewarder must approve this smart contract for transfer
        IERC20(s_stakingToken).safeTransferFrom(msg.sender, s_rewarder, _amountStaked);
        
        emit RewardTokenStaked(msg.sender, _amountStaked);
    }

    /**
     * @dev Unstake a certain amount in the specific element of the array of staking
     * Reverts tx if the staking period is under 3 Months
     */
    function unstake(uint16 _indexStakingDate, uint _amountToUnstake) external {
        uint[] storage stakingDates = s_stakingDatesOf[msg.sender];
        uint stakingDate = stakingDates[_indexStakingDate];
        uint stakingDurationInSeconds = (block.timestamp - stakingDate); 
        if (stakingDurationInSeconds < THREE_MONTHS) {
            revert UnstakeError();
        }

        uint amountStaked = s_amountStakedBy[msg.sender][stakingDate];

        if (_amountToUnstake > amountStaked) {
            revert AmountToUnstakeTooHighError();
        }
        
        emit RewardTokenUnstaked(msg.sender, _indexStakingDate, _amountToUnstake);
    }

    /**
     * @dev Function to calculate rewards by address of the staker
     * The staked amount must be expressed in the smallest unit of the token
     * @return totalRewards expressed in the decimals of the staking token
     */
    function calculateRewards(address _staker) internal view returns (uint) {
        uint totalRewards = 0;
        uint[] storage stakingDates = s_stakingDatesOf[_staker];
        
        for (uint i = 0; i < stakingDates.length; i++) {
            uint stakingDate = stakingDates[i];
            uint amountStaked = s_amountStakedBy[_staker][stakingDate];
            uint stakingDurationInSeconds = (block.timestamp - stakingDate); 
            uint stakingDurationInHours = (block.timestamp - stakingDate) / 1 hours; 
            uint hourlyRate = s_hourlyRewardRate1; // Default rate

            // Logic to determine the applicable rate based on duration
            if (stakingDurationInSeconds >= ONE_YEAR) {
                hourlyRate = s_hourlyRewardRate3; // 12% for 12 months
            } else if (stakingDurationInSeconds >= SIX_MONTHS) {
                hourlyRate = s_hourlyRewardRate2; // 9% for 6 months
            }


            // Calculate rewards for this staking deposit. 
            totalRewards += (amountStaked * hourlyRate * stakingDurationInHours) / (10**DECIMALS_PERCENTAGE);    
        }

        totalRewards = totalRewards / (10**DECIMALS_HOURLY_REWARD_RATE);
        return totalRewards; // Return total rewards earned        
    }

    /**
     * @dev Function to calculate rewards by address of the staker and the indexStakingDate
     */
    function calculateRewards(address _staker, uint16 _indexStakingDate) internal view returns (uint) {
        uint totalRewards = 0;
        uint[] storage stakingDates = s_stakingDatesOf[_staker];
        
        uint stakingDate = stakingDates[_indexStakingDate];

        uint amountStaked = s_amountStakedBy[_staker][stakingDate];
        uint stakingDurationInSeconds = (block.timestamp - stakingDate); 
        uint stakingDurationInHours = (block.timestamp - stakingDate) / 1 hours; 
        uint hourlyRate = s_hourlyRewardRate1; // Default rate

        // Logic to determine the applicable rate based on duration
        if (stakingDurationInSeconds >= ONE_YEAR) {
            hourlyRate = s_hourlyRewardRate3; // 12% for 12 months
        } else if (stakingDurationInSeconds >= SIX_MONTHS) {
            hourlyRate = s_hourlyRewardRate2; // 9% for 6 months
        }

        uint amountClaimed = s_amountRewardClaimedBy[msg.sender][_indexStakingDate];
        // Calculate rewards for this staking deposit. 
        totalRewards += (amountStaked * hourlyRate * stakingDurationInHours) / (10**DECIMALS_PERCENTAGE);    
        //We substract the amount already claimed by the user
        totalRewards -= amountClaimed;
        return totalRewards;
    }

    /**
     * @dev Enables the owner of the SC to withdraw amount of staking token
     */
    function withdraw(address _to, uint _amount) external onlyOwner() {
        if (s_stakingToken.balanceOf(address(this)) < _amount) revert BalanceSmartContractError();
        if (_to == address(0)) revert AddressZeroError();
        s_stakingToken.transfer(_to, _amount);
    }

    /**
     * @dev Claim Reward 
     */
    function claimReward(uint16 _indexStakingDate) external {
        uint[] storage stakingDates = s_stakingDatesOf[msg.sender];
        if (_indexStakingDate > stakingDates.length) revert IndexStakingDepositError();
        uint stakingDate = stakingDates[_indexStakingDate];
        uint stakingDurationInSeconds = (block.timestamp - stakingDate); 
        if (stakingDurationInSeconds < THREE_MONTHS) {
            revert ClaimError();
        }

        uint rewardAmountClaimed = calculateRewards(msg.sender, _indexStakingDate);
        s_amountRewardClaimedBy[msg.sender][stakingDate] = s_amountRewardClaimedBy[msg.sender][stakingDate] + rewardAmountClaimed;

        IERC20(s_rewardToken).safeTransferFrom(s_rewarder, msg.sender, rewardAmountClaimed);
        emit RewardTokenClaimed(msg.sender, _indexStakingDate, rewardAmountClaimed);

    }

    /**
     * @dev Getter for 'stakingToken'
     */
    function getStakingToken() public view returns(address) {
        return address(s_stakingToken);
    }

    /**
     * @dev Getter for 'rewardToken'
     */
    function getRewardToken() public view returns(address) {
        return address(s_rewardToken);
    }

   function getFinishedAt() public view returns(uint) {
        return s_finishedAt;
    }

    /**
     * @dev Getter for 'rewardRate1'
     */
    function getRewardRate1() public view returns(uint16) {
        return s_rewardRate1;
    }

    /**
     * @dev Getter for 'rewardRate2'
     */
    function getRewardRate2() public view returns(uint16) {
        return s_rewardRate2;
    }

    /**
     * @dev Getter for 'rewardRate2'
     */
    function getRewardRate3() public view returns(uint16) {
        return s_rewardRate3;
    }

    /**
     * @dev Getter for 'amountStakedBy' giving staker address
     */
    function getAmountStakedBy(address _staker) public view returns (uint[] memory){
        return s_stakingDatesOf[_staker];
    }

    /**
     * @dev Getter for 'stakingDatesOf'
     */
    function getStakingDatesOf(address _staker) public view returns (uint[] memory){
        return s_stakingDatesOf[_staker];
    }

    /**
     * @dev Getter for 'stakingDateOf' giving indexStakingDate
     */
    function getStakingDateOf(address _staker, uint16 _indexStakingDate) public view returns (uint){
        return s_stakingDatesOf[_staker][_indexStakingDate];
    }

    function setRewardRate1(uint16 _rewardRate1) public onlyOwner() {
        s_rewardRate1 = _rewardRate1;
        s_hourlyRewardRate1 = (s_rewardRate1 / HOURS_IN_ONE_YEAR) * DECIMALS_HOURLY_REWARD_RATE;
    }

    function setRewardRate2(uint16 _rewardRate2) public onlyOwner() {
        s_rewardRate2 = _rewardRate2;
        s_hourlyRewardRate2 = (s_rewardRate2 / HOURS_IN_ONE_YEAR) * DECIMALS_HOURLY_REWARD_RATE;
    }

    function setRewardRate3(uint16 _rewardRate3) public onlyOwner() {
        s_rewardRate3 = _rewardRate3;
        s_hourlyRewardRate3 = (s_rewardRate3 / HOURS_IN_ONE_YEAR) * DECIMALS_HOURLY_REWARD_RATE;
    }
}