pragma solidity ^0.8.0;
contract EthTeamContract is StandardToken, Ownable {
event Buy(address indexed token, address indexed from, uint256 value, uint256 weiValue);
event Sell(address indexed token, address indexed from, uint256 value, uint256 weiValue);
event BeginGame(address indexed team1, address indexed team2, uint64 gameTime);
event EndGame(address indexed team1, address indexed team2, uint8 gameResult);
event ChangeStatus(address indexed team, uint8 status);


uint256 public price;

uint8 public status;

uint64 public gameTime;

uint64 public finishTime;

address public feeOwner;

address public gameOpponent;


function EthTeamContract(
string _teamName, string _teamSymbol, address _gameOpponent, uint64 _gameTime, uint64 _finishTime, address _feeOwner
) public {
name = _teamName;
symbol = _teamSymbol;
decimals = 3;
totalSupply_ = 0;
price = 1 szabo;
gameOpponent = _gameOpponent;
gameTime = _gameTime;
finishTime = _finishTime;
feeOwner = _feeOwner;
owner = msg.sender;
}


function transfer(address _to, uint256 _value) public returns (bool) {
if (_to != address(this)) {
return super.transfer(_to, _value);
}
require(_value <= balances_[msg.sender] && status == 0);

if (gameTime > 1514764800) {

require(gameTime - 300 > block.timestamp);
}
balances_[msg.sender] = balances_[msg.sender].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
uint256 weiAmount = price.mul(_value);
msg.sender.transfer(weiAmount);
emit Transfer(msg.sender, _to, _value);
emit Sell(_to, msg.sender, _value, weiAmount);
return true;
}