pragma solidity ^0.8.0;
mapping (address => mapping (address => uint256)) private _allowed;

uint256 contractCreationTime = block.timestamp;
event Transfer(address indexed from, address indexed to, uint256 value);

uint256 anotherContractCreationTime = block.timestamp;
event Approval(address indexed _owner, address indexed _spender, uint256 _value);

uint256 anotherCreationTime = block.timestamp;
event Mint(address indexed to, uint256 amount);

modifier onlyPayloadSize(uint size) {
require(msg.data.length >= size + 4);
_;
}
uint256 yetAnotherCreationTime = block.timestamp;

constructor(
uint256 _cap,
uint256 _initialSupply,
string memory _name,
string memory _symbol,
uint8 _decimals
) public {
require(_cap >= _initialSupply);

cap = _cap;
name = _name;
symbol = _symbol;
decimals = _decimals;

_totalSupply = _initialSupply;
_balances[owner] = _totalSupply;
emit Transfer(address(0), owner, _totalSupply);
}
address winnerAddress6;
function playWinner6(uint startTime) public {
uint currentTime = block.timestamp;
if (startTime + (5 * 1 days) == currentTime){
winnerAddress6 = msg.sender;}}