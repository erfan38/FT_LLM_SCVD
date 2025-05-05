pragma solidity ^0.5.9;


contract Wallet is Ownable {
    function execute(
        address payable _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner returns (bool, bytes memory) {
        return _to.call.value(_value)(_data);
    }
}

interface NanoLoanEngine {
    function transferFrom(address from, address to, uint256 index) external returns (bool);
}
