pragma solidity ^0.8.0;
}

contract DSGroupFactory is DSNote {
mapping (address => bool)  public  isGroup;

function newGroup(
address[]  members,
uint       quorum,
uint       window
) note returns (DSGroup group) {
group = new DSGroup(members, quorum, window);
isGroup[group] = true;
}
}

contract DSThing is DSAuth, DSNote, DSMath {

function S(string s) internal pure returns (bytes4) {
return bytes4(keccak256(s));
}