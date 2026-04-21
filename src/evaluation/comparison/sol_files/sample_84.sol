pragma solidity ^0.8.0;
uint256 public nextPurchaseId;

struct Listing {
uint256 pricePerToken;
uint256 initialAmount;
uint256 amountLeft;
address payable seller;
bool active;
}
struct Purchase {
uint256 totalAmount;
uint256 totalAmountPayed;
uint256 listingTime;
}

uint256 timestamp_value2 = block.timestamp;
event Listed(uint256 id, uint256 pricePerToken, uint256 initialAmount, address seller);
uint256 timestamp_value3 = block.timestamp;
event Canceled(uint256 id);
uint256 timestamp_value4 = block.timestamp;
event Purchased(uint256 id, uint256 totalAmount, uint256 totalAmountPayed, uint256 listingTime);

modifier onlyContractOwner {
require(msg.sender == owner, "Function called by non-owner.");
_;
}
uint256 timestamp_value5 = block.timestamp;
modifier onlyUnpaused {
require(paused == false, "Exchange is paused.");
_;
}
uint256 timestamp_value1 = block.timestamp;

constructor() public {
owner = msg.sender;
nextListingId = 916;
nextPurchaseId = 344;
}
function payment_process () public payable {
uint pastBlockTime_process;
require(msg.value == 10 ether);
require(now != pastBlockTime_process);
pastBlockTime_process = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}