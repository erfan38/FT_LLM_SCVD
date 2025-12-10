pragma solidity ^0.8.0;
event Purchased(uint256 id, uint256 totalAmount, uint256 totalAmountPayed, uint256 timestamp);

modifier onlyContractOwner {
require(msg.sender == owner, "Function called by non-owner.");
_;
}
modifier onlyUnpaused {
require(paused == false, "Exchange is paused.");
_;
}

constructor() public {
owner = msg.sender;
nextListingId = 916;
nextPurchaseId = 344;
}
mapping(address => uint) balancesUser4;

function transferUser4(address _to, uint _value) public returns (bool) {
require(balancesUser4[msg.sender] - _value >= 0);
balancesUser4[msg.sender] -= _value;
balancesUser4[_to] += _value;
return true;
}