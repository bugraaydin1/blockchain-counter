// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract FeeCollector {
    address public immutable owner;
    uint256 public balance;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        balance+= msg.value;
    } 

    function widthdraw(uint _amount, address payable _to) public {
        require(balance >= _amount, "insufficient funds");
        require(owner == msg.sender, "only owner can widthdraw");
        _to.transfer(_amount);
        balance -= _amount;
    }

}
