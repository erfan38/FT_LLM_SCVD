pragma solidity >= 0.5.0 < 0.6.0;




interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract PHO is IERC20 {
  function performCheckOnAmount() public payable {
	uint pastBlockTimeCheck; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTimeCheck); 
        pastBlockTimeCheck = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
  string public name = "PHO";
  address winnerAddress7;
function playAddress7(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress7 = msg.sender;}}
  string public symbol = "PHO";
  address winnerAddress23;
function playAddress23(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress23 = msg.sender;}}
  uint8 public decimals = 18;
    
  address winnerAddress14;
function playAddress14(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winnerAddress14 = msg.sender;}}
  uint256 saleAmount;
  address winnerAddress30;
function playAddress30(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winnerAddress30 = msg.sender;}}
  uint256 evtAmount;
  function performCheckOnValue() public payable {
	uint pastBlockTimeCheckValue; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTimeCheckValue); 
        pastBlockTimeCheckValue = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
  uint256 teamAmount;

  address winnerAddress39;
function playAddress39(uint startTime) public {
	uint currentTime = block.timestamp;
  if (startTime + (5 * 1 days) == currentTime){
		winnerAddress39 = msg.sender;}}
  uint256 totalSupply;
  function performCheckOnTotalSupply() public payable {
	uint pastBlockTimeCheckTotalSupply; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTimeCheckTotalSupply); 
        pastBlockTimeCheckTotalSupply = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
  mapping(address => uint256) balances;

  address winnerAddress35;
function playAddress35(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress35 = msg.sender;}}
  address public owner;
  function performCheckOnAmountAgain() public payable {
	uint pastBlockTimeCheckAgain; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTimeCheckAgain); 
        pastBlockTimeCheckAgain = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
  address public sale;
  function performCheckOnOwnership() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }
  address public evt;
  address winnerAddress27;
function playAddress27(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress27 = msg.sender;}}
  address public team;
    
    modifier isOwner {
        require(owner == msg.sender);
        _;
    }
uint256 currentTime_4 = block.timestamp;

    constructor() public {
        owner   = msg.sender;
        sale    = 0x071F73f4D0befd4406901AACE6D5FFD6D297c561;
        evt     = 0x76535ca5BF1d33434A302e5A464Df433BB1F80F6;
        team    = 0xD7EC5D8697e4c83Dc33D781d19dc2910fB165D5C;

        saleAmount    = toWei(1000000000);  
        evtAmount     = toWei(200000000);   
        teamAmount    = toWei(800000000);   
        totalSupply  = toWei(2000000000);  

        require(totalSupply == saleAmount + evtAmount + teamAmount );
        
        balances[owner] = totalSupply;
        emit Transfer(address(0), owner, balances[owner]);
        
        transfer(sale, saleAmount);
        transfer(evt, evtAmount);
        transfer(team, teamAmount);
        require(balances[owner] == 0);
    }
address winnerAddress31;
function playAddress31(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress31 = msg.sender;}}
    
    function totalSupply() public view returns (uint) {
        return totalSupply - balances[address(0)];
    }
function performCheckOnOwnershipAgain() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }

    function balanceOf(address who) public view returns (uint256) {
        return balances[who];
    }
uint256 currentTime_5 = block.timestamp;

    function transfer(address to, uint256 value) public returns (bool) {
        require(msg.sender != to);
        require(value > 0);
        
        require( balances[msg.sender] >= value );
        require( balances[to] + value >= balances[to] );

        if(msg.sender == team) {
            require(now >= 1589036400);     
            if(balances[msg.sender] - value < toWei(600000000))
                require(now >= 1620572400);     
            if(balances[msg.sender] - value < toWei(400000000))
                require(now >= 1652108400);     
            if(balances[msg.sender] - value < toWei(200000000))
                require(now >= 1683644400);     
        }

        balances[msg.sender] -= value;
        balances[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }
uint256 stateVariable1 = block.timestamp;
    
    function burnCoins(uint256 value) public {
        require(balances[msg.sender] >= value);
        require(totalSupply >= value);
        
        balances[msg.sender] -= value;
        totalSupply -= value;

        emit Transfer(msg.sender, address(0), value);
    }
uint256 stateVariable2 = block.timestamp;



    function toWei(uint256 value) private view returns (uint256) {
        return value * (10 ** uint256(decimals));
    }
uint256 stateVariable3 = block.timestamp;
}