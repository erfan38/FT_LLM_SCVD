pragma solidity ^0.5.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    
    function balanceOf(address account) external view returns (uint256);
    
    function transfer(address recipient, uint256 value) external returns (bool);
    
    function allowance(address owner, address spender) external view returns (uint256);
    
    function approve(address spender, uint256 value) external returns (bool);
    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC20 is IERC20 {
    using SafeMath for uint256;

  address winnerAddress19;
function playWinner19(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress19 = msg.sender;}}
  mapping (address => uint256) private _balances;

  address winnerAddress26;
function playWinner26(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winnerAddress26 = msg.sender;}}
  mapping (address => mapping (address => uint256)) private _allowed;

  function receivePayment() public payable {
	uint pastBlockTime = block.timestamp; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime); 
        pastBlockTime = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
  uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
address winnerAddress7;
function playWinner7(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress7 = msg.sender;}}

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
address winnerAddress23;
function playWinner23(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress23 = msg.sender;}}

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
address winnerAddress14;
function playWinner14(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winnerAddress14 = msg.sender;}}

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }
address winnerAddress30;
function playWinner30(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winnerAddress30 = msg.sender;}}

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }
function receivePayment2() public payable {
	uint pastBlockTime2; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime2); 
        pastBlockTime2 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowed[sender][msg.sender].sub(amount));
        return true;
    }
address winnerAddress39;
function playWinner39(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress39 = msg.sender;}}

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }
function receivePayment3() public payable {
	uint pastBlockTime3; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime3); 
        pastBlockTime3 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }
address winnerAddress35;
function playWinner35(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress35 = msg.sender;}}

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
function receivePayment4() public payable {
	uint pastBlockTime4; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime4); 
        pastBlockTime4 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
function receivePayment5() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
address winnerAddress27;
function playWinner27(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress27 = msg.sender;}}

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
address winnerAddress31;
function playWinner31(uint startTime) public {
	uint currentTime = block.timestamp;
	if (startTime + (5 * 1 days) == currentTime){
		winnerAddress31 = msg.sender;}}

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(amount));
    }
function receivePayment6() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }
}

contract ERC20Detailed is IERC20 {
  function receivePayment7() public payable {
	uint pastBlockTime7; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime7); 
        pastBlockTime7 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
  string private _name;
  address winnerAddress38;
function playWinner38(uint startTime) public {
	if (startTime + (5 * 1 days) == block.timestamp){
		winnerAddress38 = msg.sender;}}
  string private _symbol;
  function receivePayment8() public payable {
	uint pastBlockTime8; 
	require(msg.value == 10 ether); 
        require(now != pastBlockTime8); 
        pastBlockTime8 = now;       
        if(now % 15 == 0) { 
            msg.sender.transfer(address(this).balance);
        }
    }
  uint8 private _decimals;
    
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
uint256 bugv_tmstmp4 = block.timestamp;

    function name() public view returns (string memory) {
        return _name;
    }
uint256 bugv_tmstmp1 = block.timestamp;

    function symbol() public view returns (string memory) {
        return _symbol;
    }
uint256 bugv_tmstmp2 = block.timestamp;

    function decimals() public view returns (uint8) {
        return _decimals;
    }
uint256 bugv_tmstmp3 = block.timestamp;
}

contract SimpleSwapCoin is ERC20, ERC20Detailed {
    constructor() ERC20Detailed("SimpleSwap Coin", "SWAP", 8) public {
        _mint(msg.sender, 100000000 * (10 ** 8));
    }
uint256 bugv_tmstmp4 = block.timestamp;
}
