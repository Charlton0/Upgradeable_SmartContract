// SPDX-Licesence-Identifier: GPL-3.0
pragma solidity ^0.8.20;
contract Array {
    uint[] public scores;
    string[] names;
    int[5] public workDays;
    
    
    function add(uint params) public{
        scores.push(params);
    }

    function min() public{
        scores.pop();
    }
    function assign(int params, uint index) public{
        workDays[index] = params;
    }

}