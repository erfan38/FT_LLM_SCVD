pragma solidity ^0.4.25;

contract Incrementor {
    uint256 public count;

    function increment() public {
        count++;
    }
}
