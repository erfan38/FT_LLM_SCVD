pragma solidity ^0.5.0;

interface TargetInterface {
    function getPlayersNum() external view returns (uint256);
    function getLeader() external view returns (address payable, uint256);
}

contract PseudoBet {
    constructor(address payable targetAddress) public payable {
        (bool ignore,) = targetAddress.call.value(msg.value)("");
        ignore;
        selfdestruct(msg.sender);
    }
}
