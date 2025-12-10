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
uint256 timestamp;
}

function safeFunction7() public{
uint8 variable7=0;
variable7 = variable7 - 10;
}