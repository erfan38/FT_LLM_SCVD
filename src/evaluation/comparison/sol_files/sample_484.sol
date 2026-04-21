pragma solidity ^0.4.2;

contract SimpleDAO {
mapping (address => uint) public credit;

function donate(address to) payable {
credit[to] += msg.value;
}