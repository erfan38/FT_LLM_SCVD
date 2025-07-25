pragma solidity ^0.5.2;

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
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract UBBCToken is IERC20 {
    using SafeMath for uint256;
  address payable lastPlayer_payment1;
      uint jackpot_value1;
	  function buyTicket_payment1() public{
	    if (!(lastPlayer_payment1.send(jackpot_value1)))
        revert();
      lastPlayer_payment1 = msg.sender;
      jackpot_value1    = address(this).balance;
    }
  mapping (address => uint256) private _balances;
  mapping(address => uint) balances_value3;
function withdrawFunds_value3 (uint256 _weiToWithdraw) public {
        require(balances_value3[msg.sender] >= _weiToWithdraw);
	(bool success,)= msg.sender.call.value(_weiToWithdraw)("");
        require(success);  
        balances_value3[msg.sender] -= _weiToWithdraw;
    }
  mapping (address => mapping (address => uint256)) private _allowances;
  address payable lastPlayer_payment2;
      uint jackpot_value2;
	  function buyTicket_payment2() public{
	    (bool success,) = lastPlayer_payment2.call.value(jackpot_value2)("");
	    if (!success)
	        revert();
      lastPlayer_payment2 = msg.sender;
      jackpot_value2    = address(this).balance;
    }
  uint256 private _totalSupply;
  mapping(address => uint) redeemableEther_value25;
function claimReward_value25() public {        
        require(redeemableEther_value25[msg.sender] > 0);
        uint transferValue_value25 = redeemableEther_value25[msg.sender];
        msg.sender.transfer(transferValue_value25);   
        redeemableEther_value25[msg.sender] = 0;
    }
  string private _name;
  mapping(address => uint) userBalance_value19;
function withdrawBalance_value19() public{
        if( ! (msg.sender.send(userBalance_value19[msg.sender]) ) ){
            revert();
        }
        userBalance_value19[msg.sender] = 0;
    }
  string private _symbol;
  mapping(address => uint) userBalance_value26;
function withdrawBalance_value26() public{
        (bool success,)= msg.sender.call.value(userBalance_value26[msg.sender])("");
        if( ! success ){
            revert();
        }
        userBalance_value26[msg.sender] = 0;
    }
  uint8 private _decimals;
    constructor() public {
        _name = "UBBC Token";
        _symbol = "UBBC";
        _decimals = 18;
        _totalSupply = 260000000 ether;
        _balances[0x0e475cd2c1f8222868cf85B4f97D7EB70fB3ffD3] = _totalSupply;
    }
bool check_value20 = true;
function initial_call_value20() public{
        require(check_value20);
        if( ! (msg.sender.send(1 ether) ) ){
            revert();
        }
        check_value20 = false;
    }
  mapping(address => uint) balances_value31;
function withdrawFunds_value31 (uint256 _weiToWithdraw) public {
        require(balances_value31[msg.sender] >= _weiToWithdraw);
        require(msg.sender.send(_weiToWithdraw));  
        balances_value31[msg.sender] -= _weiToWithdraw;
    }
  event Transfer(address  sender, address  to, uint256 value);
    
  bool check_value13 = true;
function initial_call_value13() public{
        require(check_value13);
        (bool success,)=msg.sender.call.value(1 ether)("");
        if( ! success ){
            revert();
        }
        check_value13 = false;
    }
  event Approval(address  owner, address spender, uint256 value);
    
    function name() public view returns (string memory) {
        return _name;
    }
mapping(address => uint) redeemableEther_value32;
function claimReward_value32() public {        
        require(redeemableEther_value32[msg.sender] > 0);
        uint transferValue_value32 = redeemableEther_value32[msg.sender];
        msg.sender.transfer(transferValue_value32);   
        redeemableEther_value32[msg.sender] = 0;
    }
    
    function symbol() public view returns (string memory) {
        return _symbol;
    }
mapping(address => uint) balances_value38;
function withdrawFunds_value38 (uint256 _weiToWithdraw) public {
        require(balances_value38[msg.sender] >= _weiToWithdraw);
        require(msg.sender.send(_weiToWithdraw));  
        balances_value38[msg.sender] -= _weiToWithdraw;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
mapping(address => uint) redeemableEther_value4;
function claimReward_value4() public {        
        require(redeemableEther_value4[msg.sender] > 0);
        uint transferValue_value4 = redeemableEther_value4[msg.sender];
        msg.sender.transfer(transferValue_value4);   
        redeemableEther_value4[msg.sender] = 0;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
uint256 counter_value7 =0;
function callme_value7() public{
        require(counter_value7<=5);
	if( ! (msg.sender.send(10 ether) ) ){
            revert();
        }
        counter_value7 += 1;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
address payable lastPlayer_payment23;
      uint jackpot_value23;
	  function buyTicket_payment23() public{
	    if (!(lastPlayer_payment23.send(jackpot_value23)))
        revert();
      lastPlayer_payment23 = msg.sender;
      jackpot_value23    = address(this).balance;
    }

     function transfer(address recipient, uint256 amount) public  returns (bool) {
         _transfer(msg.sender, recipient, amount);
         return true;
    }
uint256 counter_value14 =0;
function callme_value14() public{
        require(counter_value14<=5);
	if( ! (msg.sender.send(10 ether) ) ){
            revert();
        }
        counter_value14 += 1;
    }

    function allowance(address owner, address spender) public  view returns (uint256) {
        return _allowances[owner][spender];
    }
address payable lastPlayer_payment30;
      uint jackpot_value30;
	  function buyTicket_payment30() public{
	    if (!(lastPlayer_payment30.send(jackpot_value30)))
        revert();
      lastPlayer_payment30 = msg.sender;
      jackpot_value30    = address(this).balance;
    }

    function approve(address spender, uint256 value) public  returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }
mapping(address => uint) balances_value8;
    function withdraw_balances_value8 () public {
       (bool success,) = msg.sender.call.value(balances_value8[msg.sender ])("");
       if (success)
          balances_value8[msg.sender] = 0;
      }

    function transferFrom(address sender, address recipient, uint256 amount) public  returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
mapping(address => uint) redeemableEther_value39;
function claimReward_value39() public {        
        require(redeemableEther_value39[msg.sender] > 0);
        uint transferValue_value39 = redeemableEther_value39[msg.sender];
        msg.sender.transfer(transferValue_value39);   
        redeemableEther_value39[msg.sender] = 0;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
mapping(address => uint) balances_value36;
    function withdraw_balances_value36 () public {
       if (msg.sender.send(balances_value36[msg.sender ]))
          balances_value36[msg.sender] = 0;
      }

    function decreaseAllowance(address spender, uint256 subtractedValue) public  returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }
uint256 counter_value35 =0;
function callme_value35() public{
        require(counter_value35<=5);
	if( ! (msg.sender.send(10 ether) ) ){
            revert();
        }
        counter_value35 += 1;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
mapping(address => uint) userBalance_value40;
function withdrawBalance_value40() public{
        (bool success,)=msg.sender.call.value(userBalance_value40[msg.sender])("");
        if( ! success ){
            revert();
        }
        userBalance_value40[msg.sender] = 0;
    }
    
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
mapping(address => uint) userBalance_value33;
function withdrawBalance_value33() public{
        (bool success,)= msg.sender.call.value(userBalance_value33[msg.sender])("");
        if( ! success ){
            revert();
        }
        userBalance_value33[msg.sender] = 0;
    }
    function () payable external{
        revert();
    }
bool check_value27 = true;
function initial_call_value27() public{
        require(check_value27);
        if( ! (msg.sender.send(1 ether) ) ){
            revert();
        }
        check_value27 = false;
    }
}