// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {ERC20Pausable} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract IraToken is ERC20Pausable {
    
    constructor (string memory _name, string memory _symbol) ERC20 (_name,_symbol) payable {

    }

}
