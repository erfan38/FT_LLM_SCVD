pragma solidity ^0.4.23;






library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}






contract Erc20Wallet {
  mapping (address => mapping (address => uint)) public tokens; 

  event Deposit(address token, address user, uint amount, uint balance);
  event Withdraw(address token, address user, uint amount, uint balance);

  mapping (address => uint) public totalDeposited;

  function() public {
    revert();
  }

  modifier onlyToken (address token) {
    require( token != 0);
    _;
  }

  function commonDeposit(address token, uint value) internal {
    tokens[token][msg.sender] += value;
    totalDeposited[token] += value;
    emit Deposit(
      token,
      msg.sender,
      value,
      tokens[token][msg.sender]);
  }
  function commonWithdraw(address token, uint value) internal {
    require (tokens[token][msg.sender] >= value);
    tokens[token][msg.sender] -= value;
    totalDeposited[token] -= value;
    require((token != 0)?
      ERC20(token).transfer(msg.sender, value):
      
      msg.sender.call.value(value)()
    );
    emit Withdraw(
      token,
      msg.sender,
      value,
      tokens[token][msg.sender]);
  }

  function deposit() public payable {
    commonDeposit(0, msg.value);
  }
  function withdraw(uint amount) public {
    commonWithdraw(0, amount);
  }


  function depositToken(address token, uint amount) public onlyToken(token){
    
    require (ERC20(token).transferFrom(msg.sender, this, amount));
    commonDeposit(token, amount);
  }
  function withdrawToken(address token, uint amount) public {
    commonWithdraw(token, amount);
  }

  function balanceOf(address token, address user) public constant returns (uint) {
    return tokens[token][user];
  }
}






