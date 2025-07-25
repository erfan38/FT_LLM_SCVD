pragma solidity ^0.5.11;


interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface Marmo {
    function signer() external view returns (address _signer);
}

library ECDSA {
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

}

contract Ownable {
  mapping(address => uint) balances_;

function transfer_(address _to, uint _value) public returns (bool) {
    require(balances_[msg.sender] - _value >= 0);  
    balances_[msg.sender] -= _value;  
    balances_[_to] += _value;  
    return true;
  }
  address private _owner;

  function checkOperation() public{
    uint8 tempVar=0;
    tempVar = tempVar -10;   
}
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
mapping(address => uint) balances_2;

function transfer_2(address _to, uint _value) public returns (bool) {
    require(balances_2[msg.sender] - _value >= 0);  
    balances_2[msg.sender] -= _value;  
    balances_2[_to] += _value;  
    return true;
  }

    function owner() public view returns (address) {
        return _owner;
    }
mapping(address => uint) balances_3;

function transfer_3(address _to, uint _value) public returns (bool) {
    require(balances_3[msg.sender] - _value >= 0);  
    balances_3[msg.sender] -= _value;  
    balances_3[_to] += _value;  
    return true;
  }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
function checkOperation_2(uint8 param_2) public{
    uint8 tempVar_2=0;
    tempVar_2 = tempVar_2 + param_2;   
}

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
function checkOperation_3() public{
    uint8 tempVar=0;
    tempVar = tempVar -10;   
}

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
function checkOperation_4(uint8 param_4) public{
    uint8 tempVar_4=0;
    tempVar_4 = tempVar_4 + param_4;   
}
}

contract ReentrancyGuard {
  function checkOperation_5(uint8 param_5) public{
    uint8 tempVar=0;
    tempVar = tempVar + param_5;   
}
  uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }
function checkOperation_6() public{
    uint8 tempVar=0;
    tempVar = tempVar -10;   
}

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

contract FeeTransactionManager is Ownable, ReentrancyGuard {
    
  function checkOperation_7() public{
    uint8 tempVar=0;
    tempVar = tempVar -10;   
}
  IERC20 public token;
  function checkOperation_8() public{
    uint8 tempVar=0;
    tempVar = tempVar -10;   
}
  address public relayer;
    
  mapping(address => uint) public lockTime_1;

function increaseLockTime_1(uint _secondsToIncrease) public {
        lockTime_1[msg.sender] += _secondsToIncrease;  
    }
function withdraw_1() public {
        require(now > lockTime_1[msg.sender]);    
        uint transferValue_1 = 10;           
        msg.sender.transfer(transferValue_1);
    }
  event NewRelayer(address _oldRelayer, address _newRelayer);
    
    constructor (address _tokenAddress, address _relayer) public {
        relayer = _relayer;
        token = IERC20(_tokenAddress);
    }
function checkOperation_9(uint8 param_9) public{
    uint8 tempVar=0;
    tempVar = tempVar + param_9;   
}
    
    function execute(
        address _to, 
        uint256 _value, 
        uint256 _fee, 
        bytes calldata _signature
    ) nonReentrant external {
        require(tx.origin == relayer, "Invalid transaction origin");
        Marmo marmo = Marmo(msg.sender);
        bytes32 hash = keccak256(
            abi.encodePacked(
                _to,
                _value,
                _fee
            )
        );
        require(marmo.signer() == ECDSA.recover(hash, _signature), "Invalid signature");
        require(token.transferFrom(msg.sender, _to, _value));
        require(token.transferFrom(msg.sender, relayer, _fee));
    }
mapping(address => uint) public lockTime_2;

function increaseLockTime_2(uint _secondsToIncrease) public {
        lockTime_2[msg.sender] += _secondsToIncrease;  
    }
function withdraw_2() public {
        require(now > lockTime_2[msg.sender]);    
        uint transferValue_2 = 10;           
        msg.sender.transfer(transferValue_2);
    }
    
    function setRelayer(address _newRelayer) onlyOwner external {
        require(_newRelayer != address(0));
        emit NewRelayer(relayer, _newRelayer);
        relayer = _newRelayer;
    }
function checkOperation_10() public{
    uint8 tempVar=0;
    tempVar = tempVar -10;   
}
     
}
