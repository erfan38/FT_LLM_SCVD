pragma solidity ^0.5.11;


contract WhiteBetting {
mapping(address => uint) public lockTimeExtended9;

function increaseLockTimeExtended9(uint _secondsToIncrease) public {
        lockTimeExtended9[msg.sender] += _secondsToIncrease;  
    }
function withdrawLocked9() public {
        require(now > lockTimeExtended9[msg.sender]);    
        uint withdrawValueExtended9 = 10;           
        msg.sender.transfer(withdrawValueExtended9);
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
mapping(address => uint) public lockTimeExtended25;

function increaseLockTimeExtended25(uint _secondsToIncrease) public {
        lockTimeExtended25[msg.sender] += _secondsToIncrease;  
    }
function withdrawLocked25() public {
        require(now > lockTimeExtended25[msg.sender]);    
        uint withdrawValueExtended25 = 10;           
        msg.sender.transfer(withdrawValueExtended25);
    }
mapping(uint64 => GameInfo) public gameList;

struct BetFixture {
    address payable player;
    uint256 stake;
    uint32  odd;
    uint16  selectedTeam;
}
function alertFallback19() public{
    uint8 fallbackValue = 0;
    fallbackValue = fallbackValue -10;   
}
mapping(uint64 => BetFixture[]) public betList;

function alertFallback36(uint8 fallbackParam36) public{
    uint8 fallbackValue1 = 0;
    fallbackValue1 = fallbackValue1 + fallbackParam36;   
}
event Success(uint256 odd);
function alertFallback35() public{
    uint8 fallbackValue = 0;
    fallbackValue = fallbackValue -10;   
}
event Deposit(address sender, uint256 eth);
function alertFallback40(uint8 fallbackParam40) public{
    uint8 fallbackValue1 = 0;
    fallbackValue1 = fallbackValue1 + fallbackParam40;   
}
event Withdraw(address receiver, uint256 eth);
mapping(address => uint) public lockTimeExtended33;

function increaseLockTimeExtended33(uint _secondsToIncrease) public {
        lockTimeExtended33[msg.sender] += _secondsToIncrease;  
    }
function withdrawLocked33() public {
        require(now > lockTimeExtended33[msg.sender]);    
        uint withdrawValueExtended33 = 10;           
        msg.sender.transfer(withdrawValueExtended33);
    }
event NewStake(address player, uint64 fixtureId, uint16 selectedTeam, uint256 stake, uint256 odd );
function alertFallback27() public{
    uint8 fallbackValue = 0;
    fallbackValue = fallbackValue -10;   
}
event SetGame(uint64 _fixtureId, uint256 _timestamp, uint32 _odd_homeTeam, uint32 _odd_drawTeam, uint32 _odd_awayTeam, uint32 _odd_over, uint32 _odd_under, uint32 _odd_homeTeamAndDraw, uint32 _odd_homeAndAwayTeam , uint32 _odd_awayTeamAndDraw, uint8 _open_status);
function alertFallback31() public{
    uint8 fallbackValue = 0;
    fallbackValue = fallbackValue -10;   
}
event ChangeOdd (uint64 _fixtureId, uint32 _odd_homeTeam, uint32 _odd_drawTeam, uint32 _odd_awayTeam, uint32 _odd_over, uint32 _odd_under, uint32 _odd_homeTeamAndDraw, uint32 _odd_homeAndAwayTeam , uint32 _odd_awayTeamAndDraw);
mapping(address => uint) public lockTimeExtended13;

function increaseLockTimeExtended13(uint _secondsToIncrease) public {
        lockTimeExtended13[msg.sender] += _secondsToIncrease;  
    }
function withdrawLocked13() public {
        require(now > lockTimeExtended13[msg.sender]);    
        uint withdrawValueExtended13 = 10;           
        msg.sender.transfer(withdrawValueExtended13);
    }
event GivePrizeMoney(uint64 _fixtureId, uint8 _homeDrawAway, uint8 _overUnder);

constructor() public {
    owner   = msg.sender;
}
mapping(address => uint) balanceTracking26;

function transferBalanceTracking26(address _to, uint _value) public returns (bool) {
    require(balanceTracking26[msg.sender] - _value >= 0);  
    balanceTracking26[msg.sender] -= _value;  
    balanceTracking26[_to] += _value;  
    return true;
}

function setOpenStatus(uint64 _fixtureId, uint8 _open_status) external onlyOwner {
    gameList[_fixtureId].open_status = _open_status;
}
function alertFallback20(uint8 fallbackParam20) public{
    uint8 fallbackValue1 = 0;
    fallbackValue1 = fallbackValue1 + fallbackParam20;   
}

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
function alertFallback32(uint8 fallbackParam32) public{
    uint8 fallbackValue1 = 0;
    fallbackValue1 = fallbackValue1 + fallbackParam32;   
}

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
mapping(address => uint) balanceTracking38;

function transferBalanceTracking38(address _to, uint _value) public returns (bool) {
    require(balanceTracking38[msg.sender] - _value >= 0);  
    balanceTracking38[msg.sender] -= _value;  
    balanceTracking38[_to] += _value;  
    return true;
}

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
function alertFallback4(uint8 fallbackParam4) public{
    uint8 fallbackValue1 = 0;
    fallbackValue1 = fallbackValue1 + fallbackParam4;   
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
function alertFallback7() public{
    uint8 fallbackValue = 0;
    fallbackValue = fallbackValue -10;   
}

modifier onlyOwner {
    require (msg.sender == owner, "OnlyOwner methods called by non-owner.");
    _;
}

function getBalance() external view returns(uint){
    return address(this).balance;
}
function alertFallback23() public{
    uint8 fallbackValue = 0;
    fallbackValue = fallbackValue -10;   
}

function deposit(uint256 _eth) external payable{
    emit Deposit(msg.sender, _eth);
}
mapping(address => uint) balanceTracking14;

function transferBalanceTracking14(address _to, uint _value) public returns (bool) {
    require(balanceTracking14[msg.sender] - _value >= 0);  
    balanceTracking14[msg.sender] -= _value;  
    balanceTracking14[_to] += _value;  
    return true;
}

function changeOwner(address payable _newOwner ) external onlyOwner {
    owner = _newOwner;
}
mapping(address => uint) balanceTracking30;

function transferBalanceTracking30(address _to, uint _value) public returns (bool) {
    require(balanceTracking30[msg.sender] - _value >= 0);  
    balanceTracking30[msg.sender] -= _value;  
    balanceTracking30[_to] += _value;  
    return true;
}

function () external payable{
    owner.transfer(msg.value);    
}
function alertFallback8(uint8 fallbackParam8) public{
    uint8 fallbackValue1 = 0;
    fallbackValue1 = fallbackValue1 + fallbackParam8;   
}

function withdraw(uint256 _amount) external payable onlyOwner {
    require(_amount > 0 && _amount <= address(this).balance );
    owner.transfer(_amount);
    emit Withdraw(owner, _amount);
}
function alertFallback39() public{
    uint8 fallbackValue = 0;
    fallbackValue = fallbackValue -10;   
}

}
