// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {IraToken} from "../src/IraToken.sol";

contract DeployIraToken is Script {

    string private tokenName = 'InRealArt';
    string private tokenSymbol = 'IRA';

     function run() external returns (IraToken) {
        vm.startBroadcast();
        IraToken iraToken = new IraToken(tokenName, tokenSymbol);
        vm.stopBroadcast();
        return iraToken;
    }
   
}