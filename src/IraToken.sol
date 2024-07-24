// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {ERC20Pausable} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {AddressZeroError} from "./IraStakingErrors.sol";

contract IraToken is ERC20, ERC20Pausable, Ownable {

    constructor(address tokenOwner) ERC20("InRealArt", "IRA") Ownable(tokenOwner) payable
    {
        if (tokenOwner == address(0)) revert AddressZeroError();
        uint totalSupply = 100000000 * 10 ** decimals();
        _mint(msg.sender, totalSupply);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // The following functions are overrides required by Solidity.
    function _update(address from, address to, uint256 value) internal  override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}