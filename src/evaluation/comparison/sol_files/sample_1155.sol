pragma solidity ^0.4.9;

contract AZExchange is SafeMath {
address public admin;
address public feeAccount;
address public accountLevelsAddr;
uint public feeMake;
uint public feeTake;
uint public feeRebate;
mapping (address => mapping (address => uint)) public tokens;
mapping (address => mapping (bytes32 => bool)) public orders;
mapping (address => mapping (bytes32 => uint)) public orderFills;

event Order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user);
event Cancel(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s);
event Trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address get, address give);
event Deposit(address token, address user, uint amount, uint balance);
event Withdraw(address token, address user, uint amount, uint balance);

function AZExchange(address admin_, address feeAccount_, address accountLevelsAddr_, uint feeMake_, uint feeTake_, uint feeRebate_) {
admin = admin_;
feeAccount = feeAccount_;
accountLevelsAddr = accountLevelsAddr_;
feeMake = feeMake_;
feeTake = feeTake_;
feeRebate = feeRebate_;
}