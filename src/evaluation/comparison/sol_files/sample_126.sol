pragma solidity ^0.8.0;
}






interface Upgrader {





function upgrade(address _wallet, address[] _toDisable, address[] _toEnable) external;