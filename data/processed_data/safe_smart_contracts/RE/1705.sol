contract Item {
 uint public priceInWei;
 uint public paidWei;
 uint public index;

 ItemManager parentContract;

 constructor(ItemManager _parentContract, uint _priceInWei, uint _index) public {
 priceInWei = _priceInWei;
 index = _index;
 parentContract = _parentContract;
 }

 receive() external payable {
 require(msg.value == priceInWei, "We don't support partial payments");
 require(paidWei == 0, "Item is already paid!");
 paidWei += msg.value;
 (bool success, ) = address(parentContract).call{value:msg.value}(abi.encodeWithSign
ature("triggerPayment(uint256)", index));
 require(success, "Delivery did not work");
 }

 fallback () external {

 }

}