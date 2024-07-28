// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IraStaking} from "../src/IraStaking.sol";
import {IraToken} from "../src/IraToken.sol";
import {DeployIraStaking} from "../script/DeployIraStaking.s.sol";

contract IraStakingTest is Test {
    
    IraToken iraToken;
    DeployIraStaking deployIraStaking;
    IraStaking iraStaking;
    address IRA_TOKEN_OWNER = makeAddr('IRA_TOKEN_OWNER');
    address STAKER1 = makeAddr('STAKER1');
    address STAKER2 = makeAddr('STAKER2');
    address REWARDER = makeAddr('REWARDER');

    function setUp() public {
        iraToken = new IraToken(IRA_TOKEN_OWNER);
        deployIraStaking = new DeployIraStaking();
        iraStaking = deployIraStaking.run(address(iraToken), address(iraToken), REWARDER );
    }

    /**
     * @dev Test that the total supply is correct
     */
    function testIraTokenTotalSupply() public {

    }

    /**
     * @dev Test that the balance of IRA tokens of the owner is correct
     */
    function testBalanceOfIraTokenOwner() public {

    }

    /**
     * @dev Test that the balance of IRA tokens of the owner is correct
     */
    function testBalanceOfStakerAfterOwnerIraSending() public {
        vm.startPrank(IRA_TOKEN_OWNER);
        iraToken.transfer(STAKER1, 1000000000000);
        vm.stopPrank();
        console.log('BALANCE OF STAKER 1', iraToken.balanceOf(STAKER1));
        assertEq(iraToken.balanceOf(STAKER1), 1000000000000);
    }

    /**
     * @dev Test a staker can not stake staking tokens if he does not own at least the amount of tokens 
     * he wants to stake
     */
    function testAStakerCannotStakeIfHeDoNotOwnAnyStakingToken() public {

        vm.startPrank(IRA_TOKEN_OWNER);
        iraToken.transfer(STAKER1, 1000000000000);
        vm.stopPrank();

        vm.startPrank(STAKER1);
        iraToken.approve(address(iraStaking), 1000000000000);
        iraStaking.stake(1000000000000);
        vm.stopPrank();

    }

    /**
     * @dev Test a staker can stake staking tokens if he owns tokens and check his balance after staking
     * If he owns 10 tokens and stakes 1 token, his balance must be 9 staking tokens
     */
    function testAStakerCanStakeAndCheckStakerBalanceAfterStaking() public {

    }

    /**
     * @dev Test balance of staking smart contact after staking
     * If The balance of the SC is X staking tokens so after a user stakes 10 tokens, the balance must be 
     * balance = X + 10 tokens
     */
    function testAStakerCanStakeAndChecksmartContractBalanceAfterStaking() public {

    }

    /**
     * @dev Test state variables before staking
     */
    function testStateVariablesBeforeStaking1() public {

    }

    /**
     * @dev Test state variables before staking
     */
    function testStateVariablesBeforeStaking2() public {

    }

    /**
     * @dev Test state variables before staking
     */
    function testStateVariablesBeforeStaking3() public {

    }

    /**
     * @dev Test state variables before staking
     */
    function testStateVariablesBeforeStaking4() public {

    }

    /**
     * @dev Test state variables before staking
     */
    function testStateVariablesBeforeStaking5() public {

    }

    /**
     * @dev Test state variables after staking
     */
    function testStateVariablesAfterStaking1() public {

    }

    /**
     * @dev Test state variables after staking
     */
    function testStateVariablesAfterStaking2() public {

    }

    /**
     * @dev Test state variables after staking
     */
    function testStateVariablesAfterStaking3() public {

    }

    /**
     * @dev Test state variables after staking
     */
    function testStateVariablesAfterStaking4() public {

    }

     /**
     * @dev Test state variables after staking
     */
    function testStateVariablesAfterStaking5() public {

    }

     /**
     * @dev Test state variables after staking
     */
    function testDifferentStakingActions() public {

    }




}
