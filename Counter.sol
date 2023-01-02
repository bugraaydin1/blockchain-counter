// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Counter {
    uint public count;

    function increase() external {
        count++;
    }

    function decrease() external {
        require(count > 0, "count should be greater than zero");
        count--;
    }
    
    function increaseBy(uint value) external {
        count += value;
    }

    function decreaseBy(uint value) external {
        require(count >= value, "count should be greater than decreaseBy value");
        count -= value;
    }

    function resetCounter () external {
        count = 0;
    } 

}
