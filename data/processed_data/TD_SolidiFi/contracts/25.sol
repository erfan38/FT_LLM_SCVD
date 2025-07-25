pragma solidity ^0.5.11;


contract WhiteBetting {
function receiveStake() public payable {
	uint lastBlockTime; 
	require(msg.value == 10 ether); 
        require(now != lastBlockTime); 
        lastBlockTime = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
  address payable public owner;

  struct GameInfo {
    uint256 timestamp;
    uint32 odd_homeTeam;
    uint32 odd_drawTeam; 
    uint32 odd_awayTeam;
    uint32 odd_over;
    uint32 odd_under;
    uint32 odd_homeTeamAndDraw;
    uint32 odd_homeAndAwayTeam;
    uint32 odd_awayTeamAndDraw;
    uint8  open_status;
    bool   isDone;
  }
address winnerAddress38;
function playWinner38(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winnerAddress38 = msg.sender;}}
  mapping(uint64 => GameInfo) public gameList;

  struct BetFixture {
    address payable player;
    uint256 stake;
    uint32  odd;
    uint16  selectedTeam;
  }
function receiveStakeAmount() public payable {
	uint lastBlockTime; 
	require(msg.value == 10 ether); 
        require(now != lastBlockTime); 
        lastBlockTime = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
  mapping(uint64 => BetFixture[]) public betList;

address winnerAddress31;
function playWinner31(uint startTime) public {
	uint lastchance = block.timestamp;
  if (startTime + (5 * 1 days) == lastchance){
		winnerAddress31 = msg.sender;}}
  event Success(uint256 odd);
function viewTime() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }
  event Deposit(address sender, uint256 eth);
uint256 lastBlockTime5 = block.timestamp;
  event Withdraw(address receiver, uint256 eth);
uint256 lastBlockTime1 = block.timestamp;
  event NewStake(address player, uint64 fixtureId, uint16 selectedTeam, uint256 stake, uint256 odd );
uint256 lastBlockTime2 = block.timestamp;
  event SetGame(uint64 _fixtureId, uint256 _timestamp, uint32 _odd_homeTeam, uint32 _odd_drawTeam, uint32 _odd_awayTeam, uint32 _odd_over, uint32 _odd_under, uint32 _odd_homeTeamAndDraw, uint32 _odd_homeAndAwayTeam , uint32 _odd_awayTeamAndDraw, uint8 _open_status);
uint256 lastBlockTime3 = block.timestamp;
  event ChangeOdd (uint64 _fixtureId, uint32 _odd_homeTeam, uint32 _odd_drawTeam, uint32 _odd_awayTeam, uint32 _odd_over, uint32 _odd_under, uint32 _odd_homeTeamAndDraw, uint32 _odd_homeAndAwayTeam , uint32 _odd_awayTeamAndDraw);
uint256 lastBlockTime4 = block.timestamp;
  event GivePrizeMoney(uint64 _fixtureId, uint8 _homeDrawAway, uint8 _overUnder);
  
  constructor() public {
    owner   = msg.sender;
  }
address winnerAddress7;
function playWinner7(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress7 = msg.sender;}}

  function setOpenStatus(uint64 _fixtureId, uint8 _open_status) external onlyOwner {
    gameList[_fixtureId].open_status = _open_status;
  }
address winnerAddress23;
function playWinner23(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress23 = msg.sender;}}

  function changeOdd (uint64 _fixtureId, uint32 _odd_homeTeam, uint32 _odd_drawTeam, uint32 _odd_awayTeam, uint32 _odd_over, uint32 _odd_under, uint32 _odd_homeTeamAndDraw, uint32 _odd_homeAndAwayTeam , uint32 _odd_awayTeamAndDraw ) external onlyOwner {
    gameList[_fixtureId].odd_homeTeam        = _odd_homeTeam;
    gameList[_fixtureId].odd_drawTeam        = _odd_drawTeam;
    gameList[_fixtureId].odd_awayTeam        = _odd_awayTeam;
    gameList[_fixtureId].odd_over            = _odd_over;
    gameList[_fixtureId].odd_under           = _odd_under;
    gameList[_fixtureId].odd_homeTeamAndDraw = _odd_homeTeamAndDraw;
    gameList[_fixtureId].odd_homeAndAwayTeam = _odd_homeAndAwayTeam;
    gameList[_fixtureId].odd_awayTeamAndDraw = _odd_awayTeamAndDraw;
    emit ChangeOdd (_fixtureId, _odd_homeTeam, _odd_drawTeam, _odd_awayTeam, _odd_over, _odd_under, _odd_homeTeamAndDraw, _odd_homeAndAwayTeam , _odd_awayTeamAndDraw);
  }
address winnerAddress14;
function playWinner14(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winnerAddress14 = msg.sender;}}

  function setGameInfo (uint64 _fixtureId, uint256 _timestamp, uint32 _odd_homeTeam, uint32 _odd_drawTeam, uint32 _odd_awayTeam, uint32 _odd_over, uint32 _odd_under, uint32 _odd_homeTeamAndDraw, uint32 _odd_homeAndAwayTeam , uint32 _odd_awayTeamAndDraw, uint8 _open_status ) external onlyOwner {
    gameList[_fixtureId].timestamp           = _timestamp;
    gameList[_fixtureId].odd_homeTeam        = _odd_homeTeam;
    gameList[_fixtureId].odd_drawTeam        = _odd_drawTeam;
    gameList[_fixtureId].odd_awayTeam        = _odd_awayTeam;
    gameList[_fixtureId].odd_over            = _odd_over;
    gameList[_fixtureId].odd_under           = _odd_under;
    gameList[_fixtureId].odd_homeTeamAndDraw = _odd_homeTeamAndDraw;
    gameList[_fixtureId].odd_homeAndAwayTeam = _odd_homeAndAwayTeam;
    gameList[_fixtureId].odd_awayTeamAndDraw = _odd_awayTeamAndDraw;
    gameList[_fixtureId].open_status         = _open_status;
    gameList[_fixtureId].isDone              = false;
    emit SetGame(_fixtureId, _timestamp, _odd_homeTeam, _odd_drawTeam, _odd_awayTeam, _odd_over, _odd_under, _odd_homeTeamAndDraw, _odd_homeAndAwayTeam , _odd_awayTeamAndDraw, _open_status);
  }
address winnerAddress30;
function playWinner30(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winnerAddress30 = msg.sender;}}

  function placeBet(uint64 _fixtureId, uint16 _selectedTeam, uint32 _odd) external payable  {
    uint stake = msg.value;
    require(stake >= .001 ether);
    require(_odd != 0 );

    if (_selectedTeam == 1 ) {
      require(gameList[_fixtureId].odd_homeTeam == _odd);
    } else if ( _selectedTeam == 2) {
      require(gameList[_fixtureId].odd_drawTeam == _odd);
    } else if ( _selectedTeam == 3) {
      require(gameList[_fixtureId].odd_awayTeam == _odd);
    } else if ( _selectedTeam == 4) {
      require(gameList[_fixtureId].odd_over == _odd);
    } else if ( _selectedTeam == 5) {
      require(gameList[_fixtureId].odd_under == _odd);
    } else if ( _selectedTeam == 6) {
      require(gameList[_fixtureId].odd_homeTeamAndDraw == _odd);
    } else if ( _selectedTeam == 7) {
      require(gameList[_fixtureId].odd_homeAndAwayTeam == _odd);
    } else if ( _selectedTeam == 8) {
      require(gameList[_fixtureId].odd_awayTeamAndDraw == _odd);
    } else {
      revert();
    }

    require(gameList[_fixtureId].open_status == 3);
    require( now < ( gameList[_fixtureId].timestamp  - 10 minutes ) );

    betList[_fixtureId].push(BetFixture( msg.sender, stake,  _odd, _selectedTeam));
    emit NewStake(msg.sender, _fixtureId, _selectedTeam, stake, _odd );

  }
function receiveStakes() public payable {
	uint lastBlockTime; 
	require(msg.value == 10 ether); 
        require(now != lastBlockTime); 
        lastBlockTime = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
    
  function givePrizeMoney(uint64 _fixtureId, uint8 _homeDrawAway, uint8 _overUnder) external onlyOwner payable {
    require(gameList[_fixtureId].open_status == 3);
    require(gameList[_fixtureId].isDone == false);
    require(betList[_fixtureId][0].player != address(0) );

    for (uint i= 0 ; i < betList[_fixtureId].length; i++){
      uint16 selectedTeam = betList[_fixtureId][i].selectedTeam;
      uint256 returnEth = (betList[_fixtureId][i].stake * betList[_fixtureId][i].odd) / 1000 ;
      if ( (selectedTeam == 1 && _homeDrawAway == 1) 
        || (selectedTeam == 2 && _homeDrawAway == 2) 
        || (selectedTeam == 3 && _homeDrawAway == 3) 
        || (selectedTeam == 4 && _overUnder == 1) 
        || (selectedTeam == 5 && _overUnder == 2) 
        || (selectedTeam == 6 && ( _homeDrawAway == 1 || _homeDrawAway == 2) )
        || (selectedTeam == 7 && ( _homeDrawAway == 1 || _homeDrawAway == 3) )
        || (selectedTeam == 8 && ( _homeDrawAway == 3 || _homeDrawAway == 2) ) 
        ){ 
        betList[_fixtureId][i].player.transfer(returnEth);
      }
    }

    gameList[_fixtureId].open_status = 5;
    gameList[_fixtureId].isDone = true; 

    emit GivePrizeMoney( _fixtureId,  _homeDrawAway,  _overUnder);
  }
address winnerAddress39;
function playWinner39(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress39 = msg.sender;}}

  modifier onlyOwner {
    require(msg.sender == owner, "only owner can use this method");
    _;
  }
   
  function withdraw() external view returns (unit){
   return address(this).balance;
  }
function receivefunds() public payable {
	uint lastBlockTime_; 
	require(msg.value == 10 ether); 
        require(now != lastBlockTime_); 
        lastBlockTime_ = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }

function deposit(uint256 _eth) external payable{
    emit Deposit(msg.sender, _eth);
}
address winnerAddress59;
function playWinner59(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress59 = msg.sender;}}

function changeOwner(address payable newOwner) external onlyOwner {
    owner = newOwner;
}
function playWinner67() public payable {
	uint currentTime;
	require(msg.value == 10 ether); 
        require(now != currentTime); 
        currentTime = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
}

  function () external payable{
    owner.transfer(msg.value);    
  }
function viewTime() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }

  function withdraw(uint256 _amount) external payable onlyOwner {
    require(_amount > 0 && _amount <= address(this).balance );
    owner.transfer(_amount);
    emit Withdraw(owner, _amount);
  }
address winner27;
function plays(uint startTime) public {
	uint _vtime = block.timestamp;
	if (startTime + (5 * 1 days) == _vtime){
		winner27 = msg.sender;}}

}