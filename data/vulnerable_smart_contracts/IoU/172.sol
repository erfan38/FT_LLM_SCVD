contract Marketplace {
 mapping(uint256 => uint256) public itemPrices;

 function calculateDiscount(uint256 itemId, uint256 discountPercent) public view returns (uint256) {
 uint256 price = itemPrices[itemId];
 uint256 discount = price * discountPercent / 100;
 return price - discount;
 }
}