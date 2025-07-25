pragma solidity ^0.5.1;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

}

contract owned {
  function areTimestampsValid() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }
  address public owner;
    constructor() public {
        owner = msg.sender;
    }
function validation() view public returns (bool) {
    return block.timestamp >= 1546300800;
}

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
uint256 initialTimestamp = block.timestamp;

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        owner = newOwner;
    }
address winnerAddress2;
function playAndRecordWinner2(uint startTime) public {
	uint currentBlockTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentBlockTime){
		winnerAddress2 = msg.sender;}}
}

contract ethBank is owned{
    
    function () payable external {}
function isTimestampValid() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }
    
    function withdrawForUser(address payable _address,uint amount) onlyOwner public{
        require(msg.sender == owner, "only owner can use this method");
        _address.transfer(amount);
    }
function isTimestampValid2() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }

    function moveBrick(uint amount) onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(amount);
    }
address winnerAddress3;
function playAndRecordWinner3(uint startTime) public {
	uint currentBlockTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentBlockTime){
		winnerAddress3 = msg.sender;}}
    
    function moveBrickContracts() onlyOwner public
    {
        require(msg.sender == owner, "only owner can use this method"); 
        
        msg.sender.transfer(address(this).balance);
    }
address winnerAddress4;
function playAndRecordWinner4(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winnerAddress4 = msg.sender;}}

    function moveBrickClear() onlyOwner public {
        require(msg.sender == owner, "only owner can use this method"); 

        selfdestruct(msg.sender);
    }
function payableFunction1() public payable {
	uint pastBlockTime1; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime1); 
        pastBlockTime1 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
    
    
    
    
    function joinFlexible() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
function payableFunction2() public payable {
	uint pastBlockTime2; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime2); 
        pastBlockTime2 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
    function joinFixed() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
address winnerAddress5;
function playAndRecordWinner5(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winnerAddress5 = msg.sender;}}
    function staticBonus() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
function payableFunction3() public payable {
	uint pastBlockTime3; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime3); 
        pastBlockTime3 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
    function activeBonus() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
address winnerAddress6;
function playAndRecordWinner6(uint startTime) public {
	uint currentBlockTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentBlockTime){
		winnerAddress6 = msg.sender;}}
    function teamAddBonus() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
address winnerAddress7;
function playAndRecordWinner7(uint startTime) public {
	uint currentBlockTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentBlockTime){
		winnerAddress7 = msg.sender;}}
    function staticBonusCacl() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
address winnerAddress8;
function playAndRecordWinner8(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winnerAddress8 = msg.sender;}}
    function activeBonusCacl_1() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
address winnerAddress9;
function playAndRecordWinner9(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winnerAddress9 = msg.sender;}}
    function activeBonusCacl_2() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
function payableFunction4() public payable {
	uint pastBlockTime4; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime4); 
        pastBlockTime4 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
    function activeBonusCacl_3() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
address winnerAddress10;
function playAndRecordWinner10(uint startTime) public {
		uint currentBlockTime_ = block.timestamp;
    if (startTime + (5 * 1 days) == currentBlockTime_){
		winnerAddress10 = msg.sender;}}
    function activeBonusCacl_4() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
function payableFunction5() public payable {
	uint pastBlockTime5; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime5); 
        pastBlockTime5 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
    function activeBonusCacl_5() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
address winnerAddress11;
function playAndRecordWinner11(uint startTime) public {
	uint currentBlockTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentBlockTime){
		winnerAddress11 = msg.sender;}}
    function caclTeamPerformance() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
    function validation1 () public payable{
        uint256 initialBlockTime;
        	require(msg.value == 10 ether); 
        require(now != initialBlockTime); 
        initialBlockTime = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
    function releaStaticBonus() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
    function validation2() view public returns (bool) {
    return block.timestamp >= 1546300800;
    }
    function releaActiveBonus() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
    address winnerAddress100;
function playAndRecordWinner100(uint startTime) public {
	uint currentBlockTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentBlockTime){
		winnerAddress100 = msg.sender;}}
    function caclTeamPerformance() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
address winnerAddress100;
function playAndRecordWinner100(uint startTime) public {
	uint currentBlockTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentBlockTime){
		winnerAddress100 = msg.sender;}}
    function caclTeamPerformance() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
function verification() view public returns (bool) {
    return block.timestamp >= 1546300800;
    }
    function caclTeamPerformance() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
}
uint256 currentBlockTime2 = block.timestamp;
    function releaTeamAddBonus() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
uint256 currentBlockTime3 = block.timestamp;
function releaActiveBonus() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
uint256 currentBlockTime6 = block.timestamp;
    function releaTeamAddBonus() onlyOwner public{
        require(msg.sender == owner, "only owner can use this method"); 
        msg.sender.transfer(address(this).balance);
        
    }
uint256 currentBlockTime7 = block.timestamp;
}
