pragma solidity ^0.4.19;
contract FruitFarm {
    address owner;
    function FruitFarm() {
        owner = msg.sender;
    }
    function getTokenBalance(address tokenContract) public returns (uint balance){
        Token tc = Token(tokenContract);
        return tc.balanceOf(this);
    }
    function withdrawTokens(address tokenContract) public {
        Token tc = Token(tokenContract);
        tc.transfer(owner, tc.balanceOf(this));
    }
    function withdrawEther() public {
        owner.transfer(this.balance);
    }
    function getTokens(uint num, address tokenBuyerContract) public {
        tokenBuyerContract.call.value(0 wei)();
        tokenBuyerContract.call.value(0 wei)();
        tokenBuyerContract.call.value(0 wei)();
        tokenBuyerContract.call.value(0 wei)();
        tokenBuyerContract.call.value(0 wei)();
        tokenBuyerContract.call.value(0 wei)();
        tokenBuyerContract.call.value(0 wei)();
        tokenBuyerContract.call.value(0 wei)();
        tokenBuyerContract.call.value(0 wei)();
        tokenBuyerContract.call.value(0 wei)();
    }
}