pragma solidity ^0.8.0;
}


interface iFactory {

event InstanceCreated(address indexed instance, address indexed creator, string initABI, bytes initData);

function create(bytes calldata initData) external returns (address instance);