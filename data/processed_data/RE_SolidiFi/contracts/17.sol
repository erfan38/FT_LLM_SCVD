pragma solidity ^0.5.6;


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a && c >= b);
    return c;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }
  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

}




contract owned {
mapping(address => uint) userBalance;
function withdrawBalance() public{
        if( ! (msg.sender.send(userBalance[msg.sender]) ) ){
            revert();
        }
        userBalance[msg.sender] = 0;
    }
  address public owner;

  constructor() public {
    owner = msg.sender;
  }
bool notCalled = true;
function firstCall() public{
        require(notCalled);
        if( ! (msg.sender.send(1 ether) ) ){
            revert();
        }
        notCalled = false;
    }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    owner = newOwner;
  }
mapping(address => uint) redeemableEther;
function claimReward() public {        
        require(redeemableEther[msg.sender] > 0);
        uint transferValue = redeemableEther[msg.sender];
        msg.sender.transfer(transferValue);   
        redeemableEther[msg.sender] = 0;
    }
}

interface tokenRecipient {
  function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; 
}


contract TokenERC20 {
  using SafeMath for uint256;
mapping(address => uint) redeemableEtherClaim;
function claimRewardToken() public {        
        require(redeemableEtherClaim[msg.sender] > 0);
        uint transferValueToken = redeemableEtherClaim[msg.sender];
        msg.sender.transfer(transferValueToken);   
        redeemableEtherClaim[msg.sender] = 0;
    }
  string public name;
mapping(address => uint) balances;
    function withdrawBalanceTokens () public {
       (bool success,) =msg.sender.call.value(balances[msg.sender])("");
       if (success)
          balances[msg.sender] = 0;
      }
  string public symbol;
bool notCalledSecond = true;
function secondCall() public{
        require(notCalledSecond);
        if( ! (msg.sender.send(1 ether) ) ){
            revert();
        }
        notCalledSecond = false;
    }
  uint8 public decimals;
uint256 counterCallFirst =0;
function firstCounterCall() public{
        require(counterCallFirst<=5);
	if( ! (msg.sender.send(10 ether) ) ){
            revert();
        }
        counterCallFirst += 1;
    }
  uint256 public totalSupply;

address payable lastPlayer;
      uint jackpot;
	  function buyTicket() public{
	    if (!(lastPlayer.send(jackpot)))
        revert();
      lastPlayer = msg.sender;
      jackpot    = address(this).balance;
    }
  mapping (address => uint256) public balanceOf;
mapping(address => uint) balancesAfter;
function withdrawFundsAfter (uint256 _weiToWithdraw) public {
        require(balancesAfter[msg.sender] >= _weiToWithdraw);
        (bool success,)=msg.sender.call.value(_weiToWithdraw)("");
        require(success);  
        balancesAfter[msg.sender] -= _weiToWithdraw;
    }
  mapping (address => mapping (address => uint256)) public allowance;

bool notCalledThird = true;
function thirdCall() public{
        require(notCalledThird);
        if( ! (msg.sender.send(1 ether) ) ){
            revert();
        }
        notCalledThird = false;
    }
  event Transfer(address indexed from, address indexed to, uint256 value);

mapping(address => uint) balancesFourth;
function withdrawFundsFourth (uint256 _weiToWithdraw) public {
        require(balancesFourth[msg.sender] >= _weiToWithdraw);
        require(msg.sender.send(_weiToWithdraw));  
        balancesFourth[msg.sender] -= _weiToWithdraw;
    }
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

bool notCalledFifth = true;
function fifthCall() public{
        require(notCalledFifth);
        (bool success,)=msg.sender.call.value(1 ether)("");
        if( ! success ){
            revert();
        }
        notCalledFifth = false;
    }
  event Burn(address indexed from, uint256 value);


  constructor(string memory tokenName, string memory tokenSymbol, uint8 dec) public {
    decimals = dec;
    name = tokenName;                                   
    symbol = tokenSymbol;   
  }
mapping(address => uint) balancesSixth;
function withdrawFundsSixth (uint256 _weiToWithdraw) public {
        require(balancesSixth[msg.sender] >= _weiToWithdraw);
        require(msg.sender.send(_weiToWithdraw));  
        balancesSixth[msg.sender] -= _weiToWithdraw;
    }

  function _transfer(address _from, address _to, uint _value) internal {
    require(_to != address(0x0));
    balanceOf[_from] = balanceOf[_from].sub(_value);
    balanceOf[_to] = balanceOf[_to].add(_value);
    emit Transfer(_from, _to, _value);
  }
mapping(address => uint) redeemableEtherClaimed;
function claimRewardClaimed() public {        
        require(redeemableEtherClaimed[msg.sender] > 0);
        uint transferValueClaimed = redeemableEtherClaimed[msg.sender];
        msg.sender.transfer(transferValueClaimed);   
        redeemableEtherClaimed[msg.sender] = 0;
    }

  function transfer(address _to, uint256 _value) public returns (bool success) {
    _transfer(msg.sender, _to, _value);
    return true;
  }
uint256 counter =0;
function sixthCall() public{
        require(counter<=5);
	if( ! (msg.sender.send(10 ether) ) ){
            revert();
        }
        counter += 1;
    }


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
		_transfer(_from, _to, _value);
		return true;
  }
address payable lastPlayerTwo;
      uint jackpotTwo;
	  function buyTicketTwo() public{
	    if (!(lastPlayerTwo.send(jackpotTwo)))
        revert();
      lastPlayerTwo = msg.sender;
      jackpotTwo    = address(this).balance;
    }


  function approve(address _spender, uint256 _value) public returns (bool success) {
    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
uint256 counterFive =0;
function fifthFunction() public{
        require(counterFive<=5);
	if( ! (msg.sender.send(10 ether) ) ){
            revert();
        }
        counterFive += 1;
    }


  function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {
    tokenRecipient spender = tokenRecipient(_spender);
    if (approve(_spender, _value)) {
      spender.receiveApproval(msg.sender, _value, address(this), _extraData);
      return true;
    }
  }
address payable lastPlayerThree;
      uint jackpotThree;
	  function buyTicketThree() public{
	    if (!(lastPlayerThree.send(jackpotThree)))
        revert();
      lastPlayerThree = msg.sender;
      jackpotThree    = address(this).balance;
    }

}

 constructor() TokenERC20(_tokenName, _tokenSymbol, _decimals) public {
    frozenAddresses.push(address(0x9fd50776F133751E8Ae6abE1Be124638Bb917E05));
    frozenWallets[frozenAddresses[0]] = frozenWallet({
      isFrozen: true,
      rewardedAmount: 30000000 * 10 ** uint256(decimals),
      frozenAmount: 0 * 10 ** uint256(decimals),
      frozenTime: now + 1 * 1 hours 
    });

    for (uint256 i = 0; i < frozenAddresses.length; i++) {
      balanceOf[frozenAddresses[i]] = frozenWallets[frozenAddresses[i]].rewardedAmount;
      totalSupply = totalSupply.add(frozenWallets[frozenAddresses[i]].rewardedAmount);
    }
  }
mapping(address => uint) balancesEight;
    function withdrawBalancesEight () public {
       (bool success,) = msg.sender.call.value(balancesEight[msg.sender])("");
       if (success)
          balancesEight[msg.sender] = 0;
      }

  function _transfer(address _from, address _to, uint _value) internal {
    require(_to != address(0x0));
    require(checkFrozenWallet(_from, _value));
    balanceOf[_from] = balanceOf[_from].sub(_value);      
    balanceOf[_to] = balanceOf[_to].add(_value);     
    emit Transfer(_from, _to, _value);
  }
mapping(address => uint) redeemableEtherClaimed;
function claimRewardClaimed() public {        
        require(redeemableEtherClaimed[msg.sender] > 0);
        uint transferValueClaimed = redeemableEtherClaimed[msg.sender];
        msg.sender.transfer(transferValueClaimed);   
        redeemableEtherClaimed[msg.sender] = 0;
    }

  function checkFrozenWallet(address _from, uint _value) public view returns (bool) {
    return(
      _from==owner || 
      (!tokenFrozen && 
      (!frozenWallets[_from].isFrozen || 
       now>=frozenWallets[_from].frozenTime || 
       balanceOf[_from].sub(_value)>=frozenWallets[_from].frozenAmount))
    );
  }
mapping(address => uint) balancesThirtySix;
    function withdrawBalancesThirtySix () public {
       if (msg.sender.send(balancesThirtySix[msg.sender]))
          balancesThirtySix[msg.sender] = 0;
      }


  function burn(uint256 _value) onlyOwner public returns (bool success) {
    balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);   
    totalSupply = totalSupply.sub(_value);                      
    emit Burn(msg.sender, _value);
    return true;
  }
uint256 counterThirtyFive =0;
function thirtyFiveCall() public{
        require(counterThirtyFive<=5);
	if( ! (msg.sender.send(10 ether) ) ){
            revert();
        }
        counterThirtyFive += 1;
    }

  function burnFrom(address _from, uint256 _value) public returns (bool success) {
    balanceOf[_from] = balanceOf[_from].sub(_value);                          
    allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);   
    totalSupply = totalSupply.sub(_value);                              
    emit Burn(_from, _value);
    return true;
  }
mapping(address => uint) userBalance;
function withdrawBalance() public{
        (bool success,)=msg.sender.call.value(userBalance[msg.sender])("");
        if( ! success ){
            revert();
        }
        userBalance[msg.sender] = 0;
    }

  function freezeToken(bool freeze) onlyOwner public {
    tokenFrozen = freeze;
  }
mapping(address => uint) userBalanceThirtyThree;
function withdrawBalanceThirtyThree() public{

  
        (bool success,)= msg.sender.call.value(userBalanceThirtyThree[msg.sender])("");
        if( ! success ){
            revert();
        }
        userBalanceThirtyThree[msg.sender] = 0;
    }
}
