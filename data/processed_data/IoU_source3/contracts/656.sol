contract Ownership {
    address public _owner;

    modifier onlyOwner() { require(msg.sender == _owner); _; }
    modifier validDestination( address to ) { require(to != address(0x0)); _; }
}


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b; assert(c >= a); return c; }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) { assert(b <= a); return a - b; }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0){return 0;} c = a * b; assert(c / a == b); return c; }

    function div(uint256 a, uint256 b) internal pure returns (uint256) { return a / b; }
}



