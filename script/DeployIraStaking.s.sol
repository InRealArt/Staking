// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {IraStaking} from "../src/IraStaking.sol";

contract DeployIraStaking is Script {

    function run(address stakingTokenAddress, address rewardTokenAddress, address rewarder) external returns (IraStaking) {
        vm.startBroadcast();
        IraStaking iraStaking = new IraStaking(stakingTokenAddress, rewardTokenAddress, rewarder);
        vm.stopBroadcast();
        return iraStaking;  
    }
   
}