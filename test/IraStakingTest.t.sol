// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IraStaking} from "../src/IraStaking.sol";
import {IraToken} from "../src/IraToken.sol";
import {DeployIraStaking} from "../script/DeployIraStaking.s.sol";
import {BalanceSmartContractError, BalanceStakingTokenError, ClaimError, AmountStakedZeroError} from "../src/IraStakingErrors.sol";

contract IraStakingTest is Test {
    IraToken iraToken;
    DeployIraStaking deployIraStaking;
    IraStaking iraStaking;
    address IRA_TOKEN_OWNER = makeAddr("IRA_TOKEN_OWNER");
    address STAKER1 = makeAddr("STAKER1");
    address STAKER2 = makeAddr("STAKER2");
    address REWARDER = makeAddr("REWARDER");
    uint96 private constant TOTAL_SUPPLY = 100000000000000000000000000;

    function setUp() public {
        iraToken = new IraToken(IRA_TOKEN_OWNER);
        deployIraStaking = new DeployIraStaking();
        iraStaking = deployIraStaking.run(
            address(iraToken),
            address(iraToken),
            REWARDER
        );
    }

    /**
     * Test that when the IraStaking SC is deployed with a zero address for staking token
     * It will revert with the appropriate error
     */
    function testIraStakingDeploymentStakingTokenCanNotBeNull() public {}

    /**
     * Test that when the IraStaking SC is deployed with a zero address for Reward token
     * It will revert with the appropriate error
     */
    function testIraStakingDeploymentRewardTokenCanNotBeNull() public {}

    /**
     * Test that when the IraStaking SC is deployed with a zero address for rewarder address
     * It will revert with the appropriate error
     */
    function testIraStakingDeploymentRewarderAddressCanNotBeNull() public {}

    /**
     * @dev Test that the total supply is correct
     */
    function testIraTokenTotalSupply() public view {
        assertEq(iraToken.totalSupply(), TOTAL_SUPPLY);
    }

    /**
     * @dev Test that the balance of IRA tokens of the owner is correct
     */
    function testBalanceOfIraTokenOwner() public view {
        assertEq(iraToken.balanceOf(IRA_TOKEN_OWNER), TOTAL_SUPPLY);
    }

    /**
     * @dev Test that the balance of IRA tokens of the owner is correct
     */
    function testBalanceOfStakerAfterOwnerIraSending() public {
        vm.startPrank(IRA_TOKEN_OWNER);
        iraToken.transfer(STAKER1, 1000000000000);
        vm.stopPrank();
        assertEq(iraToken.balanceOf(STAKER1), 1000000000000);
    }

    /**
     * @dev Test a staker can not stake staking tokens if he does not own at least the amount of tokens
     * he wants to stake
     */
    function testAStakerCannotStakeIfHeDoNotOwnAnyStakingToken() public {
        vm.startPrank(STAKER1);
        iraToken.approve(address(iraStaking), 1000);
        vm.expectRevert(BalanceStakingTokenError.selector);
        iraStaking.stake(1000);
        vm.stopPrank();
    }

    /**
     * @dev Test a staker can stake staking tokens if he owns tokens and check his balance after staking
     * If he owns 10 tokens and stakes 1 token, his balance must be 9 staking tokens
     */
    function testAStakerCanStakeAndCheckStakerBalanceAfterStaking() public {
        vm.startPrank(IRA_TOKEN_OWNER);
        iraToken.transfer(STAKER1, 10);
        vm.stopPrank();

        vm.startPrank(STAKER1);
        iraToken.approve(address(iraStaking), 9);
        iraStaking.stake(9);
        vm.stopPrank();
        assertEq(iraToken.balanceOf(STAKER1), 1);
    }

    /**
     * @dev Test balance of staking smart contact after staking
     * If The balance of the SC is X staking tokens so after a user stakes 10 tokens, the balance must be
     * balance = X + 10 tokens
     * Test the function with 1 staker
     */
    function testAStakerCanStakeAndChecksmartContractBalanceAfterStaking()
        public
    {
        vm.startPrank(IRA_TOKEN_OWNER);
        iraToken.transfer(STAKER1, 10);
        vm.stopPrank();

        vm.startPrank(STAKER1);
        iraToken.approve(address(iraStaking), 10);
        iraStaking.stake(10);
        vm.stopPrank();
        assertEq(iraToken.balanceOf(IRA_TOKEN_OWNER), TOTAL_SUPPLY - 10);
    }

    /**
     * @dev Test balance of staking smart contact after staking
     * If The balance of the SC is X staking tokens so after a user stakes 10 tokens and another user stake 5 tokens, the balance must be
     * balance = X + 15 tokens
     * So, Test the function with 2 stakers
     */
    function testAStakerCanStakeAndChecksmartContractBalanceAfterStaking2()
        public
    {
        vm.startPrank(IRA_TOKEN_OWNER);
        iraToken.transfer(STAKER1, 10);
        iraToken.transfer(STAKER2, 5);
        vm.stopPrank();

        vm.startPrank(STAKER1);
        iraToken.approve(address(iraStaking), 10);
        iraStaking.stake(10);
        vm.stopPrank();

        vm.startPrank(STAKER2);
        iraToken.approve(address(iraStaking), 5);
        iraStaking.stake(5);
        vm.stopPrank();
        assertEq(iraToken.balanceOf(IRA_TOKEN_OWNER), TOTAL_SUPPLY - 15);
    }

    /**
     * @dev Test state variables before staking
     */
    function testAmountStakedByAfterStaking() public {
        vm.startPrank(IRA_TOKEN_OWNER);
        iraToken.transfer(STAKER1, 2000);
        vm.stopPrank();

        vm.startPrank(STAKER1);
        iraToken.approve(address(iraStaking), 1000);
        iraStaking.stake(1000);
        vm.stopPrank();
        assertEq(iraStaking.getAmountStakedBy(STAKER1, block.timestamp), 1000);
        assertEq(iraStaking.getStakingDateOf(STAKER1, 0), block.timestamp);
        console.log(iraStaking.getStakingDateOf(STAKER1, 0), block.timestamp);

        vm.startPrank(STAKER1);
        iraToken.approve(address(iraStaking), 500);
        iraStaking.stake(500);
        vm.stopPrank();
        console.log(block.timestamp);
        assertEq(iraStaking.getAmountStakedBy(STAKER1, block.timestamp), 500);
        assertEq(iraStaking.getStakingDateOf(STAKER1, 1), block.timestamp);
    }

    /**
     * @dev Do the same test than above but with 2 different staking dates.
     * Exemple : A staker stake 1000 tokens now and 500 tokens tomorrow.
     * Check that the mapping have the good values
     * (Use vm.warp)
     */
    function testStateVariablesBeforeStaking2() public {
        vm.startPrank(IRA_TOKEN_OWNER);
        iraToken.transfer(STAKER1, 1500);

        vm.stopPrank();
        vm.startPrank(STAKER1);
        iraToken.approve(address(iraStaking), 1000);
        iraStaking.stake(1000);
        vm.stopPrank();
        assertEq(iraStaking.getAmountStakedBy(STAKER1, block.timestamp), 1000);
        assertEq(iraStaking.getStakingDateOf(STAKER1, 0), block.timestamp);

        vm.startPrank(STAKER1);
        uint256 OneDayInTheFuture = block.timestamp + 2 days;
        vm.warp(OneDayInTheFuture);
        iraToken.approve(address(iraStaking), 500);
        iraStaking.stake(500);
        vm.stopPrank();
        assertEq(iraStaking.getAmountStakedBy(STAKER1, OneDayInTheFuture), 500);
        assertEq(iraStaking.getStakingDateOf(STAKER1, 1), OneDayInTheFuture);
    }

    /**
     * @dev Test balance of staker after staking.
     * Normally if a staker owns 1000 tokens and stake 400 tokens,
     * after staking his balance must be 600 tokens.
     * Check this
     */
    function testStakerBalanceAfterStaking() public {
        vm.startPrank(IRA_TOKEN_OWNER);
        iraToken.transfer(STAKER1, 1000);

        vm.stopPrank();
        vm.startPrank(STAKER1);
        iraToken.approve(address(iraStaking), 400);
        iraStaking.stake(400);
        vm.stopPrank();
        assertEq(iraToken.balanceOf(STAKER1), 600);
    }

    /**
     * @dev Test that if a staker staked an amount of tokens at a specific date,
     * he can not claim his reward before 3 months.
     * Check that the SC revert with the appropriate error
     */
    function testStakerCanNotClaimBefore3Months() public {
        vm.startPrank(IRA_TOKEN_OWNER);
        iraToken.transfer(STAKER1, 10);
        vm.stopPrank();

        vm.startPrank(STAKER1);
        iraToken.approve(address(iraStaking), 10);
        iraStaking.stake(10);
        vm.stopPrank();

        vm.startPrank(STAKER1);
        vm.expectRevert(ClaimError.selector);
        iraStaking.claimReward(0);
        vm.stopPrank();
    }

    /**
     * @dev
     * Check that if a user owns 1000 tokens and wants to stake an amount greater than 1000,
     * it will revert with "BalanceStakingTokenError"
     */
    function testErrorOnStaking() public {
        //     vm.startPrank(IRA_TOKEN_OWNER);
        //     iraToken.transfer(STAKER1, 1000);
        //     vm.stopPrank();
        //     vm.startPrank(STAKER1);
        //     iraToken.approve(address(iraStaking), 1001);
        //     vm.expectRevert(ERC20InsufficientBalance.selector);
        //     iraStaking.stake(1001);
        //     vm.stopPrank();
    }

    /**
     * @dev
     * Check that if a user owns 1000 tokens and wants to stake an amount equal to 0,
     * it will revert with "AmountStakedZeroError"
     */
    function testErrorOnStaking2() public {
        vm.startPrank(IRA_TOKEN_OWNER);
        iraToken.transfer(STAKER1, 1000);
        vm.stopPrank();

        vm.startPrank(STAKER1);
        iraToken.approve(address(iraStaking), 1000);
        vm.expectRevert(AmountStakedZeroError.selector);
        iraStaking.stake(0);
        vm.stopPrank();
    }

    /**
     * @dev Do the following test.
     * A staker stakes 1000 tokens now.
     * This will add 1 entry in the 2 mappings : s_amountStakedBy and s_stakingDatesOf
     * Then he stakes another 500 tokens tomorrow. It will add others entries in these 2 mappings
     * Check that 3 months after the 1st staking date, he can unstake his first amount (1000) but can not unstake the second amount (500)
     * ==> Revert with "ClaimError" error
     */
    function testStakerCanNotClaimBefore3Months2() public {
        vm.startPrank(IRA_TOKEN_OWNER);
        iraToken.transfer(STAKER1, 1500);
        vm.stopPrank();

        vm.startPrank(STAKER1);
        iraToken.approve(address(iraStaking), 1000);
        iraStaking.stake(1000);
        vm.stopPrank();
        assertEq(iraStaking.getAmountStakedBy(STAKER1, block.timestamp), 1000);
        assertEq(iraStaking.getStakingDateOf(STAKER1, 0), block.timestamp);

        vm.startPrank(STAKER1);
        uint256 OneDayInTheFuture = block.timestamp + 1 days;
        vm.warp(OneDayInTheFuture);

        iraToken.approve(address(iraStaking), 500);
        iraStaking.stake(500);
        vm.stopPrank();
        assertEq(iraStaking.getAmountStakedBy(STAKER1, block.timestamp), 500);
        assertEq(iraStaking.getStakingDateOf(STAKER1, 1), block.timestamp);

        vm.startPrank(STAKER1);
        uint256 OneMonthInTheFuture = block.timestamp + 91 days;
        vm.warp(OneMonthInTheFuture);
        iraStaking.claimReward(0);
        vm.expectRevert(ClaimError.selector);
        iraStaking.claimReward(1);
        vm.stopPrank();
    }

    /**
     * @dev Test that if a staker claims his reward for an staking entry AND the rewarder does not own the appropriate amount of reward tokens,
     * it will revert with "BalanceRewarderError"
     *
     */
    function testClaimingBalanceRewarderError() public {}

    /**
     * @dev Test that if a staker claims his reward for an staking entry, the calculated reward is added to his balance
     * A prerequisite is that the 'rewarder' must owns reward tokens to perform that
     */
    function testBalanceAfterClaimingRewards() public {}

    /**
     * @dev Test that if a staker claims his reward for an staking entry, the balance of the rewarder is decreased by the amount of calculated reward tokens
     * A prerequisite is that the 'rewarder' must owns reward tokens to perform that
     */
    function testBalanceAfterClaimingRewards2() public {}

    /**
     * @dev
     * Prerequisites :
     * 1) Rewarder must onws enough reward tokens
     * 2) Staker can claim rewards so after at least 3 months of staking
     *
     * Test that if a staker wants to claim his rewards, it will update the state variable mapping "s_amountRewardClaimedBy" with appropriate value
     */
    function testStateVariablesAfterClaimingRewards1() public {}

    /**
     * @dev
     * Same test than above but with 2 claiming at 2 different times
     *
     * Test that if a staker wants to claim his rewards, it will update the state variable mapping "s_amountRewardClaimedBy" with appropriate value
     */
    function testStateVariablesAfterClaimingRewards2() public {}

    /**
     * @dev When a staker stakes a specific amount of tokens, the Smart contract can compute an hourly rate of earning (based on the rules we defined)
     * Test that after a staker claims his reward for a specific stalking entry the amount of rewards is correct according to this hourly rate
     */
    function testClaimingRewardIsCorrect() public {}

    /**
     * @dev Do the same test as above but with 1 claiming today and 1 claiming tomorrow.
     * (The first claiming must reward the staker with a big amount and the 2nd claiming must reward the staker with a tiny amount because he already claimed once)
     * Check that claim rewards are with right calculated values
     *
     */
    function testClaimingRewardIsCorrect3() public {}

    /**
     * @dev Do the same test as above by checkiing the state variable mapping "s_amountRewardClaimedBy" with appropriate value
     *
     */
    function testClaimingRewardIsCorrect2() public {}
}
