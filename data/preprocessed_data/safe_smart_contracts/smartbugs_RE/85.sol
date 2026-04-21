

pragma solidity ^0.5.9;


interface ERC20 {
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function increaseApproval (address _spender, uint _addedValue) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
}



pragma solidity ^0.5.9;


interface NanoLoanEngine {
    enum Status { initial, lent, paid, destroyed }
    function rcn() external returns (ERC20);
    function getTotalLoans() external view returns (uint256);
    function pay(uint index, uint256 _amount, address _from, bytes calldata oracleData) external returns (bool);
    function cosign(uint index, uint256 cost) external returns (bool);
    function getCreator(uint index) external view returns (address);
    function getDueTime(uint index) external view returns (uint256);
    function getDuesIn(uint index) external view returns (uint256);
    function getPendingAmount(uint index) external returns (uint256);
    function getStatus(uint index) external view returns (Status);
}



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



pragma solidity ^0.5.9;


